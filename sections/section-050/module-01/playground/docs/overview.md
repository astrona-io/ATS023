---
draft: true
exam_objectives:
- Troubleshoot services and networking
---
# Guided Practice: Repair A Service Selector

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

<!-- astrona:playground:renew -->

```sh
export KUBECONFIG="$(astrona kubeconfig ats-023-playground-050-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-023-playground-050-01" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.

## Inspect And Explain

The Service selector names a release label that no application Pod has. Both application replicas are healthy, but the Service has no eligible backends.

Inspect the relevant evidence:

```sh
kubectl -n starfleet get service probe -o yaml
kubectl -n starfleet get pods -l app=probe --show-labels
kubectl -n starfleet get endpointslices -l kubernetes.io/service-name=probe -o yaml
```

The Service controller discovers eligible Pods through labels and readiness. A correct client port cannot compensate for a selector that matches no Pods. Compare both selector labels with the template labels, inspect EndpointSlices, then repeat the original request.


Save this as `service-probe.yaml`:

```yaml
apiVersion: v1
kind: Service
metadata:
  name: probe
  namespace: starfleet
spec:
  selector:
    app: probe
    release: probe
  ports:
  - name: http
    port: 80
    targetPort: http
```

Apply the required change:

```sh
kubectl apply -f service-probe.yaml
```

## Verify The Result

Observe the actual result. A denied-request command returns a nonzero status when the denial works. Run denial checks separately from a shell sequence that stops on the first nonzero status.

```sh
kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://probe/
```

Restore the original `probe` Service selector to `app: probe, release: probe`. Keep ClusterIP behavior, client TCP port 80, target port `http` and two healthy replicas. EndpointSlices must contain exactly two ready probe Pod backends and the original client must receive version one.


## Common pitfalls

> [!WARNING]
> A correct target port cannot compensate for a selector matching no Pods. Check both required labels and ready EndpointSlices. Direct Pod access does not verify Service selection.
