#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
worker_name="astro-ats-023-capstone-010-worker"

podman exec "${worker_name}" systemctl start kubelet
kubectl wait --for=condition=Ready "node/${worker_name}" --timeout=240s
kubectl -n starfleet patch deployment scout --patch-file "$DIR/scout-patch.yaml"
kubectl -n starfleet patch deployment probe --patch-file "$DIR/probe-patch.yaml"
kubectl -n starfleet rollout status deployment/scout --timeout=180s
kubectl -n starfleet rollout status deployment/probe --timeout=180s
echo "[solution] Applied."
