#!/usr/bin/env bash
set -euo pipefail
if [[ "$(kubectl config current-context)" != "kind-astro-ats-023-playground-020-01" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
solution_directory="$(cd "$(dirname "$0")" && pwd)"
python3 "$solution_directory/recover-controller.py"
kubectl -n kube-system wait --for=condition=Ready pod/kube-controller-manager-astro-ats-023-playground-020-01-control-plane --timeout=240s
kubectl apply -f "$solution_directory/deployment-probe.yaml"
kubectl -n starfleet rollout status deployment/probe --timeout=180s
