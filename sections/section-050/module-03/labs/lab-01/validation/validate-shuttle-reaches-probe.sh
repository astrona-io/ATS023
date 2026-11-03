#!/usr/bin/env bash
# Check: a real request from shuttle to the probe Service succeeds.
set -uo pipefail

for attempt in 1 2 3 4 5 6 7 8; do
  if kubectl -n starfleet exec deploy/shuttle -- wget -q -T 3 -O- http://probe/ 2>/dev/null | grep -q '^version=v1'; then
    echo "PASS: shuttle received version=v1 from http://probe/"
    exit 0
  fi
  sleep 3
done
echo "FAIL: shuttle cannot fetch http://probe/ (no answer with version=v1)"
exit 1
