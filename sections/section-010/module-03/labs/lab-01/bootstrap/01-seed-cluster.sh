#!/usr/bin/env bash
# Starting state for the failing-Deployment lab. Environment only: the learner
# repairs it.
set -euo pipefail

if [[ "$(kubectl config current-context)" != "kind-astro-ats-023-lab-010-03-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"

# Bounded wait: the kubelet must have tried and failed to pull at least once.
for _ in $(seq 1 45); do
  if kubectl -n starfleet get pods -l app=probe -o jsonpath='{.items[*].status.containerStatuses[*].state.waiting.reason}' 2>/dev/null | grep -Eq 'ErrImagePull|ImagePullBackOff'; then
    break
  fi
  sleep 2
done
echo "[lab] Ready."
