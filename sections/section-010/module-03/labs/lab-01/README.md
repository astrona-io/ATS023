---
estimated_duration: 25m
---

# Lab: Repair A Failing Deployment

Graded lab for the failed-workloads module. The `probe` Deployment in `starfleet` uses an image tag that does not exist and reads `GREETING` from a ConfigMap name that does not exist. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run -c .
astrona submit -c .
astrona destroy ats-023-lab-010-03-01
```

Authors prove the reference solution with `astrona test -c .`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-image-tag-fixed.sh` | The container image is `docker.io/library/busybox:1.37.0` |
| `validate-configmap-reference-fixed.sh` | `GREETING` still comes from `configMapKeyRef` `probe-config/greeting` |
| `validate-configmap-intact.sh` | The ConfigMap `probe-config` still has `greeting=hello` |
| `validate-probe-running.sh` | Two replicas are available and no container is waiting |
| `validate-probe-reads-greeting.sh` | A running Pod prints `GREETING=hello` |

`configmap-intact` passes before any change. The other four fail on the broken start state.
