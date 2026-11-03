#!/usr/bin/env bash
# Starting state for the capstone. Environment only: it creates the workloads
# and then introduces four faults. The API server fault comes last, because
# every other step needs the API.
set -euo pipefail

CONTEXT="kind-astro-ats-023-capstone-020"
NODE="astro-ats-023-capstone-020-control-plane"
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

if [ "$(kubectl config current-context)" != "$CONTEXT" ]; then
  echo "Refusing to operate on another Kubernetes context" >&2
  exit 1
fi

kubectl apply -f "$DIR/manifests/lab-start.yaml"
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n starfleet wait --for=condition=Ready pod/shuttle --timeout=120s
kubectl -n outpost wait --for=condition=Ready pod/drifter --timeout=120s

# Fault 1: kube-proxy gets an image tag that does not exist. The DaemonSet
# controller starts the rollout, so this happens before the controller manager breaks.
kubectl -n kube-system set image daemonset/kube-proxy kube-proxy=registry.k8s.io/kube-proxy:v0.0.0-missing
for _ in $(seq 1 24); do
  unavailable="$(kubectl -n kube-system get daemonset kube-proxy -o 'jsonpath={.status.numberUnavailable}' 2>/dev/null || true)"
  if [ -n "$unavailable" ] && [ "$unavailable" != "0" ]; then
    break
  fi
  sleep 5
done

# Faults 2 and 3: scheduler and controller manager manifests. Each edited copy is
# staged outside the manifest directory and moved in one step.
podman exec "$NODE" sh -c '
  cp /etc/kubernetes/manifests/kube-scheduler.yaml /etc/kubernetes/kube-scheduler.yaml.lab-new &&
  sed -i "s#- --kubeconfig=/etc/kubernetes/scheduler.conf#- --kubeconfig=/etc/kubernetes/scheduler-old.conf#" /etc/kubernetes/kube-scheduler.yaml.lab-new &&
  grep -q -- "scheduler-old.conf" /etc/kubernetes/kube-scheduler.yaml.lab-new &&
  mv /etc/kubernetes/kube-scheduler.yaml.lab-new /etc/kubernetes/manifests/kube-scheduler.yaml &&
  cp /etc/kubernetes/manifests/kube-controller-manager.yaml /etc/kubernetes/kube-controller-manager.yaml.lab-new &&
  sed -i "s#^\( *\)- --leader-elect=true\$#&\n\1- --leader-elect-lease-duration=invalid#" /etc/kubernetes/kube-controller-manager.yaml.lab-new &&
  grep -q -- "leader-elect-lease-duration=invalid" /etc/kubernetes/kube-controller-manager.yaml.lab-new &&
  mv /etc/kubernetes/kube-controller-manager.yaml.lab-new /etc/kubernetes/manifests/kube-controller-manager.yaml
'

# Wait (at most 2 minutes) until both Pods are no longer Ready.
for _ in $(seq 1 24); do
  scheduler="$(kubectl -n kube-system get pod -l component=kube-scheduler -o 'jsonpath={.items[0].status.containerStatuses[0].ready}' 2>/dev/null || true)"
  manager="$(kubectl -n kube-system get pod -l component=kube-controller-manager -o 'jsonpath={.items[0].status.containerStatuses[0].ready}' 2>/dev/null || true)"
  if [ "$scheduler" != "true" ] && [ "$manager" != "true" ]; then
    break
  fi
  sleep 5
done

kubectl apply -f "$DIR/manifests/scout.yaml"

# Fault 4: the API server gets a wrong etcd port. This edit needs no API.
podman exec "$NODE" sh -c '
  cp /etc/kubernetes/manifests/kube-apiserver.yaml /etc/kubernetes/kube-apiserver.yaml.lab-new &&
  sed -i "s#--etcd-servers=https://127.0.0.1:2379#--etcd-servers=https://127.0.0.1:2399#" /etc/kubernetes/kube-apiserver.yaml.lab-new &&
  grep -q -- "--etcd-servers=https://127.0.0.1:2399" /etc/kubernetes/kube-apiserver.yaml.lab-new &&
  mv /etc/kubernetes/kube-apiserver.yaml.lab-new /etc/kubernetes/manifests/kube-apiserver.yaml
'
echo "[lab] Four faults are in place."
