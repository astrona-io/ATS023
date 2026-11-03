#!/usr/bin/env bash
# Check: probe uses busybox 1.37.0 and LEVEL still comes from the ConfigMap
# probe-config key level through a configMapKeyRef. A literal value fails.
set -uo pipefail

image="$(kubectl -n starfleet get deployment probe -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)"
case "$image" in
  docker.io/library/busybox:1.37.0|busybox:1.37.0) ;;
  *) echo "FAIL: probe uses image '${image}', expected docker.io/library/busybox:1.37.0"; exit 1 ;;
esac

ref="$(kubectl -n starfleet get deployment probe -o json 2>/dev/null \
  | jq -r '.spec.template.spec.containers[0].env // [] | map(select(.name=="LEVEL")) | .[0].valueFrom.configMapKeyRef | "\(.name // "none")/\(.key // "none")"')"
if [ "$ref" != "probe-config/level" ]; then
  echo "FAIL: LEVEL comes from '${ref}', expected configMapKeyRef probe-config/level"
  exit 1
fi

echo "PASS: probe uses $image and reads LEVEL from probe-config/level"
