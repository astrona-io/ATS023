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

# Check: the scout Deployment has two available replicas that the scheduler placed (no fixed nodeName shortcut).

available() { [ "$(kubectl -n starfleet get deployment scout -o "jsonpath={.status.availableReplicas}" 2>/dev/null)" = "2" ]; }

if ! retry 36 5 available; then
  echo "FAIL: Deployment scout in starfleet does not have two available replicas"
  exit 1
fi
fixed="$(kubectl -n starfleet get deployment scout -o "jsonpath={.spec.template.spec.nodeName}" 2>/dev/null)"
if [ -n "$fixed" ]; then
  echo "FAIL: the scout Deployment sets nodeName=$fixed; the scheduler must choose the node"
  exit 1
fi
other="$(kubectl -n starfleet get deployment scout -o "jsonpath={.spec.template.spec.schedulerName}" 2>/dev/null)"
if [ -n "$other" ] && [ "$other" != "default-scheduler" ]; then
  echo "FAIL: the scout Deployment names the scheduler $other"
  exit 1
fi
unassigned="$(kubectl -n starfleet get pods -l app=scout -o "jsonpath={range .items[*]}{.spec.nodeName}{\"\n\"}{end}" 2>/dev/null | grep -c "^$")"
if [ "$unassigned" -ne 0 ]; then
  echo "FAIL: $unassigned scout Pod(s) have no node"
  exit 1
fi
echo "PASS: both scout Pods were placed by the scheduler and are available"
