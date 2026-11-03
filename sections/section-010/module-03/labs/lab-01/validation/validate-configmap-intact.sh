#!/usr/bin/env bash
# Check: the ConfigMap probe-config still exists with greeting=hello. The fault
# is in the Deployment; changing the ConfigMap is a shortcut.
set -uo pipefail

value="$(kubectl -n starfleet get configmap probe-config -o jsonpath='{.data.greeting}' 2>/dev/null || true)"
if [ "$value" != "hello" ]; then
  echo "FAIL: ConfigMap probe-config has greeting='${value}', expected 'hello'"
  exit 1
fi

echo "PASS: ConfigMap probe-config still has greeting=hello"
