#!/usr/bin/env bash
# Check: incident-report.exitCode equals the last terminated exit code of crash-report.
set -uo pipefail
actual="$(kubectl -n starfleet get pod crash-report -o jsonpath='{.status.containerStatuses[0].lastState.terminated.exitCode}' 2>/dev/null || true)"
value="$(kubectl -n starfleet get configmap incident-report -o jsonpath='{.data.exitCode}' 2>/dev/null || true)"
if [ -z "$actual" ]; then echo "FAIL: Pod crash-report has no terminated instance (was it deleted?)"; exit 1; fi
if [ "$value" = "$actual" ]; then echo "PASS: exitCode $value matches the last terminated instance"; exit 0; fi
echo "FAIL: exitCode must be $actual (found '$value')"; exit 1
