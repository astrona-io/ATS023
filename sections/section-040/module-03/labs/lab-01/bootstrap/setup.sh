#!/usr/bin/env bash
# Starting state for the node-level logs lab. Environment only.
set -euo pipefail
context="kind-astro-ats-023-lab-040-03-01"
worker="astro-ats-023-lab-040-03-01-worker"
if [[ "$(kubectl config current-context)" != "$context" ]]; then
  printf 'Refusing to operate on another Kubernetes context\n' >&2
  exit 1
fi
lab_directory="$(cd "$(dirname "$0")/.." && pwd)"
kubectl apply -f "$lab_directory/bootstrap/manifests/relay.yaml"
# Random token that the logger prints once; it appears in a node log file.
token="$(od -An -N4 -tx1 /dev/urandom | tr -d ' \n')"
kubectl apply -f - <<MANIFEST
apiVersion: v1
kind: Pod
metadata:
  name: beacon-logger
  namespace: starfleet
spec:
  nodeSelector:
    kubernetes.io/hostname: $worker
  containers:
  - name: logger
    image: docker.io/library/busybox:1.37.0
    env:
    - name: TOKEN
      value: "$token"
    command:
    - sh
    - -c
    - 'echo "beacon: audit token=\$TOKEN"; sleep 3600'
MANIFEST
kubectl -n starfleet wait --for=condition=Ready pod/beacon-logger --timeout=180s
# Bounded wait (about 2 minutes) until the kubelet has reported the pull failure.
for attempt in $(seq 1 60); do
  reason="$(kubectl -n starfleet get pods -l app=relay -o jsonpath='{.items[0].status.containerStatuses[0].state.waiting.reason}' 2>/dev/null || true)"
  if [[ "$reason" == "ErrImagePull" || "$reason" == "ImagePullBackOff" ]]; then exit 0; fi
  sleep 2
done
printf 'relay did not reach an image pull failure in time\n' >&2
exit 1
