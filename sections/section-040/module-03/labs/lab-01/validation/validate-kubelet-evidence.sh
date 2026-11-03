#!/usr/bin/env bash
# Check: ConfigMap node-log-evidence records the image reference the kubelet failed to pull.
set -uo pipefail
image="$(kubectl -n starfleet get configmap node-log-evidence -o jsonpath='{.data.failedImage}' 2>/dev/null || true)"
case "$image" in
  busybox:1.37.99|docker.io/library/busybox:1.37.99) echo "PASS: failedImage is $image"; exit 0 ;;
  *) echo "FAIL: failedImage must be the image reference in the kubelet pull error (found '$image')"; exit 1 ;;
esac
