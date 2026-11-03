#!/usr/bin/env bash
# Applies the reference solution. Run only by `astrona test`.
set -euo pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

kubectl -n starfleet patch deployment scout --patch-file "$DIR/scout-patch.yaml"
kubectl -n starfleet rollout status deployment/scout --timeout=180s
echo "[solution] Applied."
