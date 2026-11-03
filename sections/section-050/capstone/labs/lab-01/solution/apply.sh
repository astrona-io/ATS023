#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl -n kube-system scale deployment/coredns --replicas=2
kubectl -n kube-system rollout status deployment/coredns --timeout=120s
kubectl -n starfleet patch deployment probe --type=json \
  -p='[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/port","value":"http"}]'
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl apply -f "$DIR/solution.yaml"
echo "[solution] Applied."
