---
draft: true
exam_objectives:
- Troubleshoot clusters and nodes
---
# Guided Practice: Recover A Stopped Worker Kubelet

Use a host shell with the private kubeconfig for this module playground. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool.

<!-- astrona:playground:renew -->

```sh
export KUBECONFIG="$(astrona kubeconfig ats-023-playground-010-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-023-playground-010-01" || exit 1
node_name="astro-ats-023-playground-010-01-control-plane"
worker_name="astro-ats-023-playground-010-01-worker"
```

Keep this connection selected. Host-level commands name only this environment's node containers. They do not operate on the host operating system.

## Inspect And Explain

The worker kubelet is stopped intentionally. The API server remains available, so node status and host service state can be compared.

Inspect the current objects before changing them:

```sh
kubectl -n starfleet get pods -o wide
kubectl get nodes -o wide
```

The playground stops the worker kubelet after its fixtures become healthy. Restart that kubelet, leave the worker schedulable and Ready, and record ConfigMap `node-recovery` with component kubelet, the exact worker node name and result ready. Keep all control-plane components running.

Save this as `configmap-node-recovery.yaml`:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: node-recovery
  namespace: starfleet
data:
  component: kubelet
  node: astro-ats-023-playground-010-01-worker
  result: ready
```

Apply the scoped correction:

```sh
podman exec "$worker_name" systemctl start kubelet
kubectl apply -f configmap-node-recovery.yaml
```

## Verify The Result

Wait for the node to report `Ready` again. The kubelet needs a short time to post a fresh status, so a bounded wait is better than a repeated manual check.

```sh
kubectl wait --for=condition=Ready node/"$worker_name" --timeout=240s
```

The command ends when the `Ready` condition is `True`. A matching field in the ConfigMap alone does not prove the repair: the node condition is the evidence that the kubelet reports again. Keep the control plane components running while you work.


## Common pitfalls

> [!WARNING]
> Confirm the private context and exact node names before a change. Check the stated scope and live result. Do not change unrelated components to hide the original fault.
