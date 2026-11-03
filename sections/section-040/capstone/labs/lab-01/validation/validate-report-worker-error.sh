#!/usr/bin/env bash
# Check: incident-report.workerError equals the code in the worker log of probe.
set -uo pipefail
actual="$(kubectl -n starfleet logs probe -c worker 2>/dev/null | sed -n 's/.*code=\([A-Z0-9-]*\).*/\1/p' | head -n 1)"
value="$(kubectl -n starfleet get configmap incident-report -o jsonpath='{.data.workerError}' 2>/dev/null || true)"
if [ -z "$actual" ]; then echo "FAIL: could not read the worker log of Pod probe"; exit 1; fi
if [ "$value" = "$actual" ]; then echo "PASS: workerError $value matches the worker log"; exit 0; fi
echo "FAIL: workerError must be the code in the worker log (found '$value')"; exit 1
