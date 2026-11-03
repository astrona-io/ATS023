#!/usr/bin/env bash
# Check: the pods stay isolated. Policies allow shuttle on pod port 8080 to
# probe and to scout, a deny policy still selects both, and no rule opens
# ingress to every source.
set -uo pipefail

policies="$(kubectl -n starfleet get networkpolicies -o json 2>/dev/null)"
fail=0

allowed_for() {
  printf '%s' "$policies" | jq --arg app "$1" '
    [.items[]
     | select((.spec.policyTypes // []) | index("Ingress"))
     | select(
         ((.spec.podSelector.matchLabels // {}) as $sel | $sel.app == $ARGS.named.app)
         or ((.spec.podSelector.matchExpressions // []) | any(.key == "app" and .operator == "In" and (.values | index($ARGS.named.app))))
       )
     | .spec.ingress[]?
     | select(any(.from[]?; .podSelector.matchLabels.app == "shuttle"))
     | select((.ports // []) | any(.port == 8080 and ((.protocol // "TCP") == "TCP")))
    ] | length' 2>/dev/null
}
for app in probe scout; do
  if [ "$(allowed_for "$app")" -lt 1 ] 2>/dev/null; then
    echo "FAIL: no NetworkPolicy allows shuttle to reach the $app pods on TCP 8080"
    fail=1
  fi
done

denies="$(printf '%s' "$policies" | jq '
  [.items[]
   | select((.spec.policyTypes // []) | index("Ingress"))
   | select((.spec.podSelector.matchLabels // {}) == {} and ((.spec.podSelector.matchExpressions // []) | length) == 0)
  ] | length' 2>/dev/null)"
if [ "${denies:-0}" -lt 1 ]; then
  echo "FAIL: the default-deny ingress policy for all pods in starfleet was removed"
  fail=1
fi

open_rules="$(printf '%s' "$policies" | jq '
  [.items[].spec.ingress[]?
   | select(
       ((.from // []) | length) == 0
       or any(.from[]?; (.ipBlock.cidr // "") == "0.0.0.0/0")
       or any(.from[]?; has("namespaceSelector"))
       or any(.from[]?; (.podSelector == {}) and (has("namespaceSelector") | not))
     )
  ] | length' 2>/dev/null)"
if [ "${open_rules:-0}" -gt 0 ]; then
  echo "FAIL: a NetworkPolicy rule allows ingress from every source or from another namespace"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: only shuttle is allowed, on port 8080, and the deny policy remains"
fi
exit "$fail"
