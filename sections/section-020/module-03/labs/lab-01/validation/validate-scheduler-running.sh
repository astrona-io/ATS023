#!/usr/bin/env bash
set -uo pipefail

CONTEXT="kind-astro-ats-023-lab-020-03-01"
NODE="astro-ats-023-lab-020-03-01-control-plane"

if [ "$(kubectl config current-context 2>/dev/null)" != "$CONTEXT" ]; then
  echo "FAIL: kubectl context is not $CONTEXT"
  exit 1
fi

# retry <tries> <seconds> <command...>: run the command until it succeeds.
# The scheduler restarts after a manifest change, so checks wait a bounded
# time instead of failing at once.
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

# Check: the scheduler mirror Pod is Ready and its container runs (waits up to 3 minutes).

scheduler_ready() {
  [ "$(kubectl -n kube-system get pod -l component=kube-scheduler -o "jsonpath={.items[0].status.containerStatuses[0].ready}" 2>/dev/null)" = "true" ]
}
container_running() { node_exec crictl ps --name kube-scheduler --state running -q 2>/dev/null | grep -q .; }

if ! retry 36 5 scheduler_ready; then
  echo "FAIL: the kube-scheduler Pod is not Ready within 3 minutes"
  exit 1
fi
if ! retry 6 5 container_running; then
  echo "FAIL: no running kube-scheduler container on the node"
  exit 1
fi
echo "PASS: the scheduler is Ready and its container is running"
