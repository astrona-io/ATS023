#!/usr/bin/env bash
# Check: scout has a memory limit that fits the process (192Mi to 256Mi), two
# ready replicas and no OOMKilled container.
set -uo pipefail

for attempt in $(seq 1 30); do
  deployment="$(kubectl -n starfleet get deployment scout -o json 2>/dev/null)"
  pods="$(kubectl -n starfleet get pods -l app=scout -o json 2>/dev/null)"
  result="$(DEPLOYMENT="$deployment" PODS="$pods" python3 - <<'PY'
import json, os

def to_mib(value):
    units = {"Ki": 1 / 1024, "Mi": 1, "Gi": 1024, "Ti": 1024 * 1024}
    for suffix, factor in units.items():
        if value.endswith(suffix):
            return float(value[: -len(suffix)]) * factor
    return float(value) / (1024 * 1024)

try:
    deployment = json.loads(os.environ["DEPLOYMENT"])
    pods = json.loads(os.environ["PODS"])
except ValueError:
    print("FAIL: cannot read the scout Deployment")
    raise SystemExit(1)
limit = deployment["spec"]["template"]["spec"]["containers"][0].get("resources", {}).get("limits", {}).get("memory")
if limit is None or not 192 <= to_mib(limit) <= 256:
    print("FAIL: scout memory limit is %s; it must be between 192Mi and 256Mi" % limit)
    raise SystemExit(1)
if deployment["spec"].get("replicas") != 2:
    print("FAIL: scout must keep 2 replicas")
    raise SystemExit(1)
ready = deployment.get("status", {}).get("readyReplicas", 0)
if ready != 2:
    print("FAIL: scout has %s ready replicas; it needs 2" % ready)
    raise SystemExit(1)
for pod in pods.get("items", []):
    for status in pod.get("status", {}).get("containerStatuses", []):
        for key in ("state", "lastState"):
            terminated = status.get(key, {}).get("terminated")
            if terminated and terminated.get("reason") == "OOMKilled":
                print("FAIL: a scout container was OOMKilled")
                raise SystemExit(1)
print("PASS: scout runs with 2 ready replicas and no OOMKilled container")
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
