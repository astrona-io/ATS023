---
draft: true
exam_objectives:
- Troubleshoot cluster components
---
# Playground: Scheduler And Cluster Add-Ons

This environment is a healthy two-node kind cluster. It has no task, no grading and no submission. You can stop the scheduler and see what happens to new Pods, and then recover it.

## What is running

- One control-plane node and one worker node. The control-plane node container is `astro-ats-023-playground-020-03-control-plane`.
- The scheduler runs as a static Pod from `/etc/kubernetes/manifests/kube-scheduler.yaml`. It holds a Lease named `kube-scheduler` in `kube-system`.
- Add-ons in `kube-system`: a `kube-proxy` DaemonSet with the ConfigMap `kube-proxy`, a CoreDNS Deployment and the network plugin.
- The example workloads: `probe` and `shuttle` in `starfleet`, and `drifter` in `outpost`.

Select the cluster first:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-023-playground-020-03)"
NODE=astro-ats-023-playground-020-03-control-plane
```

## What to try

- Read the Lease `kube-scheduler` with `kubectl -n kube-system get lease kube-scheduler -o yaml` twice, a few seconds apart, and compare `renewTime`.
- Read the scheduler log with `crictl logs` on the node.
- Move `kube-scheduler.yaml` out of the manifest directory into `/etc/kubernetes`, create a Pod, and compare `kubectl describe pod` with a Pod that cannot fit on any node. Move the file back afterwards.
- List the keys of the ConfigMap `kube-proxy` and find the proxy mode and the cluster CIDR.
- Compare `kubectl -n kube-system get daemonset` with the Pods the DaemonSet should have, one per node.
- Read the log of one `kube-proxy` Pod and the log of one CoreDNS Pod.
