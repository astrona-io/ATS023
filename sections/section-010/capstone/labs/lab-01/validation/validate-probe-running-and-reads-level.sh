#!/usr/bin/env bash
# Check: behaviour. probe has 2 available replicas, no waiting container, and a
# Pod sees LEVEL=high.
set -uo pipefail

desired="$(kubectl -n starfleet get deployment probe -o jsonpath='{.spec.replicas}' 2>/dev/null || true)"
available="$(kubectl -n starfleet get deployment probe -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ "$desired" != "2" ] || [ "${available:-0}" != "2" ]; then
  echo "FAIL: probe has ${available:-0} available of '${desired}' desired replicas, expected 2 of 2"
  exit 1
fi

value="$(kubectl -n starfleet exec deploy/probe -- printenv LEVEL 2>/dev/null || true)"
if [ "$value" != "high" ]; then
  echo "FAIL: LEVEL in a probe Pod is '${value}', expected 'high'"
  exit 1
fi

echo "PASS: 2 of 2 probe replicas are available and LEVEL=high"
