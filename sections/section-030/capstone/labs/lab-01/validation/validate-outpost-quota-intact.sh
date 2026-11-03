#!/usr/bin/env bash
# Check: the outpost quota still exists and still enforces memory requests,
# memory limits and the Pod count.
set -uo pipefail

quota="$(kubectl -n outpost get resourcequota outpost-quota -o json 2>/dev/null)"
if [[ -z "$quota" ]]; then
  echo "FAIL: ResourceQuota outpost-quota in outpost was deleted"
  exit 1
fi
QUOTA="$quota" python3 - <<'PY'
import json, os
hard = json.loads(os.environ["QUOTA"]).get("spec", {}).get("hard", {})
missing = [key for key in ("requests.memory", "limits.memory", "pods") if key not in hard]
if missing:
    print("FAIL: outpost-quota no longer limits: " + ", ".join(missing))
    raise SystemExit(1)
print("PASS: outpost-quota is intact")
PY
