---
draft: true
exam_objectives:
- Troubleshoot services and networking
---
# Repair A Missing Ingress Backend Solution

Use a host shell with this lab's private kubeconfig. A kubeconfig identifies the cluster and credentials used by kubectl, the Kubernetes command-line tool. This environment is separate from the ungraded playground.

```sh
export KUBECONFIG="$(astrona kubeconfig ats-023-lab-050-01-02)"
test "$(kubectl config current-context)" = "kind-astro-ats-023-lab-050-01-02" || exit 1
```

Keep this connection selected throughout the task. Every script supplied by the lab refuses a different context.

## Inspect And Explain

The lab includes a working Traefik Ingress controller and healthy application. The seeded route points at a nonexistent Service.

Inspect the relevant evidence:

```sh
kubectl -n starfleet get ingress
kubectl -n starfleet get service probe
kubectl -n ingress-system logs deployment/traefik --tail=20
```

The Ingress backend names a Service and one of its client-facing ports. Healthy Pods do not help when the route names a Service that does not exist. Inspect the reference, controller evidence and Service before changing the route. Repeat the routed request after correction.


Save this as `ingress-probe.yaml`:

```yaml
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: probe
  namespace: starfleet
spec:
  ingressClassName: traefik
  rules:
  - host: probe.local
    http:
      paths:
      - path: /
        pathType: Prefix
        backend:
          service:
            name: probe
            port:
              number: 80
```

Apply the required change:

```sh
kubectl apply -f ingress-probe.yaml
```

## Verify The Result

Observe the actual result. A denied-request command returns a nonzero status when the denial works. Run denial checks separately from a shell sequence that stops on the first nonzero status.

```sh
kubectl -n starfleet exec deployment/probe -- python -c 'import urllib.request,urllib.error; request=urllib.request.Request('"'"'http://traefik.ingress-system.svc/'"'"',headers={'"'"'Host'"'"':'"'"'probe.local'"'"'}); print(urllib.request.urlopen(request,timeout=5).read().decode())'
kubectl -n starfleet exec deployment/probe -- python -c 'import urllib.request,urllib.error; request=urllib.request.Request('"'"'http://traefik.ingress-system.svc/'"'"',headers={'"'"'Host'"'"':'"'"'unmatched.local'"'"'});
try: urllib.request.urlopen(request,timeout=5); raise RuntimeError('"'"'Unexpected matched route'"'"')
except urllib.error.HTTPError as error: print(error.code)'
```

Create an Ingress `probe` for class `traefik`, host `probe.local`, Prefix path `/` and backend Service `probe` port 80. The request through the controller with the matching Host header must receive version one. An unmatched host must return 404. Preserve the original application and Service.

After recording the result, remove this independent lab with `astrona destroy ats-023-lab-050-01-02`.

## Common pitfalls

> [!WARNING]
> The backend names a Service, not a Deployment or Pod. Refer to the Service port rather than the container port. Healthy Pods cannot repair a nonexistent backend reference.
