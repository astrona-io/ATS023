---
draft: true
exam_objectives:
- Troubleshoot cluster components
---
# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-023-lab-020-03-01)"
NODE=astro-ats-023-lab-020-03-01-control-plane
```

## Step 1: Find the missing component

Check the Pods and their events, then the scheduler Pod:

```sh
kubectl -n starfleet get pods -o wide
kubectl -n starfleet describe pod -l app=scout
kubectl -n kube-system get pods -l component=kube-scheduler
```

The `scout` Pods are Pending with no node and no events. The scheduler Pod is not Ready and restarts. Read the log of the previous run:

```sh
kubectl -n kube-system logs -l component=kube-scheduler --previous --tail=10
```

The log names the kubeconfig file `/etc/kubernetes/scheduler-old.conf` that the scheduler cannot read. Compare with the files on the node:

```sh
podman exec $NODE ls /etc/kubernetes
```

The file `scheduler.conf` exists and `scheduler-old.conf` does not.

## Step 2: Repair the manifest

Copy the manifest out of the watched directory, fix the copy and move it back in one step:

```sh
podman exec $NODE sh -c 'cp /etc/kubernetes/manifests/kube-scheduler.yaml /etc/kubernetes/kube-scheduler.yaml.fixed && sed -i "s#scheduler-old.conf#scheduler.conf#" /etc/kubernetes/kube-scheduler.yaml.fixed && mv /etc/kubernetes/kube-scheduler.yaml.fixed /etc/kubernetes/manifests/kube-scheduler.yaml'
```

Wait for the kubelet to rescan the directory, up to about a minute:

```sh
kubectl -n kube-system get pods -l component=kube-scheduler --watch
```

When the Pod is Ready, press Ctrl-C and grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS023.git -c sections/section-020/module-03/labs/lab-01 --keep
```

The check `scheduler-flag-restored` passes, and `scheduler-running` passes once the Pod is Ready.

## Step 3: Prove the scheduler works

Read the Lease twice, a few seconds apart, and check the `scout` Pods:

```sh
kubectl -n kube-system get lease kube-scheduler -o jsonpath='{.spec.holderIdentity}{"  "}{.spec.renewTime}{"\n"}'
kubectl -n starfleet get pods -l app=scout -o wide
```

The second reading shows a later `renewTime`, and both `scout` Pods have a node and the status Running. Grade it again. The checks `lease-renewing`, `scout-scheduled` and `new-pod-scheduled` pass. The last check creates a throwaway Pod and deletes it again.
