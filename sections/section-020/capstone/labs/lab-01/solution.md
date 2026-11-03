---
draft: true
exam_objectives:
- Troubleshoot cluster components
---
# Solution

The capstone is unguided; this page lists the order that works and why. Run `astrona submit --git ssh://git@github.com/astrona-io/ATS023.git -c sections/section-020/capstone/labs/lab-01 --keep` after each repair.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-023-capstone-020)"
NODE=astro-ats-023-capstone-020-control-plane
```

## Order of repair

First the API server, because every other repair is checked through the API. `crictl ps -a --name kube-apiserver` on the node shows exited attempts, and `crictl logs` shows failed connections to `127.0.0.1:2399`. etcd listens on 2379. Replace the port in a copy of the manifest and move the copy into `/etc/kubernetes/manifests`. Wait until `kubectl get --raw=/readyz` answers `ok`.

Next the controller manager and the scheduler. `scout` has no ReplicaSet, which points at the controller manager. Its previous log names the invalid `--leader-elect-lease-duration` value, so remove that flag line from a copy and move the copy back. The Pods of `scout`, once created, would be Pending without events, which points at the scheduler. Its log names the missing kubeconfig file `/etc/kubernetes/scheduler-old.conf`; the existing file is `scheduler.conf`.

Last `kube-proxy`. `kubectl -n kube-system get daemonset kube-proxy` shows fewer Ready Pods than nodes, and the Pod events show an image that cannot be pulled. `kubectl -n kube-system rollout undo daemonset/kube-proxy` restores the previous revision. The DaemonSet controller runs inside the controller manager, so this works only after the controller manager is repaired.

## Proof

Wait for `scout` to become available and read the Lease twice:

```sh
kubectl -n starfleet get deployment scout
kubectl -n kube-system get lease kube-scheduler -o jsonpath='{.spec.renewTime}{"\n"}'
kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://probe/
```
