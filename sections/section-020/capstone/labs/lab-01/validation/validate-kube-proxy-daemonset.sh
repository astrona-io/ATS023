#!/usr/bin/env bash
set -uo pipefail

CONTEXT="kind-astro-ats-023-capstone-020"
NODE="astro-ats-023-capstone-020-control-plane"

if [ "$(kubectl config current-context 2>/dev/null)" != "$CONTEXT" ]; then
  echo "FAIL: kubectl context is not $CONTEXT"
  exit 1
fi

# retry <tries> <seconds> <command...>: run the command until it succeeds.
# Components restart after a manifest change and the API server may be down
# for a while, so checks wait a bounded time instead of failing at once.
retry() {
  local tries="$1" pause="$2" attempt
  shift 2
  for ((attempt = 1; attempt <= tries; attempt++)); do
    if "$@"; then
      return 0
    fi
    sleep "$pause"
  done
  return 1
}

node_exec() { podman exec "$NODE" "$@"; }
pod_ready() {
  [ "$(kubectl -n kube-system get pod -l "component=$1" -o "jsonpath={.items[0].status.containerStatuses[0].ready}" 2>/dev/null)" = "true" ]
}

# Check: kube-proxy runs on every node from its original image.

healthy() {
  local desired ready
  desired="$(kubectl -n kube-system get daemonset kube-proxy -o "jsonpath={.status.desiredNumberScheduled}" 2>/dev/null)"
  ready="$(kubectl -n kube-system get daemonset kube-proxy -o "jsonpath={.status.numberReady}" 2>/dev/null)"
  [ "$desired" = "2" ] && [ "$ready" = "2" ]
}
if ! retry 36 5 healthy; then
  echo "FAIL: the kube-proxy DaemonSet does not have two Ready Pods"
  exit 1
fi
image="$(kubectl -n kube-system get daemonset kube-proxy -o "jsonpath={.spec.template.spec.containers[0].image}" 2>/dev/null)"
case "$image" in
  *kube-proxy:v*) ;;
  *) echo "FAIL: unexpected kube-proxy image: $image"; exit 1 ;;
esac
if printf "%s" "$image" | grep -q "missing"; then
  echo "FAIL: kube-proxy still uses the missing image tag: $image"
  exit 1
fi
if ! kubectl -n kube-system get configmap kube-proxy >/dev/null 2>&1; then
  echo "FAIL: the ConfigMap kube-proxy no longer exists"
  exit 1
fi
echo "PASS: kube-proxy is Ready on both nodes"
