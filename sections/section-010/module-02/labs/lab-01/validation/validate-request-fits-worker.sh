#!/usr/bin/env bash
# Check: scout still has a CPU request and it is not larger than the allocatable
# CPU of the worker. Fails on the broken start state (64 CPUs).
set -uo pipefail

to_millicores() {
  case "$1" in
    *m) echo "${1%m}" ;;
    *) awk -v v="$1" 'BEGIN { printf "%d", v * 1000 }' ;;
  esac
}

request="$(kubectl -n starfleet get deployment scout -o jsonpath='{.spec.template.spec.containers[0].resources.requests.cpu}' 2>/dev/null || true)"
if [ -z "$request" ]; then
  echo "FAIL: scout has no CPU request (or the Deployment is missing); keep a request and lower it"
  exit 1
fi

worker="$(kubectl get nodes -l '!node-role.kubernetes.io/control-plane' -o jsonpath='{.items[0].metadata.name}' 2>/dev/null || true)"
allocatable="$(kubectl get node "$worker" -o jsonpath='{.status.allocatable.cpu}' 2>/dev/null || true)"
if [ -z "$allocatable" ]; then
  echo "FAIL: cannot read the allocatable CPU of the worker"
  exit 1
fi

request_m="$(to_millicores "$request")"
allocatable_m="$(to_millicores "$allocatable")"
if [ "$request_m" -gt "$allocatable_m" ]; then
  echo "FAIL: scout requests ${request} CPU, the worker offers ${allocatable}"
  exit 1
fi

echo "PASS: scout requests ${request} CPU, the worker offers ${allocatable}"
