#!/usr/bin/env bash
# Check: behaviour. scout still has 2 replicas, both available, all on the worker.
set -uo pipefail

desired="$(kubectl -n starfleet get deployment scout -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
if [ "$desired" != "2" ]; then
  echo "FAIL: Deployment scout has '${desired}' desired replicas (or is missing), expected 2"
  exit 1
fi

available="$(kubectl -n starfleet get deployment scout -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ "${available:-0}" != "2" ]; then
  echo "FAIL: scout has ${available:-0} of 2 replicas available"
  exit 1
fi

worker="$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
other="$(kubectl -n starfleet get pods -l app=scout -o json 2>/dev/null \
  | jq -r --arg w "$worker" '[.items[] | select(.metadata.deletionTimestamp == null) | select(.spec.nodeName != $w)] | length')"
if [ "$other" != "0" ]; then
  echo "FAIL: $other scout Pods are not on $worker"
  exit 1
fi

echo "PASS: 2 scout Pods are available on $worker"
