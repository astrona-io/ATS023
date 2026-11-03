---
draft: true
exam_objectives:
- Troubleshoot cluster components
---
# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-023-lab-020-02-01)"
NODE=astro-ats-023-lab-020-02-01-control-plane
```

## Step 1: Read the evidence on the node

`kubectl` cannot be trusted, so ask the container runtime. List the API server containers, including exited ones:

```sh
podman exec $NODE crictl ps -a --name kube-apiserver
```

The result shows several attempts of `kube-apiserver` with the state `Exited` and a growing ATTEMPT number. The kubelet keeps restarting the container. Read the log of the newest attempt with its container identifier:

```sh
podman exec $NODE crictl logs --tail=20 <CONTAINER_ID>
```

The log has lines about failing to connect to `127.0.0.1:2399`. Now compare with the etcd manifest:

```sh
podman exec $NODE grep -E 'listen-client-urls|etcd-servers' /etc/kubernetes/manifests/etcd.yaml /etc/kubernetes/manifests/kube-apiserver.yaml
```

etcd listens for clients on port 2379, but the API server flag `--etcd-servers` names port 2399.

## Step 2: Repair the flag

Copy the manifest out of the watched directory, fix the copy and move it back in one step:

```sh
podman exec $NODE sh -c 'cp /etc/kubernetes/manifests/kube-apiserver.yaml /etc/kubernetes/kube-apiserver.yaml.fixed && sed -i "s#127.0.0.1:2399#127.0.0.1:2379#" /etc/kubernetes/kube-apiserver.yaml.fixed && mv /etc/kubernetes/kube-apiserver.yaml.fixed /etc/kubernetes/manifests/kube-apiserver.yaml'
```

Wait for the kubelet to rescan and for the API server to start. This command retries until the readiness check answers `ok`:

```sh
until kubectl get --raw=/readyz 2>/dev/null; do sleep 5; done
```

Check the progress with the first `crictl` command if it takes longer than two minutes. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS023.git -c sections/section-020/module-02/labs/lab-01 --keep
```

The checks `etcd-flag-restored` and `apiserver-ready` now pass.

## Step 3: Prove etcd is healthy

```sh
kubectl -n kube-system exec etcd-$NODE -- etcdctl endpoint health --endpoints=https://127.0.0.1:2379 --cacert=/etc/kubernetes/pki/etcd/ca.crt --cert=/etc/kubernetes/pki/etcd/healthcheck-client.crt --key=/etc/kubernetes/pki/etcd/healthcheck-client.key
```

The endpoint reports `is healthy`. Run the grader again. The check `etcd-healthy` passes.

## Step 4: Record the recovery

```sh
kubectl -n starfleet create configmap apiserver-recovery --from-literal=flag=--etcd-servers --from-literal=etcd-client-port=2379
```

Grade it with the same `astrona submit` command. All five checks pass, including `workloads-intact`, which fails if you deleted or recreated the workloads.
