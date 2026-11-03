#!/usr/bin/env bash
# Starting state for the cluster DNS lab. Environment only: it creates the
# workloads, then breaks cluster DNS. It does not fix anything.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet rollout status deployment/shuttle --timeout=180s
kubectl -n outpost rollout status deployment/drifter --timeout=180s

# Fault 1: the Corefile names a cluster domain that does not exist.
kubectl apply -f "$DIR/manifests/corefile-broken.yaml"
# Fault 2: CoreDNS is scaled down.
kubectl -n kube-system scale deployment/coredns --replicas=0
kubectl -n kube-system wait --for=delete pod -l k8s-app=kube-dns --timeout=90s
echo "[lab] Ready."
