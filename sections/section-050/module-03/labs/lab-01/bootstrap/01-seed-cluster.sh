#!/usr/bin/env bash
# Starting state for the endpoints and NetworkPolicy lab. Environment only:
# the Service targets port 9090 and a default-deny policy blocks all ingress.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet rollout status deployment/shuttle --timeout=180s
kubectl -n outpost rollout status deployment/drifter --timeout=180s
echo "[lab] Ready."
