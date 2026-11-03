---
estimated_duration: 25m
---

# Lab: Repair A Pending Deployment

Graded lab for the scheduling module. The worker node is labelled `pool=survey` and tainted `dedicated=survey:NoSchedule`. The `scout` Deployment has a wrong `nodeSelector`, no toleration and a CPU request no node can satisfy. The task is in `question.md`; the walkthrough is in `solution.md`.

**Status: UNTESTED - never run against a live cluster.**

## Run it

```sh
astrona run -c .
astrona submit -c .
astrona destroy ats-023-lab-010-02-01
```

Authors prove the reference solution with `astrona test -c .`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-worker-rules-kept.sh` | The worker keeps the label `pool=survey` and the taint `dedicated=survey:NoSchedule` and is not cordoned |
| `validate-selector-matches-worker.sh` | `scout` still has a `nodeSelector` and every pair matches a label of the worker |
| `validate-toleration-matches-taint.sh` | The Pod template has a keyed toleration for the `dedicated` taint |
| `validate-request-fits-worker.sh` | `scout` keeps a CPU request that is not larger than the worker's allocatable CPU |
| `validate-scout-running-on-worker.sh` | Two replicas are available and every `scout` Pod runs on the worker |

`worker-rules-kept` passes before any change. The other four fail on the broken start state.
