---
draft: true
exam_objectives:
- Troubleshoot services and networking
---
# Endpoints, Probes And NetworkPolicy

A Service can exist, DNS can resolve it, and a client can still get no answer. The cause is often in the layer between the Service and the pod: the list of endpoints, the port the Service forwards to, the readiness of the pod, or a NetworkPolicy that filters the connection. This module teaches how to read each of these, how to test them with the right tool, and how to repair them.

## Learning Goals

- Read the EndpointSlices of a Service and explain which pods appear in them.
- Find a mismatch between `port`, `targetPort` and the container port.
- Show how a failing readiness probe removes a pod from the endpoints.
- Test a Service with `kubectl port-forward` and a temporary debug pod.
- Write default-deny and allow NetworkPolicies, and state when a cluster enforces them.
- Explain NodePort and the role of `kube-proxy`.

## Before You Start

You need basic Kubernetes knowledge: pods, Deployments, Services, namespaces, labels and selectors. The playground is a single-node kind cluster running Kubernetes 1.35. Namespace `starfleet` runs a `probe` Deployment with two replicas, a `probe` Service that works, a second Service `probe-alt` with a wrong target port, and a `shuttle` client pod. Namespace `outpost` runs a `drifter` client pod. No NetworkPolicy exists at the start. Graded labs run in their own clusters.

## Reading Order

The first part reads EndpointSlices and shows how selectors, readiness probes and the target port decide what a Service forwards to. The second part covers the tools for testing a Service: `kubectl port-forward`, a temporary debug pod, and the NodePort Service type with the role of `kube-proxy`. The third part covers NetworkPolicy: default deny, allow rules, and the condition that the network plugin must enforce them. A lab follows the third part: you repair a wrong target port and an over-broad deny policy. The module ends with a summary.

Launch your playground now, and keep it running while you read:

<!-- astrona:playground -->
