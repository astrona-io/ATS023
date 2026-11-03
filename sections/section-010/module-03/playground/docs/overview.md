---
draft: true
exam_objectives:
- Troubleshoot clusters and nodes
---
# Playground: Failed Workloads

This is a playground, not a lab. It starts a cluster in which several workloads fail, each in a different way, and then waits. There is no task, no `astrona submit` and no pass or fail.

## What is running

`kubectl` already points at the playground cluster.

| Namespace | Workload | State |
| --- | --- | --- |
| `starfleet` | `probe` | Running; reads `GREETING` from the ConfigMap `probe-config` |
| `starfleet` | `scout` | Revision 1 is good. Revision 2 uses an image tag that does not exist: `ErrImagePull` and `ImagePullBackOff` |
| `starfleet` | `shuttle` | `CreateContainerConfigError`: the ConfigMap `shuttle-settings` does not exist |
| `starfleet` | `bridge` | `CreateContainerConfigError`: the ConfigMap `bridge-config` has the key `level`, not `mode` |
| `starfleet` | `wait-volume` (Pod) | `ContainerCreating`: it mounts the ConfigMap `wait-volume-settings`, which does not exist |
| `outpost` | `drifter` | `OOMKilled` and `CrashLoopBackOff`: it allocates more than its 64 MiB limit |

## Things to try

- List the Pods of the whole cluster and sort the events by creation time. Match each non-running Pod to its event.
- Describe `shuttle` and `bridge` and compare the two event messages.
- Fix `scout` with `kubectl rollout undo`, then check `kubectl rollout history`.
- Create the missing ConfigMap for `shuttle` and watch the existing Pod start without a new rollout.
- Change the key in `bridge` so that it matches the ConfigMap.
- Create the ConfigMap `wait-volume-settings` and watch `wait-volume` leave `ContainerCreating`.
- Raise the memory limit of `drifter` to 512Mi and confirm that it runs.
- Read `kubectl logs --previous` for `drifter` before and after the change.
