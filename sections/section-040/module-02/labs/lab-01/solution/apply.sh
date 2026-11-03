#!/usr/bin/env bash
# Reference solution. Run only by `astrona test`.
set -euo pipefail
kubectl -n starfleet create configmap error-report --from-literal=container=worker --from-literal=errorCode=E-5290 --dry-run=client -o yaml | kubectl apply -f -
kubectl -n starfleet set env deployment/shuttle -c fetch-config MODE=ready
kubectl -n starfleet rollout status deployment/shuttle --timeout=120s
