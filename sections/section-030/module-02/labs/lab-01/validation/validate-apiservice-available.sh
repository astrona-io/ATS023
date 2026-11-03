#!/usr/bin/env bash
# Check: the APIService v1beta1.metrics.k8s.io has Available=True.
set -uo pipefail

for attempt in $(seq 1 20); do
  status="$(kubectl get apiservice v1beta1.metrics.k8s.io -o jsonpath='{.status.conditions[?(@.type=="Available")].status}' 2>/dev/null)"
  if [[ "$status" == "True" ]]; then
    echo "PASS: APIService v1beta1.metrics.k8s.io is Available"
    exit 0
  fi
  sleep 3
done
echo "FAIL: APIService v1beta1.metrics.k8s.io is not Available (status: ${status:-unknown})"
exit 1
