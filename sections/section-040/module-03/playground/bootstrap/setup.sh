#!/usr/bin/env bash
# Starting state for the node-level logs playground. Environment only.
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-023-playground-040-03" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
playground_directory="$(cd "$(dirname "$0")/.." && pwd)"
kubectl apply -f "$playground_directory/bootstrap/manifests/start.yaml"
kubectl -n starfleet wait --for=condition=Ready pod/beacon-logger --timeout=180s
kubectl -n starfleet rollout status deployment/scout --timeout=180s
