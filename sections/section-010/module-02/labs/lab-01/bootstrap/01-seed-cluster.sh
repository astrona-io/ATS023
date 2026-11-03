#!/usr/bin/env bash
# Starting state for the Pending Pods lab. Environment only: the learner
# repairs it.
set -euo pipefail

if [[ "$(kubectl config current-context)" != "kind-astro-ats-023-lab-010-02-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
worker_name="astro-ats-023-lab-010-02-01-worker"

kubectl wait --for=condition=Ready "node/${worker_name}" --timeout=180s
kubectl label node "${worker_name}" pool=survey --overwrite
kubectl taint node "${worker_name}" dedicated=survey:NoSchedule --overwrite
kubectl apply -f "$DIR/manifests/lab-start.yaml"

# Bounded wait: the scheduler must have tried and failed at least once.
for _ in $(seq 1 30); do
  if kubectl -n starfleet get events --field-selector reason=FailedScheduling -o name 2>/dev/null | grep -q .; then
    break
  fi
  sleep 2
done
echo "[lab] Ready."
