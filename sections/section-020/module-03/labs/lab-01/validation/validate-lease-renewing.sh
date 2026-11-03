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

# Check: the kube-scheduler Lease has a holder and its renewTime moves forward.

read_renew() { kubectl -n kube-system get lease kube-scheduler -o "jsonpath={.spec.renewTime}" 2>/dev/null; }
have_holder() { [ -n "$(kubectl -n kube-system get lease kube-scheduler -o "jsonpath={.spec.holderIdentity}" 2>/dev/null)" ]; }

if ! retry 24 5 have_holder; then
  echo "FAIL: the Lease kube-scheduler in kube-system has no holderIdentity"
  exit 1
fi
first="$(read_renew)"
moved() { [ "$(read_renew)" != "$first" ]; }
if ! retry 15 2 moved; then
  echo "FAIL: renewTime of the Lease kube-scheduler did not change in 30 seconds"
  exit 1
fi
echo "PASS: the scheduler holds the Lease and renews it"
