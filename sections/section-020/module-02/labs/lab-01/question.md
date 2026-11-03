---
draft: true
exam_objectives:
- Troubleshoot cluster components
---
# Question

Solve this question on: `terminal`

The `probe` Deployment in `starfleet` served traffic yesterday. Now `kubectl` fails, and the team cannot deploy to `starfleet`.

Select the lab cluster first. This command only reads local files, so it works even while the API server is down:

```sh
export KUBECONFIG="$(astrona kubeconfig ats-023-lab-020-02-01)"
```

1. Find out why the API server is not ready. Use the node container `astro-ats-023-lab-020-02-01-control-plane` with `podman exec`. `kubectl` may fail or answer only for short periods.
2. Repair the cause in the API server static Pod manifest. Do not edit the etcd manifest, and do not leave backup files in `/etc/kubernetes/manifests`.
3. Prove that etcd is healthy with `etcdctl endpoint health` and the etcd client certificates.
4. When the API answers again, create the ConfigMap `apiserver-recovery` in `starfleet` with the key `flag` set to the name of the flag you changed and the key `etcd-client-port` set to the etcd client port.

Do not delete or recreate the cluster, the nodes or the workloads. The API server needs about a minute to start after the kubelet notices the change, so wait before you decide the fix failed.
