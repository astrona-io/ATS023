#!/usr/bin/env bash
# Check: shuttle is Available and its init container finished with exit code 0.
set -uo pipefail
fail=0
available="$(kubectl -n starfleet get deployment shuttle -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ "${available:-0}" -lt 1 ]; then echo "FAIL: Deployment shuttle has no available replica"; fail=1; fi
code="$(kubectl -n starfleet get pods -l app=shuttle -o jsonpath='{.items[?(@.status.phase=="Running")].status.initContainerStatuses[0].state.terminated.exitCode}' 2>/dev/null || true)"
if [ "$code" != "0" ]; then echo "FAIL: fetch-config did not finish with exit code 0 (found '$code')"; fail=1; fi
if [ "$fail" -eq 0 ]; then echo "PASS: shuttle is Available and fetch-config finished"; fi
exit "$fail"
