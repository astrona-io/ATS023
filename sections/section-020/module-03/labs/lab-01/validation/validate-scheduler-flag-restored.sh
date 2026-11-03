#!/usr/bin/env bash
set -uo pipefail

CONTEXT="kind-astro-ats-023-lab-020-03-01"
NODE="astro-ats-023-lab-020-03-01-control-plane"

if [ "$(kubectl config current-context 2>/dev/null)" != "$CONTEXT" ]; then
  echo "FAIL: kubectl context is not $CONTEXT"
  exit 1
fi

# retry <tries> <seconds> <command...>: run the command until it succeeds.
# The scheduler restarts after a manifest change, so checks wait a bounded
# time instead of failing at once.
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

# Check: the scheduler manifest uses the real kubeconfig, keeps leader election, and the manifest directory is clean.

manifest="$(node_exec cat /etc/kubernetes/manifests/kube-scheduler.yaml 2>/dev/null)"
fail=0

if [ "$(printf "%s\n" "$manifest" | grep -c -- "- --kubeconfig=/etc/kubernetes/scheduler.conf$")" -ne 1 ]; then
  echo "FAIL: kube-scheduler.yaml does not have exactly one --kubeconfig=/etc/kubernetes/scheduler.conf flag"
  fail=1
fi
if printf "%s\n" "$manifest" | grep -q "scheduler-old"; then
  echo "FAIL: kube-scheduler.yaml still names the missing kubeconfig file"
  fail=1
fi
if ! printf "%s\n" "$manifest" | grep -q -- "--leader-elect=true"; then
  echo "FAIL: leader election is no longer enabled (--leader-elect=true is missing)"
  fail=1
fi
files="$(node_exec ls -A /etc/kubernetes/manifests 2>/dev/null | tr "\n" " ")"
if [ "$files" != "etcd.yaml kube-apiserver.yaml kube-controller-manager.yaml kube-scheduler.yaml " ]; then
  echo "FAIL: the manifest directory holds unexpected files: $files"
  fail=1
fi

if [ "$fail" -eq 0 ]; then
  echo "PASS: the scheduler manifest is correct and the manifest directory is clean"
fi
exit "$fail"
