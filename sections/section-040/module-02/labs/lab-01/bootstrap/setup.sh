#!/usr/bin/env bash
# Starting state for the multi-container logs lab. Environment only.
set -euo pipefail
context="kind-astro-ats-023-lab-040-02-01"
if [[ "$(kubectl config current-context)" != "$context" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
lab_directory="$(cd "$(dirname "$0")/.." && pwd)"
kubectl apply -f "$lab_directory/manifests/lab-start.yaml"
kubectl -n starfleet wait --for=condition=Ready pod/bridge --timeout=180s
# Bounded wait (about 2 minutes) until the init container has failed once.
for attempt in $(seq 1 60); do
  restarts="$(kubectl -n starfleet get pods -l app=shuttle -o jsonpath='{.items[0].status.initContainerStatuses[0].restartCount}' 2>/dev/null || true)"
  if [[ "${restarts:-0}" -ge 1 ]]; then exit 0; fi
  sleep 2
done
printf 'init container did not fail in time\n' >&2
exit 1
