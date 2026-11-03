#!/usr/bin/env bash
# Starting state for the output streams capstone. Environment only.
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-023-capstone-040" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
lab_directory="$(cd "$(dirname "$0")/.." && pwd)"
kubectl apply -f "$lab_directory/bootstrap/manifests/capstone-start.yaml"
kubectl -n starfleet wait --for=condition=Ready pod/probe pod/beacon-logger --timeout=180s
# Bounded wait (about 2 minutes) until crash-report has restarted once.
for attempt in $(seq 1 60); do
  restarts="$(kubectl -n starfleet get pod crash-report -o jsonpath='{.status.containerStatuses[0].restartCount}' 2>/dev/null || true)"
  if [[ "${restarts:-0}" -ge 1 ]]; then exit 0; fi
  sleep 2
done
printf 'crash-report did not restart in time\n' >&2
exit 1
