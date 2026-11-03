---
estimated_duration: 30m
---

# Capstone: Output Streams And Runtime Evidence

Integrated, unguided capstone for the output streams section. **Status: UNTESTED - never run against a live cluster.**

The cluster has three evidence Pods (a restarting container, a two-container Pod with one error and a logger on the worker node) and two Deployments with faults (an init container that fails and an image tag that does not exist). The task is in `question.md`; `solution.md` is a reference for after the attempt.

## Run it

```sh
astrona run -c sections/section-040/capstone/labs/lab-01
astrona submit -c sections/section-040/capstone/labs/lab-01
astrona destroy ats-023-capstone-040
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-report-exit-code.sh` | `exitCode` equals the last terminated exit code of `crash-report` |
| `validate-report-worker-error.sh` | `workerError` equals the code in the `worker` log of `probe` |
| `validate-report-node-log-file.sh` | `nodeLogFile` is a real path under `/var/log/pods` on the worker with the logger output |
| `validate-shuttle-init-fixed.sh` | `shuttle` is Available and `fetch-config` finished with exit code 0 |
| `validate-relay-image-fixed.sh` | `relay` uses `busybox:1.37.0` and is Available |
| `validate-no-shortcut.sh` | Evidence Pods, the init check, the `relay` command and the kubelet are intact |

`validate-no-shortcut.sh` passes on the start state; the other checks fail until the task is done.
