#!/usr/bin/env bash
# Check: the scout nodeSelector exists and every pair matches a label of the
# worker. Fails on the broken start state (pool=surveyor).
set -uo pipefail

selector="$(kubectl -n starfleet get deployment scout -o json 2>/dev/null | jq -c '.spec.template.spec.nodeSelector // {}')"
if [ -z "$selector" ] || [ "$selector" = "{}" ]; then
  echo "FAIL: scout has no nodeSelector (or the Deployment is missing); keep a selector and correct it"
  exit 1
fi

worker="$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
labels="$(kubectl get node "$worker" -o json 2>/dev/null | jq -c '.metadata.labels')"

mismatch="$(jq -n --argjson s "$selector" --argjson l "$labels" '[$s | to_entries[] | select($l[.key] != .value) | .key] | join(",")')"
if [ "$mismatch" != '""' ]; then
  echo "FAIL: nodeSelector keys ${mismatch} do not match the labels of $worker"
  exit 1
fi

echo "PASS: nodeSelector $selector matches the labels of $worker"
