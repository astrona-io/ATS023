#!/usr/bin/env bash
# Starting state for the scheduling playground. Environment only.
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-023-playground-010-02" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
worker_name="astro-ats-023-playground-010-02-worker"
kubectl wait --for=condition=Ready "node/${worker_name}" --timeout=180s
kubectl label node "${worker_name}" pool=survey --overwrite
kubectl apply -f "${directory}/workloads.yaml"
kubectl -n starfleet rollout status deployment/scout --timeout=180s
kubectl -n starfleet rollout status deployment/bridge --timeout=180s
kubectl -n outpost rollout status deployment/drifter --timeout=180s
echo "[playground] Ready."
