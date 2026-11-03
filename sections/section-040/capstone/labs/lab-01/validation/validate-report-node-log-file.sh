#!/usr/bin/env bash
# Check: incident-report.nodeLogFile is the real log file of beacon-logger on the worker.
set -uo pipefail
worker="astro-ats-023-capstone-040-worker"
engine="$(command -v podman || command -v docker)"
path="$(kubectl -n starfleet get configmap incident-report -o jsonpath='{.data.nodeLogFile}' 2>/dev/null || true)"
if ! [[ "$path" =~ ^/var/log/pods/starfleet_beacon-logger_[^/]+/logger/[0-9]+\.log$ ]]; then
  echo "FAIL: nodeLogFile must be the path under /var/log/pods (found '$path')"; exit 1
fi
if "$engine" exec "$worker" grep -q "beacon: capstone marker" "$path" 2>/dev/null; then
  echo "PASS: $path holds the beacon-logger output"; exit 0
fi
echo "FAIL: $path does not exist on the worker or lacks the marker"; exit 1
