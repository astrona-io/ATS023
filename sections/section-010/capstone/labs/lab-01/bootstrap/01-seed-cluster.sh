#!/usr/bin/env bash
# Starting state for the capstone. Environment only: the learner repairs it.
set -euo pipefail

if [[ "$(kubectl config current-context)" != "kind-astro-ats-023-capstone-010" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
worker_name="astro-ats-023-capstone-010-worker"

kubectl wait --for=condition=Ready "node/${worker_name}" --timeout=180s
kubectl label node "${worker_name}" pool=survey --overwrite
kubectl taint node "${worker_name}" dedicated=survey:NoSchedule --overwrite
kubectl apply -f "$DIR/manifests/lab-start.yaml"

# Stop the kubelet on the worker node container of this environment only.
podman exec "${worker_name}" systemctl stop kubelet
kubectl wait --for=jsonpath='{.status.conditions[?(@.type=="Ready")].status}'=Unknown "node/${worker_name}" --timeout=180s
echo "[lab] Ready."
