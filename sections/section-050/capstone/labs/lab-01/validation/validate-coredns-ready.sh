#!/usr/bin/env bash
# Check: CoreDNS runs two ready replicas.
set -uo pipefail

desired="$(kubectl -n kube-system get deployment coredns -o jsonpath='{.spec.replicas}' 2>/dev/null)"
if [ "${desired:-}" != "2" ]; then
  echo "FAIL: the coredns Deployment has ${desired:-no} replicas, expected 2"
  exit 1
fi
if ! kubectl -n kube-system rollout status deployment/coredns --timeout=90s >/dev/null 2>&1; then
  echo "FAIL: the coredns Deployment did not become ready within 90 seconds"
  exit 1
fi
echo "PASS: coredns runs 2 ready replicas"
