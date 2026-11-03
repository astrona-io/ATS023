#!/usr/bin/env bash
# Check: the fix did not bypass cluster DNS or remove the workloads.
set -uo pipefail

fail=0
kube_dns_ip="$(kubectl -n kube-system get service kube-dns -o jsonpath='{.spec.clusterIP}' 2>/dev/null)"
if [ -z "$kube_dns_ip" ]; then
  echo "FAIL: the kube-dns Service in kube-system was removed"
  exit 1
fi

for target in "starfleet shuttle" "outpost drifter"; do
  set -- $target
  policy="$(kubectl -n "$1" get deployment "$2" -o jsonpath='{.spec.template.spec.dnsPolicy}' 2>/dev/null)"
  config="$(kubectl -n "$1" get deployment "$2" -o jsonpath='{.spec.template.spec.dnsConfig}' 2>/dev/null)"
  if { [ -n "$policy" ] && [ "$policy" != "ClusterFirst" ]; } || [ -n "$config" ]; then
    echo "FAIL: the $2 Deployment overrides dnsPolicy or dnsConfig"
    fail=1
  fi
  if ! kubectl -n "$1" exec "deploy/$2" -- cat /etc/resolv.conf 2>/dev/null | grep -Eq "^nameserver[[:space:]]+${kube_dns_ip//./\\.}\$"; then
    echo "FAIL: $2 does not use the kube-dns Service address $kube_dns_ip as its nameserver"
    fail=1
  fi
done

replicas="$(kubectl -n starfleet get deployment probe -o jsonpath='{.spec.replicas}' 2>/dev/null)"
if [ "${replicas:-}" != "2" ]; then
  echo "FAIL: the probe Deployment was removed or changed"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: pods still use the kube-dns Service and the workloads are unchanged"
fi
exit "$fail"
