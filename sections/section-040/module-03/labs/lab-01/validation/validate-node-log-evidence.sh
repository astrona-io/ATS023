#!/usr/bin/env bash
# Check: ConfigMap node-log-evidence has the token and the node log file that holds it.
set -uo pipefail
worker="astro-ats-023-lab-040-03-01-worker"
engine="$(command -v podman || command -v docker)"
fail=0
token="$(kubectl -n starfleet get configmap node-log-evidence -o jsonpath='{.data.token}' 2>/dev/null || true)"
log_file="$(kubectl -n starfleet get configmap node-log-evidence -o jsonpath='{.data.logFile}' 2>/dev/null || true)"
expected="$(kubectl -n starfleet get pod beacon-logger -o jsonpath='{.spec.containers[0].env[?(@.name=="TOKEN")].value}' 2>/dev/null || true)"
if [ -z "$expected" ]; then echo "FAIL: Pod beacon-logger is missing or has no TOKEN"; exit 1; fi
if [ "$token" != "$expected" ]; then echo "FAIL: token does not match the token in the node log"; fail=1; fi
if ! [[ "$log_file" =~ ^/var/log/pods/starfleet_beacon-logger_[^/]+/logger/[0-9]+\.log$ ]]; then
  echo "FAIL: logFile must be the path under /var/log/pods on the worker node (found '$log_file')"; fail=1
elif ! "$engine" exec "$worker" grep -q "token=$expected" "$log_file" 2>/dev/null; then
  echo "FAIL: the file $log_file on the worker does not contain the token"; fail=1
fi
if [ "$fail" -eq 0 ]; then echo "PASS: node-log-evidence names the token and its node log file"; fi
exit "$fail"
