#!/usr/bin/env bash
# Check: GREETING is still read from the ConfigMap probe-config, key greeting.
# A literal value or a new ConfigMap name is a shortcut and fails.
set -uo pipefail

ref="$(kubectl -n starfleet get deployment probe -o json 2>/dev/null \
  | jq -r '.spec.template.spec.containers[0].env // [] | map(select(.name=="GREETING")) | .[0].valueFrom.configMapKeyRef | "\(.name // "none")/\(.key // "none")"')"
if [ "$ref" != "probe-config/greeting" ]; then
  echo "FAIL: GREETING comes from '${ref}', expected configMapKeyRef probe-config/greeting"
  exit 1
fi

echo "PASS: GREETING comes from configMapKeyRef probe-config/greeting"
