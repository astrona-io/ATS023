---
draft: true
exam_objectives:
- Troubleshoot clusters and nodes
---
# Failed Workloads: Events And Pod States

When a workload does not start, Kubernetes already knows why. The answer sits in the status of the Pod, in the state of each container and in the events that the kubelet and the controllers write. This module teaches you to read those three sources in order, to tell the common failure states apart, and to repair the Deployment that causes them.

## Learning goals

After this module you can:

- Read a Pod's phase, its container states and its events, and say which component wrote each one.
- Tell `Pending` from `ContainerCreating` and explain what each says about the scheduler and the kubelet.
- Diagnose `ErrImagePull` and `ImagePullBackOff` from the image reference.
- Diagnose `CreateContainerConfigError` caused by a missing ConfigMap, Secret or key.
- Recognise `CrashLoopBackOff`, `OOMKilled` and `Evicted` and say how they differ.
- Use `kubectl get events --sort-by`, `kubectl rollout status` and `kubectl rollout undo` to find and repair a failed rollout.

## Before you start

You need Kubernetes basics: Pods, Deployments, ReplicaSets, ConfigMaps and the commands `kubectl get`, `kubectl describe` and `kubectl logs`. The playground is a `kind` cluster with one control plane node and one worker node. Several Deployments in `starfleet` and `outpost` are broken on purpose, each in a different way, and one Deployment is healthy for comparison.

## Reading order

The first part explains the Pod phase, the container states and the event stream, and how to read them with `kubectl describe` and `kubectl get events`. The second part covers the two failures that stop a container before it runs: a bad image reference and a missing configuration object. A graded lab follows the second part. The third part covers containers that start and then fail, Pods removed by the kubelet, and rolling back a bad rollout. A summary closes the module.

<!-- astrona:playground -->
