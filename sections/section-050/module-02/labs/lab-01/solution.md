# Solution

Solve this lab on `terminal`. Each step ends with `astrona submit`. The `--keep` flag keeps the lab running so you can continue after a failed check.

Start the lab if it is not running:

```sh
astrona run --git ssh://git@github.com/astrona-io/ATS023.git -c sections/section-050/module-02/labs/lab-01
export KUBECONFIG="$(astrona kubeconfig ats-023-lab-050-02-01)"
```

## Step 1: Find the first failure

A client asks the `kube-dns` Service, and the Service sends the request to a CoreDNS pod. Check that a CoreDNS pod exists first:

```sh
kubectl -n kube-system get deployment coredns
kubectl -n kube-system get pods -l k8s-app=kube-dns
kubectl -n kube-system get endpointslices -l kubernetes.io/service-name=kube-dns
```

The Deployment shows `0/0` ready, the pod list is empty, and the EndpointSlice has no endpoints. No pod answers DNS queries, so every lookup times out. This is the first broken relationship.

## Step 2: Read the Corefile before you scale up

Scaling up first would start pods that run a faulty configuration. Read the Corefile:

```sh
kubectl -n kube-system get configmap coredns -o jsonpath='{.data.Corefile}'
```

The `kubernetes` plugin line says `kubernetes cluster.locall in-addr.arpa ip6.arpa`. The plugin answers only for the zone that it names, so no `svc.cluster.local` name matches. CoreDNS then forwards those names to the node resolvers, which do not know them.

## Step 3: Correct the zone

Edit the ConfigMap and change `cluster.locall` to `cluster.local`:

```sh
kubectl -n kube-system edit configmap coredns
kubectl -n kube-system get configmap coredns -o jsonpath='{.data.Corefile}' | grep kubernetes
```

The second command prints the `kubernetes cluster.local in-addr.arpa ip6.arpa {` line. Grade it:

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS023.git -c sections/section-050/module-02/labs/lab-01 --keep
```

The check `corefile-zone` passes. The other checks still fail because no pod runs.

## Step 4: Scale CoreDNS back to two replicas

```sh
kubectl -n kube-system scale deployment coredns --replicas=2
kubectl -n kube-system rollout status deployment/coredns
```

The new pods read the corrected Corefile when they start. Prove the lookup from both namespaces:

```sh
kubectl -n starfleet exec deploy/shuttle -- nslookup probe.starfleet.svc.cluster.local
kubectl -n outpost exec deploy/drifter -- nslookup probe.starfleet.svc.cluster.local
kubectl -n starfleet exec deploy/shuttle -- wget -q -T 3 -O- http://probe/
```

Both lookups return the cluster IP of `probe`, and the last command prints a line that starts with `version=v1`.

## Step 5: Grade and clean up

```sh
astrona submit --git ssh://git@github.com/astrona-io/ATS023.git -c sections/section-050/module-02/labs/lab-01
astrona destroy ats-023-lab-050-02-01
```

All four checks pass. Do not change `dnsPolicy` or `dnsConfig` to point pods at another resolver: the `dns-not-bypassed` check fails, and the cluster stays broken for every other pod.
