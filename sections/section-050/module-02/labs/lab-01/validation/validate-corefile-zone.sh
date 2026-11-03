#!/usr/bin/env bash
# Check: the Corefile serves the cluster.local zone and keeps its other plugins.
set -uo pipefail

corefile="$(kubectl -n kube-system get configmap coredns -o jsonpath='{.data.Corefile}' 2>/dev/null)"
fail=0

if ! printf '%s\n' "$corefile" | grep -Eq '^[[:space:]]*kubernetes[[:space:]]+cluster\.local([[:space:]]|$)'; then
  echo "FAIL: the kubernetes plugin in the Corefile does not serve the zone cluster.local"
  fail=1
fi
if ! printf '%s\n' "$corefile" | grep -Eq '^[[:space:]]*forward[[:space:]]+\.[[:space:]]+/etc/resolv\.conf'; then
  echo "FAIL: the forward plugin that sends other names to the node resolvers is missing"
  fail=1
fi
if ! printf '%s\n' "$corefile" | grep -Eq '^[[:space:]]*errors[[:space:]]*$'; then
  echo "FAIL: the errors plugin is missing from the Corefile"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: the Corefile serves cluster.local and keeps forward and errors"
fi
exit "$fail"
