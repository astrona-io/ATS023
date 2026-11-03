#!/usr/bin/env bash
# Check: drifter in outpost has 2 ready replicas and every container has a
# memory request and a memory limit (set in the Deployment or by a LimitRange).
set -uo pipefail

for attempt in $(seq 1 30); do
  deployment="$(kubectl -n outpost get deployment drifter -o json 2>/dev/null)"
  pods="$(kubectl -n outpost get pods -l app=drifter -o json 2>/dev/null)"
  result="$(DEPLOYMENT="$deployment" PODS="$pods" python3 - <<'PY'
import json, os
try:
    deployment = json.loads(os.environ["DEPLOYMENT"])
    pods = json.loads(os.environ["PODS"])
except ValueError:
    print("FAIL: cannot read the drifter Deployment in outpost")
    raise SystemExit(1)
if deployment["spec"].get("replicas") != 2:
    print("FAIL: drifter must keep 2 replicas")
    raise SystemExit(1)
if deployment.get("status", {}).get("readyReplicas", 0) != 2:
    print("FAIL: drifter does not have 2 ready replicas")
    raise SystemExit(1)
for pod in pods.get("items", []):
    for container in pod["spec"]["containers"]:
        resources = container.get("resources", {})
        if "memory" not in resources.get("requests", {}) or "memory" not in resources.get("limits", {}):
            print("FAIL: a drifter container has no memory request or limit")
            raise SystemExit(1)
print("PASS: drifter runs 2 replicas with memory requests and limits")
PY
)"
  status=$?
  if [[ $status -eq 0 ]]; then
    echo "$result"
    exit 0
  fi
  sleep 3
done
echo "$result"
exit 1
