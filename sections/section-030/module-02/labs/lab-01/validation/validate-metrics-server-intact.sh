#!/usr/bin/env bash
# Check: the repair edited the existing metrics-server Deployment (not replaced
# it) and kept the flag that makes the kubelet scrape work on kind.
set -uo pipefail

fail=0

annotation="$(kubectl -n kube-system get deployment metrics-server -o jsonpath='{.metadata.annotations.lab\.astrona\.io/seeded}' 2>/dev/null)"
if [[ "$annotation" != "true" ]]; then
  echo "FAIL: the metrics-server Deployment was deleted or replaced; edit the existing one"
  fail=1
fi

image="$(kubectl -n kube-system get deployment metrics-server -o jsonpath='{.spec.template.spec.containers[0].image}' 2>/dev/null)"
if [[ "$image" != *metrics-server* ]]; then
  echo "FAIL: the metrics-server image was changed to: ${image:-none}"
  fail=1
fi

args="$(kubectl -n kube-system get deployment metrics-server -o jsonpath='{range .spec.template.spec.containers[0].args[*]}{@}{"\n"}{end}' 2>/dev/null)"
if ! printf '%s\n' "$args" | grep -qx -- '--kubelet-insecure-tls'; then
  echo "FAIL: the argument --kubelet-insecure-tls is missing"
  fail=1
fi
if [[ "$(printf '%s\n' "$args" | grep -cx -- '--kubelet-insecure-tls')" -gt 1 ]]; then
  echo "FAIL: the argument --kubelet-insecure-tls appears more than once"
  fail=1
fi

ready="$(kubectl -n kube-system get deployment metrics-server -o jsonpath='{.status.readyReplicas}' 2>/dev/null)"
if [[ "${ready:-0}" -lt 1 ]]; then
  echo "FAIL: no metrics-server replica is ready"
  fail=1
fi

if [[ $fail -eq 0 ]]; then
  echo "PASS: metrics-server was repaired in place and is ready"
fi
exit $fail
