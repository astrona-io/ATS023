#!/usr/bin/env bash
# Check: no shortcut. The kubelet still runs, the logger Pod is intact and relay keeps its command.
set -uo pipefail
worker="astro-ats-023-lab-040-03-01-worker"
engine="$(command -v podman || command -v docker)"
fail=0
if [ "$("$engine" exec "$worker" systemctl is-active kubelet 2>/dev/null)" != "active" ]; then echo "FAIL: kubelet is not active on the worker"; fail=1; fi
node="$(kubectl -n starfleet get pod beacon-logger -o jsonpath='{.spec.nodeName}' 2>/dev/null || true)"
if [ "$node" != "$worker" ]; then echo "FAIL: Pod beacon-logger is missing or not on the worker"; fail=1; fi
cmd="$(kubectl -n starfleet get deployment relay -o jsonpath='{.spec.template.spec.containers[0].command[2]}' 2>/dev/null || true)"
if [ "$cmd" != "sleep 3600" ]; then echo "FAIL: Deployment relay is missing or its command was changed"; fail=1; fi
if [ "$fail" -eq 0 ]; then echo "PASS: kubelet, logger Pod and relay command are intact"; fi
exit "$fail"
