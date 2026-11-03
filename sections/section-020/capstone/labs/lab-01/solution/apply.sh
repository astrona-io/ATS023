#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

CONTEXT="kind-astro-ats-023-capstone-020"
NODE="astro-ats-023-capstone-020-control-plane"

if [ "$(kubectl config current-context)" != "$CONTEXT" ]; then
  echo "Refusing to operate on another Kubernetes context" >&2
  exit 1
fi

# Fix the API server first: nothing else can be done through the API before.
podman exec "$NODE" sh -c '
  cp /etc/kubernetes/manifests/kube-apiserver.yaml /etc/kubernetes/kube-apiserver.yaml.fixed &&
  sed -i "s#127.0.0.1:2399#127.0.0.1:2379#" /etc/kubernetes/kube-apiserver.yaml.fixed &&
  mv /etc/kubernetes/kube-apiserver.yaml.fixed /etc/kubernetes/manifests/kube-apiserver.yaml
'
for _ in $(seq 1 48); do
  if [ "$(kubectl get --raw=/readyz 2>/dev/null)" = "ok" ]; then
    break
  fi
  sleep 5
done

podman exec "$NODE" sh -c '
  cp /etc/kubernetes/manifests/kube-controller-manager.yaml /etc/kubernetes/kube-controller-manager.yaml.fixed &&
  sed -i "/leader-elect-lease-duration=invalid/d" /etc/kubernetes/kube-controller-manager.yaml.fixed &&
  mv /etc/kubernetes/kube-controller-manager.yaml.fixed /etc/kubernetes/manifests/kube-controller-manager.yaml &&
  cp /etc/kubernetes/manifests/kube-scheduler.yaml /etc/kubernetes/kube-scheduler.yaml.fixed &&
  sed -i "s#scheduler-old.conf#scheduler.conf#" /etc/kubernetes/kube-scheduler.yaml.fixed &&
  mv /etc/kubernetes/kube-scheduler.yaml.fixed /etc/kubernetes/manifests/kube-scheduler.yaml
'

kubectl -n kube-system rollout undo daemonset/kube-proxy
kubectl -n kube-system rollout status daemonset/kube-proxy --timeout=240s
kubectl -n starfleet rollout status deployment/scout --timeout=240s
echo "[solution] Applied."
