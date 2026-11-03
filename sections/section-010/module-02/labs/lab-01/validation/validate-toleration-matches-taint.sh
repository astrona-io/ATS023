#!/usr/bin/env bash
# Check: the scout Pod template has a toleration for dedicated=survey with the
# NoSchedule effect (or no effect). A toleration without a key, which tolerates
# everything, does not count.
set -uo pipefail

count="$(kubectl -n starfleet get deployment scout -o json 2>/dev/null | jq '
  [.spec.template.spec.tolerations // [] | .[]
   | select(.key == "dedicated")
   | select((.operator // "Equal") == "Exists" or .value == "survey")
   | select((.effect // "NoSchedule") == "NoSchedule")] | length')"
if [ "${count:-0}" -lt 1 ]; then
  echo "FAIL: the scout Pod template has no toleration for dedicated=survey:NoSchedule"
  exit 1
fi

echo "PASS: the scout Pod template tolerates dedicated=survey:NoSchedule"
