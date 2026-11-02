#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-023-lab-010-01-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
lab_directory="$(cd "$(dirname "$0")/.." && pwd)"
solution_directory="$lab_directory/solution"
node_name="astro-ats-023-lab-010-01-01-control-plane"
worker_name="astro-ats-023-lab-010-01-01-worker"
podman exec "$worker_name" systemctl start kubelet
kubectl apply -f "$solution_directory/configmap-node-recovery.yaml"
kubectl wait --for=condition=Ready node/"$worker_name" --timeout=240s
