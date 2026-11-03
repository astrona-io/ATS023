#!/usr/bin/env bash
# Starting state for the section capstone. Environment only. Four faults are
# left in place: CoreDNS is scaled to zero, the probe readiness probe checks
# the wrong port, the scout Service selector matches no pod, and the allow
# policy names the Service port instead of the pod port.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n starfleet rollout status deployment/scout --timeout=180s
kubectl -n starfleet rollout status deployment/shuttle --timeout=180s
kubectl -n outpost rollout status deployment/drifter --timeout=180s

kubectl -n kube-system scale deployment/coredns --replicas=0
kubectl -n kube-system wait --for=delete pod -l k8s-app=kube-dns --timeout=90s
echo "[lab] Ready."
