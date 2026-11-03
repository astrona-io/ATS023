#!/usr/bin/env bash
# Starting state for the failed-workloads playground. Environment only.
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-023-playground-010-03" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
directory="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
kubectl apply -f "${directory}/workloads.yaml"
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet rollout status deployment/scout --timeout=180s
# Second revision of scout: a tag that does not exist. Revision 1 stays good,
# so a rollout undo has something to return to.
kubectl -n starfleet set image deployment/scout scout=docker.io/library/busybox:1.37.99
echo "[playground] Ready."
