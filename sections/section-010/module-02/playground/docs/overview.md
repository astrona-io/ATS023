---
draft: true
exam_objectives:
- Troubleshoot clusters and nodes
---
# Playground: Pending Pods, Taints And Node Maintenance

This is a playground, not a lab. It starts a cluster with one control plane node and one worker node, and then waits. There is no task, no `astrona submit` and no pass or fail. Change rules, break them, destroy the playground and start again.

## What is running

`kubectl` already points at the playground cluster. The worker node has the label `pool=survey`. The control plane node has its usual `NoSchedule` taint.

| Namespace | Workload | State |
| --- | --- | --- |
| `starfleet` | `scout` (2 replicas) | Running on the worker |
| `starfleet` | `bridge` (2 replicas) | Running on the worker, protected by a PodDisruptionBudget with `minAvailable: 2` |
| `starfleet` | `probe` | `Pending`: its `nodeSelector` asks for `pool: survey-east` |
| `starfleet` | `shuttle` | `Pending`: it requests 64 CPUs |
| `outpost` | `drifter` | Running on the worker |

## Things to try

- Read the `FailedScheduling` event of `probe` and of `shuttle` and name the rule that rejected the worker in each case.
- Fix `probe` by correcting its `nodeSelector`. Fix `shuttle` by lowering its CPU request. Confirm both reach `Running` on the worker.
- Taint the worker with `dedicated=survey:NoSchedule`, restart `scout` and watch the rollout stall. Add a toleration to repair it.
- Compare `status.capacity` and `status.allocatable` of the worker node.
- Drain the worker with `--timeout=30s`, read the budget message, then uncordon.
- Scale `bridge` to 3 replicas and drain again. Notice what changes in `kubectl get pdb`.
- Change the taint effect to `NoExecute` and watch what happens to running Pods without a toleration.
