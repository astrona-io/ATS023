#!/usr/bin/env bash
# Check: no shortcut. Evidence Pods, init check, relay command and kubelet are intact.
set -uo pipefail
worker="astro-ats-023-capstone-040-worker"
engine="$(command -v podman || command -v docker)"
fail=0
if [ "$("$engine" exec "$worker" systemctl is-active kubelet 2>/dev/null)" != "active" ]; then echo "FAIL: kubelet is not active on the worker"; fail=1; fi
for pod in crash-report probe beacon-logger; do
  if ! kubectl -n starfleet get pod "$pod" >/dev/null 2>&1; then echo "FAIL: evidence Pod $pod is missing"; fail=1; fi
done
check="$(kubectl -n starfleet get deployment shuttle -o jsonpath='{.spec.template.spec.initContainers[0].command[2]}' 2>/dev/null || true)"
case "$check" in *'"$MODE" != "ready"'*) ;; *) echo "FAIL: the init container check of shuttle was removed or changed"; fail=1;; esac
cmd="$(kubectl -n outpost get deployment relay -o jsonpath='{.spec.template.spec.containers[0].command[2]}' 2>/dev/null || true)"
if [ "$cmd" != "sleep 3600" ]; then echo "FAIL: relay is missing or its command was changed"; fail=1; fi
if [ "$fail" -eq 0 ]; then echo "PASS: evidence, init check, relay command and kubelet are intact"; fi
exit "$fail"
