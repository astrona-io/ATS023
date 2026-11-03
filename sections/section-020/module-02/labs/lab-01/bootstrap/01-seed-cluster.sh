#!/usr/bin/env bash
# Starting state for the API server lab. Environment only: it creates the
# Starfleet workloads, then breaks the etcd client address in the API server
# manifest. The last step needs no API: it edits a file on the node.
set -euo pipefail

CONTEXT="kind-astro-ats-023-lab-020-02-01"
NODE="astro-ats-023-lab-020-02-01-control-plane"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ "$(kubectl config current-context)" != "$CONTEXT" ]; then
  echo "Refusing to operate on another Kubernetes context" >&2
  exit 1
fi

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet wait --for=condition=Ready pod/shuttle --timeout=120s
kubectl -n outpost wait --for=condition=Ready pod/drifter --timeout=120s

# Stage the edited copy outside the manifest directory, then move it in one step.
podman exec "$NODE" sh -c '
  cp /etc/kubernetes/manifests/kube-apiserver.yaml /etc/kubernetes/kube-apiserver.yaml.lab-new &&
  sed -i "s#--etcd-servers=https://127.0.0.1:2379#--etcd-servers=https://127.0.0.1:2399#" /etc/kubernetes/kube-apiserver.yaml.lab-new &&
  grep -q -- "--etcd-servers=https://127.0.0.1:2399" /etc/kubernetes/kube-apiserver.yaml.lab-new &&
  mv /etc/kubernetes/kube-apiserver.yaml.lab-new /etc/kubernetes/manifests/kube-apiserver.yaml
'
echo "[lab] The API server manifest now has a wrong etcd port."
