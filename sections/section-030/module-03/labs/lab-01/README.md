---
estimated_duration: 25m
---

# Lab: Fix OOMKilled And Quota Rejections

Graded lab for the resources module. `scout` is killed by a memory limit that is too low, the `starfleet` quota has no room for a larger `scout`, and `drifter` in `outpost` is rejected because the quota requires memory values and no LimitRange supplies them. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run -c .
astrona submit -c .
astrona destroy ats-023-lab-030-03-01
```

Authors prove the reference solution with `astrona test -c .`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-scout-not-oomkilled.sh` | The `scout` limit is 192Mi to 256Mi, two replicas are ready and no container is `OOMKilled` |
| `validate-starfleet-quota-and-probe-intact.sh` | `compute-quota` still limits memory, and `probe` keeps 2 replicas and limit 256Mi |
| `validate-drifter-admitted.sh` | `drifter` has 2 ready replicas and every container has a memory request and limit |
| `validate-outpost-quota-intact.sh` | `outpost-quota` still limits memory requests, memory limits and Pods |

`starfleet-quota-and-probe-intact` and `outpost-quota-intact` pass before any change; they guard against shortcuts such as deleting a quota.
