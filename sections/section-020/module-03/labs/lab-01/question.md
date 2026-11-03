---
draft: true
exam_objectives:
- Troubleshoot cluster components
---
# Question

Solve this question on: `terminal`

The team created the `scout` Deployment with two replicas in `starfleet`. Its Pods stay Pending, and `kubectl describe pod` shows no events. The `probe` Deployment, which started earlier, still runs.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-023-lab-020-03-01)"
```

1. Find out why the `scout` Pods have no node. Check the scheduler Pod in `kube-system`, its log and its manifest. The node container is `astro-ats-023-lab-020-03-01-control-plane`; use `podman exec` for node commands.
2. Repair the cause in the scheduler static Pod manifest. Keep leader election enabled and do not leave backup files in `/etc/kubernetes/manifests`.
3. Show that the scheduler is active: the Lease `kube-scheduler` in `kube-system` has a holder and its `renewTime` changes.
4. Make both `scout` Pods Running on a node chosen by the scheduler.

Do not set `nodeName` on the Pods or the Deployment, do not delete the Deployment, and do not change the other control-plane manifests.
