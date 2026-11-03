---
draft: true
exam_objectives:
- Troubleshoot clusters and nodes
---
# Repair A Pending Deployment

Solve this question on: `terminal`

Use the kubeconfig of this lab:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-023-lab-010-02-01)"
```

The survey team reserved the worker node for its own workloads. The worker has the label `pool=survey` and the taint `dedicated=survey:NoSchedule`. The `scout` Deployment in `starfleet` has two replicas, and none of its Pods start.

1. Find out why the scheduler rejects the worker node for `scout`. There is more than one reason.

2. Change the `scout` Deployment so that both replicas are `Running` and `Ready` on the worker node. The Deployment must keep a `nodeSelector` that matches the worker's labels, a toleration for the reserved taint and a CPU request, but the CPU request must fit the worker node.

3. Do not remove the taint or the label from the worker node, do not cordon it, and do not delete or scale down the Deployment.

`kubectl` has cluster administrator rights.
