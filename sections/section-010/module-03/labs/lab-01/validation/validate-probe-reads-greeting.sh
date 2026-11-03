#!/usr/bin/env bash
# Check: behaviour. A running probe Pod sees GREETING=hello from the ConfigMap.
set -uo pipefail

value="$(kubectl -n starfleet exec deploy/probe -- printenv GREETING 2>/dev/null || true)"
if [ "$value" != "hello" ]; then
  echo "FAIL: GREETING in a probe Pod is '${value}', expected 'hello'"
  exit 1
fi

echo "PASS: GREETING=hello inside a probe Pod"
