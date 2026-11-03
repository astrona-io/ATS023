#!/usr/bin/env bash
# Check: relay uses busybox:1.37.0 and has an available replica.
set -uo pipefail
fail=0
image="$(kubectl -n outpost get deployment relay -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)"
case "$image" in
  busybox:1.37.0|docker.io/library/busybox:1.37.0) ;;
  *) echo "FAIL: relay image must be busybox:1.37.0 (found '$image')"; fail=1 ;;
esac
available="$(kubectl -n outpost get deployment relay -o jsonpath='{.status.availableReplicas}' 2>/dev/null || true)"
if [ "${available:-0}" -lt 1 ]; then echo "FAIL: Deployment relay has no available replica"; fail=1; fi
if [ "$fail" -eq 0 ]; then echo "PASS: relay is Available with $image"; fi
exit "$fail"
