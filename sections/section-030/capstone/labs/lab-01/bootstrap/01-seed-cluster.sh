#!/usr/bin/env bash
# Starting state for the capstone. Faults left in place on purpose:
# 1. metrics-server lost its argument --kubelet-insecure-tls (Recreate strategy).
# 2. scout is OOMKilled by its memory limit and the starfleet quota is too small
#    for a larger scout.
# 3. drifter in outpost is rejected by a quota with no LimitRange defaults.
set -euo pipefail

if [[ "$(kubectl config current-context)" != "kind-astro-ats-023-capstone-030" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
kubectl apply -f "$DIR/manifests.yaml"
kubectl -n starfleet rollout status deployment/probe --timeout=180s
kubectl -n kube-system get deployment metrics-server >/dev/null
kubectl wait --for=condition=Available apiservice/v1beta1.metrics.k8s.io --timeout=180s

kubectl -n kube-system get deployment metrics-server -o json | python3 -c '
import json, sys
deployment = json.load(sys.stdin)
container = deployment["spec"]["template"]["spec"]["containers"][0]
container["args"] = [arg for arg in container.get("args", []) if arg != "--kubelet-insecure-tls"]
deployment["spec"]["strategy"] = {"type": "Recreate"}
deployment["metadata"].setdefault("annotations", {})["lab.astrona.io/seeded"] = "true"
json.dump(deployment, sys.stdout)
' | kubectl replace -f -

for attempt in $(seq 1 40); do
  status="$(kubectl get apiservice v1beta1.metrics.k8s.io -o jsonpath='{.status.conditions[?(@.type=="Available")].status}' 2>/dev/null || true)"
  if [[ "$status" != "True" ]]; then
    break
  fi
  sleep 3
done
echo "[lab] Ready."
