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

# Check: scout has two available replicas through a ReplicaSet, placed by the scheduler.

available() { [ "$(kubectl -n starfleet get deployment scout -o "jsonpath={.status.availableReplicas}" 2>/dev/null)" = "2" ]; }
if ! retry 48 5 available; then
  echo "FAIL: Deployment scout in starfleet does not have two available replicas"
  exit 1
fi
fixed="$(kubectl -n starfleet get deployment scout -o "jsonpath={.spec.template.spec.nodeName}" 2>/dev/null)"
if [ -n "$fixed" ]; then
  echo "FAIL: the scout Deployment sets nodeName=$fixed; the scheduler must choose the node"
  exit 1
fi
owner="$(kubectl -n starfleet get pods -l app=scout -o "jsonpath={.items[*].metadata.ownerReferences[0].kind}" 2>/dev/null)"
if [ "$owner" != "ReplicaSet ReplicaSet" ]; then
  echo "FAIL: the scout Pods are not owned by a ReplicaSet: $owner"
  exit 1
fi
echo "PASS: scout runs through a ReplicaSet on scheduled Pods"
