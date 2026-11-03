---
draft: true
exam_objectives:
- Troubleshoot services and networking
---
# Summary

Cluster DNS is four objects that work together. The `coredns` Deployment in `kube-system` runs the server, the `kube-dns` Service gives it a stable address, the `coredns` ConfigMap holds the Corefile, and the kubelet writes the Service address into the `/etc/resolv.conf` of every pod that uses the default `ClusterFirst` policy. A failure at any of the four looks like a failed lookup from the client, so the owner is found from the evidence, not from the symptom.

A pod's resolver decides which names are tried. The `search` line adds the namespace, `svc.cluster.local` and `cluster.local` suffixes, and `ndots:5` makes names with fewer than five dots go through those suffixes first. A Service has the name `service.namespace.svc.cluster.local`. A short name works only inside its own namespace, and a name with the namespace works from anywhere. A name error is an answer from a live server; a timeout is no answer.

The CoreDNS logs and the Corefile give the server's side. The `errors` plugin prints failures and the `log` plugin prints every query. The `kubernetes` plugin answers the cluster zone and must name the correct domain. The `forward` plugin sends all other names to the node resolvers. A scaled-down Deployment leaves the `kube-dns` EndpointSlice empty, and a bad Corefile crashes pods that start after the change.

Repair DNS inside its own objects, read the Corefile before scaling up, and prove the result with a lookup from a pod in the namespace that had the problem. Do not bypass cluster DNS in a workload to hide a cluster fault.

<!-- astrona:playground:destroy -->
