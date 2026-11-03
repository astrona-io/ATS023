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

# Check: the API server answers /readyz with ok and its container is running (waits up to 3 minutes).

api_ready() { [ "$(kubectl get --raw=/readyz 2>/dev/null)" = "ok" ]; }
container_running() { node_exec crictl ps --name kube-apiserver --state running -q 2>/dev/null | grep -q .; }

if ! retry 36 5 api_ready; then
  echo "FAIL: /readyz did not answer ok within 3 minutes"
  exit 1
fi
if ! retry 6 5 container_running; then
  echo "FAIL: no running kube-apiserver container on the node"
  exit 1
fi
echo "PASS: the API server is ready and its container is running"
