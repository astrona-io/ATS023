#!/usr/bin/env bash
# Reference solution. Run only by `astrona test`.
set -euo pipefail

kubectl -n kube-system patch deployment metrics-server --type=json \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
kubectl -n kube-system rollout status deployment/metrics-server --timeout=180s
kubectl wait --for=condition=Available apiservice/v1beta1.metrics.k8s.io --timeout=180s

kubectl -n starfleet patch resourcequota compute-quota --type=merge -p '{"spec":{"hard":{"limits.memory":"1Gi"}}}'
kubectl -n starfleet set resources deployment/scout --limits=memory=200Mi
kubectl -n starfleet rollout status deployment/scout --timeout=180s

kubectl apply -f - <<'YAML'
apiVersion: v1
kind: LimitRange
metadata:
  name: container-defaults
  namespace: outpost
spec:
  limits:
  - type: Container
    default:
      memory: 64Mi
    defaultRequest:
      memory: 32Mi
YAML
kubectl -n outpost rollout restart deployment/drifter
kubectl -n outpost rollout status deployment/drifter --timeout=180s

sample_ready=0
for attempt in $(seq 1 40); do
  sample="$(kubectl get --raw /apis/metrics.k8s.io/v1beta1/namespaces/starfleet/pods 2>/dev/null || true)"
  if [[ -n "$sample" ]] && printf '%s' "$sample" | python3 -c '
import json, sys
names = [item["metadata"]["name"] for item in json.load(sys.stdin).get("items", [])]
sys.exit(0 if len([n for n in names if n.startswith("probe-")]) == 2 and len([n for n in names if n.startswith("scout-")]) == 2 else 1)
'; then
    sample_ready=1
    break
  fi
  sleep 3
done
test "$sample_ready" -eq 1
kubectl -n starfleet create configmap usage-report \
  --from-literal=source=metrics.k8s.io/v1beta1 \
  --from-literal=podMetricsJson="$sample"
echo "[solution] Applied."
