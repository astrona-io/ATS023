#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-023-lab-030-01-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
lab_directory="$(cd "$(dirname "$0")/.." && pwd)"
solution_directory="$lab_directory/solution"
cluster_name="astro-ats-023-lab-030-01-01"

metric_sample_ready=0
for attempt in $(seq 1 30); do
  metric_sample="$(kubectl get --raw /apis/metrics.k8s.io/v1beta1/namespaces/starfleet/pods)"
  if printf '%s' "$metric_sample" | python3 -c 'import json,sys; items=json.load(sys.stdin).get("items",[]); assert len([item for item in items if item["metadata"]["name"].startswith("probe-")])==2'; then
    metric_sample_ready=1
    break
  fi
  sleep 2
done
test "$metric_sample_ready" -eq 1
kubectl -n starfleet create configmap metric-report --from-literal=namespace=starfleet --from-literal=source=metrics.k8s.io/v1beta1 --from-literal=sampleJson="$metric_sample"

