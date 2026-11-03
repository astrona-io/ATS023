#!/usr/bin/env bash
# Check: scout has a nodeSelector pair that matches the worker labels and a
# keyed toleration for the dedicated taint. Fails on the broken start state.
set -uo pipefail

selector="$(kubectl -n starfleet get deployment scout -o jsonpath='{.spec.template.spec.nodeSelector.pool}' 2>/dev/null || true)"
if [ "$selector" != "survey" ]; then
  echo "FAIL: scout nodeSelector pool is '${selector}', expected 'survey'"
  exit 1
fi

count="$(kubectl -n starfleet get deployment scout -o json 2>/dev/null | jq '
  [.spec.template.spec.tolerations // [] | .[]
   | select(.key == "dedicated")
   | select((.operator // "Equal") == "Exists" or .value == "survey")
   | select((.effect // "NoSchedule") == "NoSchedule")] | length')"
if [ "${count:-0}" -lt 1 ]; then
  echo "FAIL: scout has no toleration for dedicated=survey:NoSchedule"
  exit 1
fi

echo "PASS: scout selects pool=survey and tolerates dedicated=survey:NoSchedule"
