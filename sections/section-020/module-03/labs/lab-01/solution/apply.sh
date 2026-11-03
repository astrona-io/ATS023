#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

CONTEXT="kind-astro-ats-023-lab-020-03-01"
NODE="astro-ats-023-lab-020-03-01-control-plane"

if [ "$(kubectl config current-context)" != "$CONTEXT" ]; then
  echo "Refusing to operate on another Kubernetes context" >&2
  exit 1
fi

podman exec "$NODE" sh -c '
  cp /etc/kubernetes/manifests/kube-scheduler.yaml /etc/kubernetes/kube-scheduler.yaml.fixed &&
  sed -i "s#scheduler-old.conf#scheduler.conf#" /etc/kubernetes/kube-scheduler.yaml.fixed &&
  mv /etc/kubernetes/kube-scheduler.yaml.fixed /etc/kubernetes/manifests/kube-scheduler.yaml
'
kubectl -n starfleet rollout status deployment/scout --timeout=240s
echo "[solution] Applied."
