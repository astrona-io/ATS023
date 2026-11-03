---
draft: true
exam_objectives:
- Troubleshoot cluster components
---
# Playground: API Server And etcd

This environment is a healthy two-node kind cluster. It has no task, no grading and no submission. You can break things on the control-plane node and recover them, or destroy the environment and start again.

## What is running

- One control-plane node and one worker node. Each node is a container; the control-plane node is `astro-ats-023-playground-020-02-control-plane`. Reach it with `podman exec`.
- The control-plane components run as static Pods from `/etc/kubernetes/manifests`: `etcd.yaml`, `kube-apiserver.yaml`, `kube-controller-manager.yaml` and `kube-scheduler.yaml`.
- The example workloads: `probe` (two replicas) and `shuttle` in `starfleet`, and `drifter` in `outpost`.

Select the cluster first:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-023-playground-020-02)"
NODE=astro-ats-023-playground-020-02-control-plane
```

## What to try

- List the manifest files, then compare the files with the mirror Pods from `kubectl -n kube-system get pods`.
- Delete the mirror Pod of the scheduler and watch it come back from the file.
- Run `crictl ps -a` and `crictl logs` for each control-plane container on the node.
- Print the etcd flags and the API server flags that name port 2379, the certificates and port 6443.
- Run `etcdctl endpoint health` with the four flags, then once without the certificate flags, and compare the two results.
- Call `/livez`, `/readyz?verbose` and `/readyz/etcd` with `kubectl get --raw`.
- Copy `kube-scheduler.yaml` out of the manifest directory into `/etc/kubernetes`, change a flag in the copy and move it back, then change it back again. Watch `crictl ps -a` between the two changes.
- Ask `kubectl auth can-i` as a service account, and read the `Forbidden` message from a real request.
