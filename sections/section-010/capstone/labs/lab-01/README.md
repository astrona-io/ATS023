---
estimated_duration: 30m
---

# Capstone: Troubleshoot Clusters And Nodes

Graded integration lab for the whole section. The worker kubelet is stopped, the `scout` Deployment cannot be scheduled and the `probe` Deployment has a bad image tag and a wrong ConfigMap key. The task is in `question.md`; the reasoning is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run -c .
astrona submit -c .
astrona destroy ats-023-capstone-010
```

Authors prove the reference solution with `astrona test -c .`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-worker-ready-and-rules-kept.sh` | The worker is `Ready`, schedulable and keeps its label and taint |
| `validate-scout-placement-rules.sh` | `scout` has the matching `nodeSelector` and a keyed toleration |
| `validate-scout-running-on-worker.sh` | Two `scout` replicas are available, all on the worker |
| `validate-probe-image-and-reference.sh` | `probe` uses busybox 1.37.0 and reads `LEVEL` through `probe-config/level` |
| `validate-probe-running-and-reads-level.sh` | Two `probe` replicas are available and print `LEVEL=high` |
| `validate-protections-kept.sh` | The ConfigMap and the PodDisruptionBudget are untouched |

`validate-protections-kept.sh` passes before any change. The other five fail on the broken start state.
