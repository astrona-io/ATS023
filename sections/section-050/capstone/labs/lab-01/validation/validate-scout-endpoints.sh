#!/usr/bin/env bash
# Check: the scout Service selects the two scout pods. The Deployment must
# stay as it is: the fix belongs in the Service.
set -uo pipefail

ready="$(kubectl -n starfleet get endpointslices -l kubernetes.io/service-name=scout -o json 2>/dev/null \
  | jq '[.items[].endpoints[]? | select(.conditions.ready == true)] | length' 2>/dev/null)"
label="$(kubectl -n starfleet get deployment scout -o jsonpath='{.spec.template.metadata.labels.app}/{.spec.replicas}' 2>/dev/null)"

fail=0
if [ "${ready:-0}" != "2" ]; then
  echo "FAIL: the scout EndpointSlices hold ${ready:-0} ready endpoints, expected 2"
  fail=1
fi
if [ "$label" != "scout/2" ]; then
  echo "FAIL: the scout Deployment was changed (found '$label', expected scout/2)"
  fail=1
fi
if [ "$fail" -eq 0 ]; then
  echo "PASS: the scout Service has 2 ready endpoints"
fi
exit "$fail"
