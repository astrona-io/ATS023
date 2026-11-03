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

# Check: probe is reachable through its Service, the other workloads are intact and the manifest directory is clean.

files="$(node_exec ls -A /etc/kubernetes/manifests 2>/dev/null | tr "\n" " ")"
if [ "$files" != "etcd.yaml kube-apiserver.yaml kube-controller-manager.yaml kube-scheduler.yaml " ]; then
  echo "FAIL: the manifest directory holds unexpected files: $files"
  exit 1
fi
if ! node_exec grep -q -- "--listen-client-urls=https://127.0.0.1:2379" /etc/kubernetes/manifests/etcd.yaml; then
  echo "FAIL: the etcd manifest was changed"
  exit 1
fi
reach() { kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://probe/ 2>/dev/null | grep -q "version="; }
if ! retry 24 5 reach; then
  echo "FAIL: shuttle cannot reach the probe Service"
  exit 1
fi
if [ "$(kubectl -n outpost get pod drifter -o "jsonpath={.status.phase}" 2>/dev/null)" != "Running" ]; then
  echo "FAIL: Pod drifter in outpost is not Running"
  exit 1
fi
echo "PASS: the Service answers, the workloads are intact and the manifest directory is clean"
