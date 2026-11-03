#!/usr/bin/env bash
# Check: the worker is Ready, schedulable, and keeps its label and taint.
# Fails on the broken start state (kubelet stopped).
set -uo pipefail

worker="$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
if [ -z "$worker" ]; then
  echo "FAIL: no worker node found"
  exit 1
fi

ready="$(kubectl get node "$worker" -o jsonpath='{.status.conditions[?(@.type=="Ready")].status}' 2>/dev/null || true)"
if [ "$ready" != "True" ]; then
  echo "FAIL: Ready condition of $worker is '${ready}', expected True"
  exit 1
fi

unschedulable="$(kubectl get node "$worker" -o jsonpath='{.spec.unschedulable}' 2>/dev/null || true)"
if [ "$unschedulable" = "true" ]; then
  echo "FAIL: $worker is cordoned"
  exit 1
fi

pool="$(kubectl get node "$worker" -o jsonpath='{.metadata.labels.pool}' 2>/dev/null || true)"
taint="$(kubectl get node "$worker" -o json | jq -r '.spec.taints // [] | map(select(.key=="dedicated" and .value=="survey" and .effect=="NoSchedule")) | length')"
if [ "$pool" != "survey" ] || [ "$taint" != "1" ]; then
  echo "FAIL: $worker must keep label pool=survey and taint dedicated=survey:NoSchedule"
  exit 1
fi

echo "PASS: $worker is Ready and schedulable and keeps its label and taint"
