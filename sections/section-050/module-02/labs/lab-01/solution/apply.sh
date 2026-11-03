#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl apply -f "$DIR/corefile-fixed.yaml"
kubectl -n kube-system scale deployment/coredns --replicas=2
kubectl -n kube-system rollout status deployment/coredns --timeout=120s
echo "[solution] Applied."
