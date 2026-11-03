---
estimated_duration: 20m
---

# Lab: Repair A Broken kube-scheduler Static Pod

**Status: UNTESTED - never run against a live cluster.**

Graded lab for the scheduler module. The scheduler manifest names a kubeconfig file that does not exist, so new Pods stay Pending without events. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS023.git -c sections/section-020/module-03/labs/lab-01
astrona submit --git ssh://git@github.com/astrona-io/ATS023.git -c sections/section-020/module-03/labs/lab-01
astrona destroy ats-023-lab-020-03-01
```

Authors run the local copy with `astrona run -c <lab>` and prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-scheduler-flag-restored.sh` | One correct `--kubeconfig` flag, `--leader-elect=true` kept, no extra files in the manifest directory |
| `validate-scheduler-running.sh` | The scheduler mirror Pod is Ready and the container runs (retries up to 3 minutes) |
| `validate-lease-renewing.sh` | The Lease `kube-scheduler` has a holder and `renewTime` changes |
| `validate-scout-scheduled.sh` | `scout` has two available replicas, no `nodeName` or other scheduler in the template, and every Pod has a node |
| `validate-new-pod-scheduled.sh` | A new throwaway Pod gets a node |

All five checks fail on the start state. A learner who sets `nodeName` fails `scout-scheduled`; one who disables leader election fails the first check.
