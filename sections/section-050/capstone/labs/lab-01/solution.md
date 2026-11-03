# Solution

Solve this lab on `terminal`. The task has four independent faults. Fix them in the order of the request path.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS023.git -c sections/section-050/capstone/labs/lab-01
export KUBECONFIG="$(astrona kubeconfig ats-023-capstone-050)"
```

## Step 1: DNS

The `coredns` Deployment in `kube-system` is scaled to zero, so no pod answers DNS queries. Scale it back:

```sh
kubectl -n kube-system scale deployment coredns --replicas=2
kubectl -n kube-system rollout status deployment/coredns
kubectl -n starfleet exec deploy/shuttle -- nslookup probe.starfleet.svc.cluster.local
```

The lookup returns the cluster IP of `probe`.

## Step 2: The probe readiness probe

The `probe` pods run, but the Service has no ready endpoints. The readiness probe checks port 9090 while the container listens on 8080:

```sh
kubectl -n starfleet get pods -l app=probe
kubectl -n starfleet describe pod -l app=probe
kubectl -n starfleet patch deployment probe --type=json -p='[{"op":"replace","path":"/spec/template/spec/containers/0/readinessProbe/httpGet/port","value":"http"}]'
kubectl -n starfleet rollout status deployment/probe
```

The pod events show a failed readiness probe on port 9090. After the rollout, both pods are ready.

## Step 3: The scout Service selector

The `scout` Service selects `app: scouts`, but the pods carry `app: scout`. Compare them, then correct the Service:

```sh
kubectl -n starfleet get service scout -o jsonpath='{.spec.selector}{"\n"}'
kubectl -n starfleet get pods -l app=scout --show-labels
kubectl -n starfleet patch service scout --type=merge -p '{"spec":{"selector":{"app":"scout"}}}'
```

A merge patch replaces the value of the `app` key. Check that the EndpointSlice now lists two endpoints:

```sh
kubectl -n starfleet get endpointslices -l kubernetes.io/service-name=scout
```

## Step 4: The NetworkPolicy port

The policy `allow-shuttle-http` allows port 80, which is the Service port. A policy matches the pod port after the Service has translated the request, so the port must be 8080. Edit the policy:

```sh
kubectl -n starfleet edit networkpolicy allow-shuttle-http
```

Change `port: 80` to `port: 8080`. Keep `default-deny-ingress`. Then test both Services:

```sh
kubectl -n starfleet exec deploy/shuttle -- wget -q -T 3 -O- http://probe/
kubectl -n starfleet exec deploy/shuttle -- wget -q -T 3 -O- http://scout/
```

Each prints a line that starts with `version=v1`. Grade the lab with `astrona submit`, then run `astrona destroy ats-023-capstone-050`.
