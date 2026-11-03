#!/usr/bin/env bash
# Check: the probe container uses busybox 1.37.0. Fails on the broken start
# state (tag 1.37.99).
set -uo pipefail

image="$(kubectl -n starfleet get deployment probe -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null || true)"
if [ -z "$image" ]; then
  echo "FAIL: Deployment probe not found"
  exit 1
fi
case "$image" in
  docker.io/library/busybox:1.37.0|busybox:1.37.0) echo "PASS: probe uses image $image" ;;
  *) echo "FAIL: probe uses image '$image', expected docker.io/library/busybox:1.37.0"; exit 1 ;;
esac
