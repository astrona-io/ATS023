#!/usr/bin/env bash
# Check: the Metrics API returns metrics for both probe Pods in starfleet.
set -uo pipefail

for attempt in $(seq 1 30); do
  response="$(kubectl get --raw /apis/metrics.k8s.io/v1beta1/namespaces/starfleet/pods 2>/dev/null)"
  if [[ -n "$response" ]] && printf '%s' "$response" | python3 -c '
import json, sys
items = json.load(sys.stdin).get("items", [])
names = [item["metadata"]["name"] for item in items if item["metadata"]["name"].startswith("probe-")]
sys.exit(0 if len(names) == 2 else 1)
' 2>/dev/null; then
    echo "PASS: metrics returned for both probe Pods"
    exit 0
  fi
  sleep 4
done
echo "FAIL: the Metrics API does not return metrics for two probe Pods"
exit 1
