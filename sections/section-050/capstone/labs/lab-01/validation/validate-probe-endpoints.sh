#!/usr/bin/env bash
# Check: probe has two ready endpoints and still has a readiness probe on the
# container port. Rejects removing the readiness probe.
set -uo pipefail

ready="$(kubectl -n starfleet get endpointslices -l kubernetes.io/service-name=probe -o json 2>/dev/null \
  | jq '[.items[].endpoints[]? | select(.conditions.ready == true)] | length' 2>/dev/null)"
port="$(kubectl -n starfleet get deployment probe -o jsonpath='{.spec.template.spec.containers[0].readinessProbe.httpGet.port}' 2>/dev/null)"

fail=0
if [ "${ready:-0}" != "2" ]; then
  echo "FAIL: the probe EndpointSlices hold ${ready:-0} ready endpoints, expected 2"
  fail=1
fi
if [ "$port" != "http" ] && [ "$port" != "8080" ]; then
  echo "FAIL: the probe readiness probe must check the container port (http or 8080), found '${port:-none}'"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: probe has 2 ready endpoints and a readiness probe on its container port"
fi
exit "$fail"
