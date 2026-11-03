#!/usr/bin/env bash
# Reference solution. Run only by `astrona test`.
set -euo pipefail
worker="astro-ats-023-capstone-040-worker"
engine="$(command -v podman || command -v docker)"
log_file="$("$engine" exec "$worker" sh -c 'ls /var/log/pods/starfleet_beacon-logger_*/logger/0.log')"
exit_code="$(kubectl -n starfleet get pod crash-report -o jsonpath='{.status.containerStatuses[0].lastState.terminated.exitCode}')"
code="$(kubectl -n starfleet logs probe -c worker | sed -n 's/.*code=\([A-Z0-9-]*\).*/\1/p' | head -n 1)"
kubectl -n starfleet create configmap incident-report \
  --from-literal=exitCode="$exit_code" \
  --from-literal=workerError="$code" \
  --from-literal=nodeLogFile="$log_file" \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl -n starfleet set env deployment/shuttle -c fetch-config MODE=ready
kubectl -n outpost set image deployment/relay relay=busybox:1.37.0
kubectl -n starfleet rollout status deployment/shuttle --timeout=120s
kubectl -n outpost rollout status deployment/relay --timeout=120s
