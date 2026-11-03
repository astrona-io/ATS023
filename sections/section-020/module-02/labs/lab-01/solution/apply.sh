#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

CONTEXT="kind-astro-ats-023-lab-020-02-01"
NODE="astro-ats-023-lab-020-02-01-control-plane"

if [ "$(kubectl config current-context)" != "$CONTEXT" ]; then
  echo "Refusing to operate on another Kubernetes context" >&2
  exit 1
fi

podman exec "$NODE" sh -c '
  cp /etc/kubernetes/manifests/kube-apiserver.yaml /etc/kubernetes/kube-apiserver.yaml.fixed &&
  sed -i "s#--etcd-servers=https://127.0.0.1:2399#--etcd-servers=https://127.0.0.1:2379#" /etc/kubernetes/kube-apiserver.yaml.fixed &&
  mv /etc/kubernetes/kube-apiserver.yaml.fixed /etc/kubernetes/manifests/kube-apiserver.yaml
'

# The kubelet rescans every 20 seconds and the API server then restarts.
for _ in $(seq 1 48); do
  if [ "$(kubectl get --raw=/readyz 2>/dev/null)" = "ok" ]; then
    break
  fi
  sleep 5
done

kubectl -n starfleet create configmap apiserver-recovery \
  --from-literal=flag=--etcd-servers \
  --from-literal=etcd-client-port=2379 \
  --dry-run=client -o yaml | kubectl apply -f -
echo "[solution] Applied."
