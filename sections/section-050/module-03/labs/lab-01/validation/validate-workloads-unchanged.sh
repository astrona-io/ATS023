#!/usr/bin/env bash
# Check: the fix did not delete or reshape the workloads.
set -uo pipefail

fail=0
replicas="$(kubectl -n starfleet get deployment probe -o jsonpath='{.spec.replicas}' 2>/dev/null)"
if [ "${replicas:-}" != "2" ]; then
  echo "FAIL: the probe Deployment does not have 2 replicas"
  fail=1
fi
type="$(kubectl -n starfleet get service probe -o jsonpath='{.spec.type}/{.spec.ports[0].port}/{.spec.selector.app}' 2>/dev/null)"
if [ "$type" != "ClusterIP/80/probe" ]; then
  echo "FAIL: the probe Service is not a ClusterIP Service on port 80 selecting app=probe (found '$type')"
  fail=1
fi
for item in "starfleet shuttle" "outpost drifter"; do
  set -- $item
  if ! kubectl -n "$1" get deployment "$2" >/dev/null 2>&1; then
    echo "FAIL: the $2 Deployment in $1 was removed"
    fail=1
  fi
done
if [ "$fail" -eq 0 ]; then
  echo "PASS: probe, shuttle and drifter are still in place"
fi
exit "$fail"
