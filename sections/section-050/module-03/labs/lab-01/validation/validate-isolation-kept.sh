#!/usr/bin/env bash
# Check: the probe pods are still isolated. Some policy selects them for
# ingress, and no rule allows every source. Rejects deleting the deny policy
# and rules that allow all pods, all namespaces or 0.0.0.0/0.
set -uo pipefail

policies="$(kubectl -n starfleet get networkpolicies -o json 2>/dev/null)"
fail=0

selecting="$(printf '%s' "$policies" | jq '
  [.items[]
   | select((.spec.policyTypes // []) | index("Ingress"))
   | select((.spec.podSelector.matchLabels // {}) as $sel | ($sel == {} or $sel.app == "probe"))
  ] | length' 2>/dev/null)"
if [ "${selecting:-0}" -lt 1 ]; then
  echo "FAIL: no NetworkPolicy with policyType Ingress selects the probe pods any more"
  fail=1
fi

open_rules="$(printf '%s' "$policies" | jq '
  [.items[].spec.ingress[]?
   | select(
       ((.from // []) | length) == 0
       or any(.from[]?; (.ipBlock.cidr // "") == "0.0.0.0/0")
       or any(.from[]?; (.namespaceSelector == {}) and (has("podSelector") | not))
       or any(.from[]?; (.podSelector == {}) and (has("namespaceSelector") | not))
     )
  ] | length' 2>/dev/null)"
if [ "${open_rules:-0}" -gt 0 ]; then
  echo "FAIL: a NetworkPolicy rule allows traffic from every source"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: the probe pods stay isolated and only chosen sources are allowed"
fi
exit "$fail"
