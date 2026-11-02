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

The lab deliberately stops the worker kubelet after its fixtures become healthy. Restart that kubelet, leave the worker schedulable and Ready, and record ConfigMap `node-recovery` with component kubelet, the exact worker node name and result ready. Keep all control-plane components running.

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

Observe the actual result. A denied request returns a nonzero status when the denial works, so run it separately from a shell sequence that stops on error. Status convergence and a successful request establish different parts of the result.

```sh
kubectl wait --for=condition=Ready node/"$worker_name" --timeout=240s
```

Trace a worker readiness failure to its stopped kubelet service and restore it. The commands above deliberately target one environment. Keep its remaining components available so an unrelated failure cannot stand in for the required denial or correction. No example command output is presented as evidence of a completed run. A matching field alone does not establish that a process used it or that a controller reconciled it.


## Common pitfalls

> [!WARNING]
> Confirm the private context and exact node names before a change. Check the stated scope and live result. Do not change unrelated components to hide the original fault.
