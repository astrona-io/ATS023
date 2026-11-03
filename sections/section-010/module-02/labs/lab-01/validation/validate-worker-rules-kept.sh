#!/usr/bin/env bash
# Check: the worker keeps its label and its taint and is not cordoned. A
# learner who removes the taint or cordons the node took a shortcut.
set -uo pipefail

worker="$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
if [ -z "$worker" ]; then
  echo "FAIL: no worker node found"
  exit 1
fi

pool="$(kubectl get node "$worker" -o jsonpath='{.metadata.labels.pool}' 2>/dev/null || true)"
if [ "$pool" != "survey" ]; then
  echo "FAIL: label pool on $worker is '${pool}', expected 'survey'"
  exit 1
fi

taint="$(kubectl get node "$worker" -o json | jq -r '.spec.taints // [] | map(select(.key=="dedicated" and .value=="survey" and .effect=="NoSchedule")) | length')"
if [ "$taint" != "1" ]; then
  echo "FAIL: taint dedicated=survey:NoSchedule is missing from $worker"
  exit 1
fi

unschedulable="$(kubectl get node "$worker" -o jsonpath='{.spec.unschedulable}' 2>/dev/null || true)"
if [ "$unschedulable" = "true" ]; then
  echo "FAIL: $worker is cordoned"
  exit 1
fi

echo "PASS: $worker keeps label pool=survey and taint dedicated=survey:NoSchedule and is schedulable"
