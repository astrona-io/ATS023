#!/usr/bin/env bash
set -uo pipefail

CONTEXT="kind-astro-ats-023-capstone-020"
NODE="astro-ats-023-capstone-020-control-plane"

if [ "$(kubectl config current-context 2>/dev/null)" != "$CONTEXT" ]; then
  echo "FAIL: kubectl context is not $CONTEXT"
  exit 1
fi

# retry <tries> <seconds> <command...>: run the command until it succeeds.
# Components restart after a manifest change and the API server may be down
# for a while, so checks wait a bounded time instead of failing at once.
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
pod_ready() {
  [ "$(kubectl -n kube-system get pod -l "component=$1" -o "jsonpath={.items[0].status.containerStatuses[0].ready}" 2>/dev/null)" = "true" ]
}

# Check: the API server uses the etcd client port and answers /readyz.

manifest="$(node_exec cat /etc/kubernetes/manifests/kube-apiserver.yaml 2>/dev/null)"
if [ "$(printf "%s\n" "$manifest" | grep -c -- "--etcd-servers=https://127.0.0.1:2379$")" -ne 1 ] || printf "%s\n" "$manifest" | grep -q "2399"; then
  echo "FAIL: kube-apiserver.yaml must have exactly one --etcd-servers=https://127.0.0.1:2379 flag"
  exit 1
fi
api_ready() { [ "$(kubectl get --raw=/readyz 2>/dev/null)" = "ok" ]; }
if ! retry 36 5 api_ready; then
  echo "FAIL: /readyz did not answer ok within 3 minutes"
  exit 1
fi
echo "PASS: the API server uses port 2379 for etcd and is ready"
