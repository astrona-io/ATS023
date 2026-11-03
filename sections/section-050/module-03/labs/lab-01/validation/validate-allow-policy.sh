#!/usr/bin/env bash
# Check: a NetworkPolicy allows ingress to the probe pods from the shuttle pods
# on TCP port 8080, the port the container listens on.
set -uo pipefail

policies="$(kubectl -n starfleet get networkpolicies -o json 2>/dev/null)"
count="$(printf '%s' "$policies" | jq '
  [.items[]
   | select((.spec.policyTypes // []) | index("Ingress"))
   | select((.spec.podSelector.matchLabels // {}) as $sel | ($sel == {} or $sel.app == "probe"))
   | .spec.ingress[]?
   | select(any(.from[]?; .podSelector.matchLabels.app == "shuttle"))
   | select((.ports // []) | any(.port == 8080 and ((.protocol // "TCP") == "TCP")))
  ] | length' 2>/dev/null)"

if [ "${count:-0}" -ge 1 ]; then
  echo "PASS: a NetworkPolicy allows shuttle to reach the probe pods on TCP 8080"
  exit 0
fi
echo "FAIL: no NetworkPolicy allows the shuttle pods to reach the probe pods on TCP 8080"
exit 1
