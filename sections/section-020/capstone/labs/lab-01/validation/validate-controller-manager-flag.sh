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

# Check: the controller manager manifest has no invalid duration flag and the Pod is Ready.

manifest="$(node_exec cat /etc/kubernetes/manifests/kube-controller-manager.yaml 2>/dev/null)"
if printf "%s\n" "$manifest" | grep -q "leader-elect-lease-duration=invalid"; then
  echo "FAIL: kube-controller-manager.yaml still has --leader-elect-lease-duration=invalid"
  exit 1
fi
if ! printf "%s\n" "$manifest" | grep -q -- "--leader-elect=true"; then
  echo "FAIL: leader election is no longer enabled on the controller manager"
  exit 1
fi
if ! retry 36 5 pod_ready kube-controller-manager; then
  echo "FAIL: the kube-controller-manager Pod is not Ready within 3 minutes"
  exit 1
fi
echo "PASS: the controller manager runs without the invalid flag"
