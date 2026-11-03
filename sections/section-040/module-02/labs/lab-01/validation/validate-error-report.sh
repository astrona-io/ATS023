#!/usr/bin/env bash
# Check: ConfigMap error-report names the failing container and the real error code.
set -uo pipefail
fail=0
container="$(kubectl -n starfleet get configmap error-report -o jsonpath='{.data.container}' 2>/dev/null || true)"
code="$(kubectl -n starfleet get configmap error-report -o jsonpath='{.data.errorCode}' 2>/dev/null || true)"
actual="$(kubectl -n starfleet logs bridge -c worker 2>/dev/null | sed -n 's/.*code=\([A-Z0-9-]*\).*/\1/p' | head -n 1)"
if [ -z "$actual" ]; then echo "FAIL: could not read the worker log of Pod bridge"; exit 1; fi
if [ "$container" != "worker" ]; then echo "FAIL: container must be worker, found '$container'"; fail=1; fi
if [ "$code" != "$actual" ]; then echo "FAIL: errorCode must match the worker log, found '$code'"; fail=1; fi
if [ "$fail" -eq 0 ]; then echo "PASS: error-report records container worker and code $actual"; fi
exit "$fail"
