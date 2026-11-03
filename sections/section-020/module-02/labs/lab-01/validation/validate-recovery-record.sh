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

# Check: the ConfigMap apiserver-recovery in starfleet records the flag that was wrong and the etcd client port.

read_key() { kubectl -n starfleet get configmap apiserver-recovery -o "jsonpath={.data.$1}" 2>/dev/null; }
have_record() { [ -n "$(read_key flag)" ]; }

if ! retry 12 5 have_record; then
  echo "FAIL: ConfigMap apiserver-recovery does not exist in starfleet"
  exit 1
fi
fail=0
if [ "$(read_key flag)" != "--etcd-servers" ]; then
  echo "FAIL: key flag must be --etcd-servers, found: $(read_key flag)"
  fail=1
fi
if [ "$(read_key etcd-client-port)" != "2379" ]; then
  echo "FAIL: key etcd-client-port must be 2379, found: $(read_key etcd-client-port)"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: apiserver-recovery records the flag and the etcd client port"
fi
exit "$fail"
