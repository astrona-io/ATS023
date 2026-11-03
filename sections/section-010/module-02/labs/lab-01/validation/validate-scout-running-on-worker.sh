#!/usr/bin/env bash
# Check: behaviour. The Deployment still has 2 replicas, both are Ready, and
# every scout Pod runs on the worker. Fails on the broken start state.
set -uo pipefail

desired="$(kubectl -n starfleet get deployment scout -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
if [ "$desired" != "2" ]; then
  echo "FAIL: Deployment scout has '${desired}' desired replicas (or is missing), expected 2"
  exit 1
fi

worker="$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"

ready=0
elsewhere=0
while read -r node phase; do
  [ -z "$node" ] && continue
  if [ "$node" != "$worker" ]; then elsewhere=$((elsewhere + 1)); fi
  if [ "$phase" = "Running" ] && [ "$node" = "$worker" ]; then ready=$((ready + 1)); fi
done < <(kubectl -n starfleet get pods -l app=scout -o json 2>/dev/null \
  | jq -r '.items[] | select(.metadata.deletionTimestamp == null) | "\(.spec.nodeName // "none") \(.status.phase)"')

available="$(kubectl -n starfleet get deployment scout -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ "${available:-0}" != "2" ]; then
  echo "FAIL: scout has ${available:-0} of 2 replicas available"
  exit 1
fi
if [ "$elsewhere" -ne 0 ] || [ "$ready" -lt 2 ]; then
  echo "FAIL: expected 2 Running scout Pods on $worker, found $ready there and $elsewhere elsewhere or unplaced"
  exit 1
fi

echo "PASS: 2 scout Pods are Running and Ready on $worker"
