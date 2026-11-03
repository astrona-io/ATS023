#!/usr/bin/env bash
# Check: the probe Service forwards to the port the containers listen on, and
# its EndpointSlices hold two ready endpoints on that port.
set -uo pipefail

slices="$(kubectl -n starfleet get endpointslices -l kubernetes.io/service-name=probe -o json 2>/dev/null)"
ready="$(printf '%s' "$slices" | jq '[.items[].endpoints[]? | select(.conditions.ready == true)] | length' 2>/dev/null)"
ports="$(printf '%s' "$slices" | jq -r '[.items[].ports[]?.port] | unique | map(tostring) | join(",")' 2>/dev/null)"

fail=0
if [ "${ready:-0}" != "2" ]; then
  echo "FAIL: the probe EndpointSlices hold ${ready:-0} ready endpoints, expected 2"
  fail=1
fi
if [ "$ports" != "8080" ]; then
  echo "FAIL: the probe EndpointSlices list the port(s) '${ports}', expected 8080"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: probe has 2 ready endpoints on port 8080"
fi
exit "$fail"
