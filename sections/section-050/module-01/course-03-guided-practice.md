---
draft: true
exam_objectives:
- Troubleshoot services and networking
---
# Guided Practice: Repair A Service Selector

A Service named `probe` exists, both `probe` pods are running, and a request from `shuttle` still gets no answer. This guided practice walks through the whole repair in the playground: connect, collect evidence, name the broken relationship, change one object and prove the result from the original client. Follow the order, because each step removes one explanation before the next.

## Learning objectives

- Collect evidence in a fixed order: Service, pods, EndpointSlices, request.
- Explain why a selector with an extra label matches no pods.
- Repair the selector and prove the repair from the client pod.

## Connect to the playground

A kubeconfig is a file that tells `kubectl`, the Kubernetes command-line tool, which cluster and credentials to use. The playground has its own kubeconfig. The commands below read it and then stop the shell if `kubectl` points at a different cluster, so you cannot change the wrong cluster by mistake.

<!-- astrona:playground:renew -->

```sh
export KUBECONFIG="$(astrona kubeconfig ats-023-playground-050-01)"
test "$(kubectl config current-context)" = "kind-astro-ats-023-playground-050-01" || exit 1
```

Keep this shell for the whole practice. The `test` command is the guard: it exits with an error when the current context is not the playground.

## Reproduce the symptom

Start with the failure itself, from the client that has the problem. The `shuttle` pod in `starfleet` asks for `probe` by its short name:

```sh
kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://probe/
```

The request fails. The `-T 3` flag limits the wait to 3 seconds. The error alone does not say which stage failed, so the next steps look at the objects in the path.

## Collect the evidence

Read the Service, the pods and the EndpointSlices in this order. The order follows the request: the Service says what it wants, the pods show what exists, and the EndpointSlices show what the controller decided.

```sh
kubectl -n starfleet get service probe -o yaml
kubectl -n starfleet get pods -l app=probe --show-labels
kubectl -n starfleet get endpointslices -l kubernetes.io/service-name=probe -o yaml
```

The Service selector has two labels: `app: probe` and `release: missing`. The pods carry only `app: probe`. A selector matches a pod only when every key and value is present on the pod, so the second label excludes both pods. The pods are healthy, so readiness is not the cause. The EndpointSlice controller built a slice for the Service, and the slice has no endpoints. The port mapping is also not the cause here: `targetPort: http` names a container port that exists.

The relationship that broke is selection, and the object that owns it is the Service. Do not change the Deployment: its labels are the reference, and the `Deployment` selector and pods must keep matching each other.

## Repair the selector

The required selector is `app: probe`. The Service keeps port 80, `targetPort: http` and type ClusterIP, so the client address does not change.

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
  ports:
    - name: http
      port: 80
      targetPort: http
```

Apply it:

```sh
kubectl apply -f service-probe.yaml
```

The `kubectl apply` command sends the new Service to the API server. The EndpointSlice controller notices the change and rebuilds the slice from the matching ready pods. The `kube-proxy` rules on each node follow the slice.

## Verify from the original client

Check the controller's decision first, then the real request:

```sh
kubectl -n starfleet get endpointslices -l kubernetes.io/service-name=probe
kubectl -n starfleet exec shuttle -- wget -q -T 3 -O- http://probe/
```

The slice now lists two addresses, one for each ready pod. The request returns a line that starts with `version=v1`. If the slice is still empty, wait a few seconds and run the first command again, because the controller works asynchronously.

A request that fails or times out is a result, not an error in your shell. When you test a path that must be denied, run that command on its own and read its exit status, because a command that returns a nonzero status stops a shell script written with `set -e`.

## What the repair proves and what it does not

The repair proves the selection stage for the original client. It does not prove that the application handles every operation. Direct access to a pod IP would have worked before the repair, so a pod-IP test cannot verify the fix: only a request through the Service name can. The state you want at the end is a ClusterIP Service on port 80, target port `http`, selector `app: probe`, two ready endpoints, and the original two replicas.

You can now repair a selector fault with evidence rather than guesswork, and you know which test proves it. The same method works for any broken relationship: name it from the evidence, change the one object that owns it, and repeat the original request.

## Common pitfalls

> [!WARNING]
> A correct target port cannot compensate for a selector that matches no pods. Check every selector label against the pod labels and read the EndpointSlices. A direct pod request does not verify Service selection, and a request from your own machine does not verify the client in `starfleet`.
