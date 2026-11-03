#!/usr/bin/env bash
# Check: real HTTP requests from shuttle to both Services succeed.
set -uo pipefail

fail=0
for name in probe scout; do
  ok=1
  for attempt in 1 2 3 4 5 6 7 8; do
    if kubectl -n starfleet exec deploy/shuttle -- wget -q -T 3 -O- "http://$name/" 2>/dev/null | grep -q '^version=v1'; then
      ok=0
      break
    fi
    sleep 3
  done
  if [ "$ok" -ne 0 ]; then
    echo "FAIL: shuttle cannot fetch http://$name/"
    fail=1
  fi
done
if [ "$fail" -eq 0 ]; then
  echo "PASS: shuttle received version=v1 from probe and scout"
fi
exit "$fail"
