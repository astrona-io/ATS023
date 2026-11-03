#!/usr/bin/env bash
# Check: the shuttle Deployment is Available and its init container completed with exit code 0.
set -uo pipefail
fail=0
available="$(kubectl -n starfleet get deployment shuttle -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ "${available:-0}" -lt 1 ]; then echo "FAIL: Deployment shuttle has no available replica"; fail=1; fi
exit_code="$(kubectl -n starfleet get pods -l app=shuttle -o jsonpath='{.items[?(@.status.phase=="Running")].status.initContainerStatuses[0].state.terminated.exitCode}' 2>/dev/null || true)"
if [ "$exit_code" != "0" ]; then echo "FAIL: init container fetch-config of the running Pod did not finish with exit code 0 (found '$exit_code')"; fail=1; fi
if [ "$fail" -eq 0 ]; then echo "PASS: shuttle is Available and fetch-config finished with exit code 0"; fi
exit "$fail"
