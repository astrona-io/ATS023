#!/usr/bin/env bash
# Starting state for the quota lab. Three faults are left in place on purpose:
# scout is OOMKilled by its memory limit, the starfleet quota is too small for
# a larger scout limit, and drifter in outpost is rejected by a quota without
# a LimitRange.
set -euo pipefail

if [[ "$(kubectl config current-context)" != "kind-astro-ats-023-lab-030-03-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
kubectl apply -f "$DIR/manifests.yaml"
kubectl -n starfleet rollout status deployment/probe --timeout=180s
echo "[lab] Ready."
