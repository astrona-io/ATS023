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

# Check: the probe Deployment still has two available replicas, shuttle still runs, and the API accepts a write.

probe_available() { [ "$(kubectl -n starfleet get deployment probe -o "jsonpath={.status.availableReplicas}" 2>/dev/null)" = "2" ]; }
write_works() {
  kubectl -n starfleet annotate deployment probe lab.astrona.io/checked-by=grader --overwrite >/dev/null 2>&1
}

if ! retry 36 5 probe_available; then
  echo "FAIL: Deployment probe in starfleet does not have two available replicas"
  exit 1
fi
if [ "$(kubectl -n starfleet get pod shuttle -o "jsonpath={.status.phase}" 2>/dev/null)" != "Running" ]; then
  echo "FAIL: Pod shuttle in starfleet is not Running"
  exit 1
fi
if ! retry 6 5 write_works; then
  echo "FAIL: the API server did not accept a write (annotate on probe)"
  exit 1
fi
echo "PASS: the workloads are intact and the API server accepts writes"
