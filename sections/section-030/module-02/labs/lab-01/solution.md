---
draft: true
exam_objectives:
- Monitor cluster and application resource usage
---
# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running, and select its kubeconfig:

```sh
astrona run -c .
export KUBECONFIG="$(astrona kubeconfig ats-023-lab-030-02-01)"
```

## Step 1: Find the failing hop

Read the symptom, then the APIService status, then the Pod:

```sh
kubectl top nodes
kubectl get apiservice v1beta1.metrics.k8s.io
kubectl -n kube-system get pods -l k8s-app=metrics-server
```

`kubectl top nodes` reports that the Metrics API is not available. The `AVAILABLE` column of the APIService shows `False`. The metrics-server Pod is not ready.

## Step 2: Read the logs and the arguments

```sh
kubectl -n kube-system logs deployment/metrics-server --tail=20
kubectl -n kube-system get deployment metrics-server -o jsonpath='{range .spec.template.spec.containers[0].args[*]}{@}{"\n"}{end}'
```

The log lines report that the scrape of the kubelet failed because of its certificate. The argument list does not contain `--kubelet-insecure-tls`. The kubelet in kind uses a self-signed serving certificate, so metrics-server needs that flag.

## Step 3: Add the argument

```sh
kubectl -n kube-system patch deployment metrics-server --type=json -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
kubectl -n kube-system rollout status deployment/metrics-server
```

Grade it:

```sh
astrona submit -c . --keep
```

The check `metrics-server-intact` passes. The other checks can still fail for up to one minute, because metrics-server needs one scrape before it has data.

## Step 4: Prove the data flows

```sh
kubectl get apiservice v1beta1.metrics.k8s.io
kubectl top nodes
kubectl get --raw /apis/metrics.k8s.io/v1beta1/namespaces/starfleet/pods
```

If `kubectl top nodes` still reports no metrics, wait a few seconds and run it again. Then grade:

```sh
astrona submit -c .
```

All four checks pass. Remove the lab with `astrona destroy ats-023-lab-030-02-01`.

## Common pitfalls

> [!WARNING]
> Do not delete the Deployment to fix the argument. Do not add the argument twice. A finished rollout is not proof of a repair, so wait for the first scrape and run `kubectl top nodes`.
