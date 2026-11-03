#!/usr/bin/env bash
# Reference solution. Run only by `astrona test`.
set -euo pipefail
worker="astro-ats-023-lab-040-03-01-worker"
engine="$(command -v podman || command -v docker)"
log_file="$("$engine" exec "$worker" sh -c 'ls /var/log/pods/starfleet_beacon-logger_*/logger/0.log')"
token="$("$engine" exec "$worker" cat "$log_file" | sed -n 's/.*token=\([0-9a-f]*\).*/\1/p' | head -n 1)"
kubectl -n starfleet create configmap node-log-evidence \
  --from-literal=token="$token" \
  --from-literal=logFile="$log_file" \
  --from-literal=failedImage=busybox:1.37.99 \
  --dry-run=client -o yaml | kubectl apply -f -
kubectl -n starfleet set image deployment/relay relay=busybox:1.37.0
kubectl -n starfleet rollout status deployment/relay --timeout=120s
