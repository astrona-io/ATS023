---
draft: true
exam_objectives:
- Monitor cluster and application resource usage
---
# Solution

Solve this lab on `terminal`. Start it and select its kubeconfig:

```sh
astrona run -c .
export KUBECONFIG="$(astrona kubeconfig ats-023-capstone-030)"
```

## Metrics

`kubectl top nodes` fails and the APIService `v1beta1.metrics.k8s.io` is not Available. The metrics-server logs show a certificate error for the kubelets. Append the missing argument and wait for the first scrape:

```sh
kubectl -n kube-system patch deployment metrics-server --type=json -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
kubectl -n kube-system rollout status deployment/metrics-server
kubectl top nodes
```

## scout and the starfleet quota

The previous state of a `scout` container is `OOMKilled` with exit code 137. A limit of 200Mi for two replicas does not fit the quota limit total of 768Mi next to `probe`. Raise the quota and the limit:

```sh
kubectl -n starfleet patch resourcequota compute-quota --type=merge -p '{"spec":{"hard":{"limits.memory":"1Gi"}}}'
kubectl -n starfleet set resources deployment/scout --limits=memory=200Mi
kubectl -n starfleet rollout status deployment/scout --timeout=180s
```

## drifter

The ReplicaSet events show that the quota requires memory values and the Pod sets none. Save a LimitRange with defaults as `limitrange-outpost.yaml` (a `LimitRange` named `container-defaults` in `outpost`, type `Container`, `default` memory `64Mi`, `defaultRequest` memory `32Mi`), apply it, then restart the Deployment:

```sh
kubectl apply -f limitrange-outpost.yaml
kubectl -n outpost rollout restart deployment/drifter
```

## The report

Wait until both `probe` and both `scout` Pods appear in the metrics, then store the response:

```sh
sample="$(kubectl get --raw /apis/metrics.k8s.io/v1beta1/namespaces/starfleet/pods)"
kubectl -n starfleet create configmap usage-report --from-literal=source=metrics.k8s.io/v1beta1 --from-literal=podMetricsJson="$sample"
```

Grade with `astrona submit -c .`.
