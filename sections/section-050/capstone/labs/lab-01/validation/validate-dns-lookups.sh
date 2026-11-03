#!/usr/bin/env bash
# Check: the fully qualified names of both Services resolve from shuttle.
set -uo pipefail

fail=0
for name in probe scout; do
  ip="$(kubectl -n starfleet get service "$name" -o jsonpath='{.spec.clusterIP}' 2>/dev/null)"
  if [ -z "$ip" ]; then
    echo "FAIL: the $name Service was not found in starfleet"
    fail=1
    continue
  fi
  pattern="(^|[^0-9.])${ip//./\\.}([^0-9.]|\$)"
  found=1
  for attempt in 1 2 3 4 5 6 7 8; do
    if kubectl -n starfleet exec deploy/shuttle -- nslookup "$name.starfleet.svc.cluster.local" 2>/dev/null | grep -Eq "$pattern"; then
      found=0
      break
    fi
    sleep 3
  done
  if [ "$found" -ne 0 ]; then
    echo "FAIL: shuttle cannot resolve $name.starfleet.svc.cluster.local to $ip"
    fail=1
  fi
done
if [ "$fail" -eq 0 ]; then
  echo "PASS: both Service names resolve from shuttle"
fi
exit "$fail"
