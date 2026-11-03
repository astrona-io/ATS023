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

# Check: a fresh Pod gets a node from the scheduler (creates and deletes a throwaway Pod).

cleanup() { kubectl -n starfleet delete pod scheduler-check --ignore-not-found --wait=false >/dev/null 2>&1; }
trap cleanup EXIT

kubectl -n starfleet delete pod scheduler-check --ignore-not-found --wait=true >/dev/null 2>&1
if ! kubectl -n starfleet run scheduler-check --image=docker.io/library/busybox:1.37.0 --restart=Never -- sh -c "sleep 60" >/dev/null 2>&1; then
  echo "FAIL: could not create the Pod scheduler-check"
  exit 1
fi
has_node() { [ -n "$(kubectl -n starfleet get pod scheduler-check -o "jsonpath={.spec.nodeName}" 2>/dev/null)" ]; }
if ! retry 12 5 has_node; then
  echo "FAIL: the new Pod scheduler-check did not get a node within one minute"
  exit 1
fi
echo "PASS: the scheduler assigned a node to a new Pod"
