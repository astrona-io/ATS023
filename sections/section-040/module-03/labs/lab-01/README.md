---
estimated_duration: 25m
---

# Lab: Find Evidence In Node-Level Logs And Fix A Kubelet-Visible Fault

Graded lab for the node-level logs module. **Status: UNTESTED - never run against a live cluster.**

The cluster has a control plane node and a worker node. Pod `beacon-logger` printed a random token that is stored in a log file on the worker, and Deployment `relay` uses an image tag that does not exist. The task is in `question.md`; the walkthrough is in `solution.md`. The setup and the validation scripts use `podman exec` (or `docker exec`) on the node container.

## Run it

```sh
astrona run -c sections/section-040/module-03/labs/lab-01
astrona submit -c sections/section-040/module-03/labs/lab-01
astrona destroy ats-023-lab-040-03-01
```

## Checks

| Script | What it proves |
| --- | --- |
| `validate-node-log-evidence.sh` | `token` equals the token in Pod `beacon-logger`, and `logFile` is a path under `/var/log/pods` on the worker that contains it |
| `validate-kubelet-evidence.sh` | `failedImage` is the image reference of the pull error |
| `validate-relay-running.sh` | `relay` uses `busybox:1.37.0` and has an available replica |
| `validate-no-shortcut.sh` | The kubelet is active, `beacon-logger` is on the worker, and the `relay` command is unchanged |

`validate-no-shortcut.sh` passes on the start state. The other three fail until the task is done.
