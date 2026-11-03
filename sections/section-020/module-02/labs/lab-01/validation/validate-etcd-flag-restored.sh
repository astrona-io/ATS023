#!/usr/bin/env bash
set -uo pipefail

CONTEXT="kind-astro-ats-023-lab-020-02-01"
NODE="astro-ats-023-lab-020-02-01-control-plane"

if [ "$(kubectl config current-context 2>/dev/null)" != "$CONTEXT" ]; then
  echo "FAIL: kubectl context is not $CONTEXT"
  exit 1
fi

# retry <tries> <seconds> <command...>: run the command until it succeeds.
# The API server restarts after a manifest change, so every check that needs
# the API waits for it a bounded time instead of failing at once.
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

# Check: the API server manifest points at the etcd client port 2379 and the manifest directory holds only the four component files.

manifest="$(node_exec cat /etc/kubernetes/manifests/kube-apiserver.yaml 2>/dev/null)"
fail=0

if [ "$(printf "%s\n" "$manifest" | grep -c -- "--etcd-servers=https://127.0.0.1:2379$")" -ne 1 ]; then
  echo "FAIL: kube-apiserver.yaml does not have exactly one --etcd-servers=https://127.0.0.1:2379 flag"
  fail=1
fi
if printf "%s\n" "$manifest" | grep -q "2399"; then
  echo "FAIL: kube-apiserver.yaml still contains the wrong etcd port"
  fail=1
fi

files="$(node_exec ls -A /etc/kubernetes/manifests 2>/dev/null | tr "\n" " ")"
if [ "$files" != "etcd.yaml kube-apiserver.yaml kube-controller-manager.yaml kube-scheduler.yaml " ]; then
  echo "FAIL: the manifest directory holds unexpected files: $files"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: the API server uses the etcd client port and the manifest directory is clean"
fi
exit "$fail"
