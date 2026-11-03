#!/usr/bin/env bash
set -uo pipefail

CONTEXT="kind-astro-ats-023-lab-020-02-01"
NODE="astro-ats-023-lab-020-02-01-control-plane"

if [ "$(kubectl config current-context 2>/dev/null)" != "$CONTEXT" ]; then
  echo "FAIL: kubectl context is not $CONTEXT"
  exit 1
fi

# retry <tries> <seconds> <command...>: run the command until it succeeds.
# The API server restarts after a manifest change, so every check that needs
# the API waits for it a bounded time instead of failing at once.
retry() {
  local tries="$1" pause="$2" attempt
  shift 2
  for ((attempt = 1; attempt <= tries; attempt++)); do
    if "$@"; then
      return 0
    fi
    sleep "$pause"
  done
  return 1
}

node_exec() { podman exec "$NODE" "$@"; }

# Check: etcd is unchanged and healthy by its own etcdctl check, and the API server reports its etcd check as ok.

etcd_manifest="$(node_exec cat /etc/kubernetes/manifests/etcd.yaml 2>/dev/null)"
if ! printf "%s\n" "$etcd_manifest" | grep -q -- "--listen-client-urls=https://127.0.0.1:2379"; then
  echo "FAIL: etcd.yaml no longer listens for clients on 127.0.0.1:2379 (the etcd manifest must stay unchanged)"
  exit 1
fi

etcd_health() {
  local id
  id="$(node_exec crictl ps --name etcd --state running -q 2>/dev/null | head -n 1)"
  [ -n "$id" ] || return 1
  node_exec crictl exec "$id" etcdctl endpoint health \
    --endpoints=https://127.0.0.1:2379 \
    --cacert=/etc/kubernetes/pki/etcd/ca.crt \
    --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt \
    --key=/etc/kubernetes/pki/etcd/healthcheck-client.key 2>&1 | grep -q "is healthy"
}
api_etcd_ok() { [ "$(kubectl get --raw=/readyz/etcd 2>/dev/null)" = "ok" ]; }

if ! retry 12 5 etcd_health; then
  echo "FAIL: etcdctl endpoint health did not report a healthy endpoint"
  exit 1
fi
if ! retry 24 5 api_etcd_ok; then
  echo "FAIL: the API server /readyz/etcd check is not ok"
  exit 1
fi
echo "PASS: etcd is healthy and the API server reaches it"
