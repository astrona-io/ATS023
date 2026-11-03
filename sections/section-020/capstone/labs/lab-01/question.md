---
draft: true
exam_objectives:
- Troubleshoot cluster components
---
# Question

Solve this question on: `terminal`

This is the capstone for the cluster components section: one integrated task, no step-by-step guidance.

The cluster hosts the `probe`, `shuttle` and `drifter` workloads. A new Deployment `scout` with two replicas in `starfleet` was created by the team, and it does not run. Several control-plane and add-on components are unhealthy, and `kubectl` does not work at the moment. Select the cluster with:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-023-capstone-020)"
```

Restore the cluster so that all of the following are true:

1. The API server is ready. Node access is through `podman exec` on `astro-ats-023-capstone-020-control-plane`.
2. The controller manager and the scheduler run from their static Pod manifests with their original settings, and the scheduler holds a moving `kube-scheduler` Lease.
3. `kube-proxy` runs on both nodes from its original image.
4. `scout` has two available replicas that a ReplicaSet created and the scheduler placed. `shuttle` reaches `probe` through its Service.

Do not delete the workloads, do not set `nodeName`, do not change the etcd manifest and do not leave backup files in `/etc/kubernetes/manifests`.
