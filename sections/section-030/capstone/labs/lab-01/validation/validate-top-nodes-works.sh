#!/usr/bin/env bash
# Check: kubectl top nodes returns data. Retries for up to two minutes because
# the first scrape happens after metrics-server starts.
set -uo pipefail

for attempt in $(seq 1 30); do
  output="$(kubectl top nodes --no-headers 2>/dev/null)"
  if [[ $? -eq 0 && -n "$output" ]]; then
    echo "PASS: kubectl top nodes returns data"
    exit 0
  fi
  sleep 4
done
echo "FAIL: kubectl top nodes does not return data"
exit 1
