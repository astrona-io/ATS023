#!/usr/bin/env bash
# Reference solution. Run only by `astrona test`.
set -euo pipefail

# Make room in the starfleet quota first, then raise the scout limit.
kubectl -n starfleet patch resourcequota compute-quota --type=merge -p '{"spec":{"hard":{"limits.memory":"1Gi"}}}'
kubectl -n starfleet set resources deployment/scout --limits=memory=200Mi
kubectl -n starfleet rollout status deployment/scout --timeout=180s

# Give outpost default requests and limits so the quota can admit drifter.
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
echo "[solution] Applied."
