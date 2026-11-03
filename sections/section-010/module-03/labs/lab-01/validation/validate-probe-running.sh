#!/usr/bin/env bash
# Check: the Deployment still has 2 replicas, both available, and no Pod has a
# waiting container. Fails on the broken start state.
set -uo pipefail

desired="$(kubectl -n starfleet get deployment probe -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
if [ "$desired" != "2" ]; then
  echo "FAIL: Deployment probe has '${desired}' desired replicas (or is missing), expected 2"
  exit 1
fi

available="$(kubectl -n starfleet get deployment probe -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ "${available:-0}" != "2" ]; then
  echo "FAIL: probe has ${available:-0} of 2 replicas available"
  exit 1
fi

waiting="$(kubectl -n starfleet get pods -l app=probe -o json 2>/dev/null \
  | jq -r '[.items[] | select(.metadata.deletionTimestamp == null) | .status.containerStatuses[]? | select(.state.waiting != null) | .state.waiting.reason] | join(",")')"
if [ -n "$waiting" ]; then
  echo "FAIL: some probe containers are waiting: ${waiting}"
  exit 1
fi

echo "PASS: 2 of 2 probe replicas are available and none is waiting"
