#!/usr/bin/env bash
# Starting state for the scheduler lab. Environment only: it creates the
# Starfleet workloads, points the scheduler at a kubeconfig file that does not
# exist, and then creates the scout Deployment, whose Pods stay Pending.
set -euo pipefail

CONTEXT="kind-astro-ats-023-lab-020-03-01"
NODE="astro-ats-023-lab-020-03-01-control-plane"
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
  cp /etc/kubernetes/manifests/kube-scheduler.yaml /etc/kubernetes/kube-scheduler.yaml.lab-new &&
  sed -i "s#- --kubeconfig=/etc/kubernetes/scheduler.conf#- --kubeconfig=/etc/kubernetes/scheduler-old.conf#" /etc/kubernetes/kube-scheduler.yaml.lab-new &&
  grep -q -- "scheduler-old.conf" /etc/kubernetes/kube-scheduler.yaml.lab-new &&
  mv /etc/kubernetes/kube-scheduler.yaml.lab-new /etc/kubernetes/manifests/kube-scheduler.yaml
'

# Wait (at most 2 minutes) until the scheduler Pod is no longer Ready.
for _ in $(seq 1 24); do
  ready="$(kubectl -n kube-system get pod -l component=kube-scheduler -o 'jsonpath={.items[0].status.containerStatuses[0].ready}' 2>/dev/null || true)"
  if [ "$ready" != "true" ]; then
    break
  fi
  sleep 5
done

kubectl apply -f "$DIR/manifests/scout.yaml"
echo "[lab] The scheduler cannot start; scout Pods stay Pending."
