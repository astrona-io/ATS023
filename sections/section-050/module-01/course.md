---
draft: true
exam_objectives:
- Troubleshoot services and networking
---
# Service And External Request Troubleshooting

A client resolves the name of a Service and still gets no answer. This module shows how a request travels from the client to the application, which component owns each step, and how to find the first step that fails. The method is the same for every fault: collect evidence in the order of the request, name the broken relationship, change only the object that owns it, and repeat the original request.

## Learning Goals

- Trace discovery, Service selection and backend ports.
- Distinguish readiness from process existence.
- Separate transport, routing and application failures.
- Choose a correction for the first demonstrated broken relationship.

## Before You Start

You need basic Kubernetes knowledge: pods, Deployments, Services, namespaces and `kubectl get` and `kubectl apply`. The playground is a single-node kind cluster running Kubernetes 1.35. Namespace `starfleet` runs a `probe` Deployment with two replicas, a `probe` Service whose selector does not match the pods, and a `shuttle` client pod. Namespace `outpost` runs a `drifter` client pod. Graded labs run in their own clusters, separate from the playground.

## Reading Order

The first part follows an in-cluster request through its five stages and compares selector, readiness and port faults. A lab follows it: you repair a Service selector. The second part adds the stages of an external request through an Ingress and teaches how to tell which component sent a response. A second lab follows: you repair an Ingress that names a missing Service. The third part is a guided practice that repairs the selector in the playground, step by step. The module ends with a summary.

Launch your playground now, and keep it running while you read:

<!-- astrona:playground -->
