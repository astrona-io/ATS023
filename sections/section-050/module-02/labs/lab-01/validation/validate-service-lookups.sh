#!/usr/bin/env bash
# Check: Service names resolve from both namespaces, and a short name works.
set -uo pipefail

ip="$(kubectl -n starfleet get service probe -o jsonpath='{.spec.clusterIP}' 2>/dev/null)"
if [ -z "$ip" ]; then
  echo "FAIL: the probe Service was not found in starfleet"
  exit 1
fi
pattern="(^|[^0-9.])${ip//./\\.}([^0-9.]|\$)"

lookup() {
  local namespace="$1" deployment="$2" name="$3" output attempt
  for attempt in 1 2 3 4 5 6 7 8; do
    output="$(kubectl -n "$namespace" exec "deploy/$deployment" -- nslookup "$name" 2>/dev/null)"
    if printf '%s\n' "$output" | grep -Eq "$pattern"; then
      return 0
    fi
    sleep 3
  done
  return 1
}

fail=0
if ! lookup starfleet shuttle probe.starfleet.svc.cluster.local; then
  echo "FAIL: shuttle in starfleet cannot resolve probe.starfleet.svc.cluster.local to $ip"
  fail=1
fi
if ! lookup outpost drifter probe.starfleet.svc.cluster.local; then
  echo "FAIL: drifter in outpost cannot resolve probe.starfleet.svc.cluster.local to $ip"
  fail=1
fi
if ! kubectl -n starfleet exec deploy/shuttle -- wget -q -T 3 -O- http://probe/ 2>/dev/null | grep -q '^version='; then
  echo "FAIL: shuttle cannot fetch http://probe/ with the short Service name"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: Service names resolve from starfleet and outpost, and the short name works"
fi
exit "$fail"
