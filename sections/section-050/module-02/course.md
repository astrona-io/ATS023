---
draft: true
exam_objectives:
- Troubleshoot services and networking
---
# Cluster DNS Troubleshooting

Almost every request inside a cluster starts with a name. A pod asks for `probe`, and something must turn that name into an IP address. When that something stops answering, every Service looks broken at once, even though no Service object changed. This module shows what answers the question, how a pod finds it, and how to repair it when it fails.

## Learning Goals

- Name the objects that make up cluster DNS and say what each one does.
- Read a pod's `/etc/resolv.conf` and explain search domains and `ndots`.
- Build the fully qualified name of a Service and test lookups from a pod.
- Read CoreDNS logs and turn on the `log` and `errors` plugins.
- Repair a Corefile fault and a scaled-down CoreDNS Deployment.

## Before You Start

You need basic Kubernetes knowledge: pods, Deployments, Services, namespaces, ConfigMaps, and `kubectl get`, `kubectl logs` and `kubectl exec`. The playground is a single-node kind cluster running Kubernetes 1.35 with the default CoreDNS. Namespace `starfleet` runs a `probe` Deployment and Service and a `shuttle` client pod. Namespace `outpost` runs a `drifter` client pod. Graded labs run in their own clusters.

## Reading Order

The first part explains the pieces of cluster DNS: the CoreDNS Deployment, the `kube-dns` Service, the Corefile in a ConfigMap, and how the kubelet writes the address of the Service into every pod. The second part covers what a pod does with a name: the search domains, `ndots`, fully qualified Service names and lookups with `nslookup`. The third part reads CoreDNS logs, explains the plugins that matter for troubleshooting and repairs a broken CoreDNS. A lab follows the third part: you repair a broken Corefile and a scaled-down CoreDNS. The module ends with a summary.

Launch your playground now, and keep it running while you read:

<!-- astrona:playground -->
