#!/usr/bin/env bash
# Check: ConfigMap usage-report in starfleet holds a recent PodMetricsList that
# includes both probe Pods and both scout Pods, with CPU and memory usage.
set -uo pipefail

report="$(kubectl -n starfleet get configmap usage-report -o json 2>/dev/null)"
if [[ -z "$report" ]]; then
  echo "FAIL: ConfigMap usage-report does not exist in starfleet"
  exit 1
fi
REPORT="$report" python3 - <<'PY'
import json, os
from datetime import datetime, timezone

data = json.loads(os.environ["REPORT"]).get("data", {})
if data.get("source") != "metrics.k8s.io/v1beta1":
    print("FAIL: key source must be metrics.k8s.io/v1beta1")
    raise SystemExit(1)
try:
    sample = json.loads(data.get("podMetricsJson", ""))
except ValueError:
    print("FAIL: key podMetricsJson is not valid JSON")
    raise SystemExit(1)
if sample.get("kind") != "PodMetricsList":
    print("FAIL: podMetricsJson is not a PodMetricsList")
    raise SystemExit(1)
items = sample.get("items", [])
for prefix in ("probe-", "scout-"):
    matching = [item for item in items if item["metadata"]["name"].startswith(prefix)]
    if len(matching) != 2:
        print("FAIL: the sample must contain 2 Pods named " + prefix + "*")
        raise SystemExit(1)
    for item in matching:
        usage = item["containers"][0].get("usage", {})
        if "cpu" not in usage or "memory" not in usage:
            print("FAIL: a sampled Pod has no cpu or memory usage")
            raise SystemExit(1)
        stamp = datetime.fromisoformat(item["timestamp"].replace("Z", "+00:00"))
        if (datetime.now(timezone.utc) - stamp).total_seconds() > 600:
            print("FAIL: the sample is older than ten minutes")
            raise SystemExit(1)
print("PASS: usage-report holds a recent PodMetricsList for probe and scout")
PY
