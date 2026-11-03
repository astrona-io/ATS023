---
draft: true
exam_objectives:
- Troubleshoot services and networking
---
# Troubleshoot services and networking

A request resolves the Service name but times out before receiving an application response. DNS success narrows the investigation without completing it. Find the next unresolved boundary instead of repeating unrelated discovery checks.

This section follows one request through its stages: name lookup, Service selection, endpoints, the port on the pod, network policy and the application. The explanations identify the responsible component at each stage, compare intended and observed state, and show which command proves or rules out that stage. Each module has a playground for practice and a graded lab. A capstone lab combines the faults of all modules, and a knowledge check follows it.

## Modules

The first module covers a request that reaches a Service and a request that enters through an Ingress. It shows how a selector, a port and a backend reference decide where traffic goes.

The second module covers cluster DNS. It explains CoreDNS, the `kube-dns` Service, search domains and `ndots`, and how to read CoreDNS logs and repair the Corefile.

The third module covers what sits behind a Service name. It explains EndpointSlices, `port`, `targetPort` and readiness, how to test a Service with a port-forward, a debug pod and a NodePort, and how a default-deny NetworkPolicy and an allow rule change who can connect.

## Learning Outcomes

- Trace discovery, Service selection and backend ports.
- Distinguish readiness from process existence.
- Separate transport, routing and application failures.
- Choose a correction for the first demonstrated broken relationship.
- Tell a name error from a timeout, and read the search domains of a pod.
- Read CoreDNS logs and repair a faulty Corefile in the ConfigMap.
- Read EndpointSlices to find an empty selector, a wrong target port or an unready pod.
- Cut a failing path in two with a port-forward and a debug pod.
- Write a default-deny policy and a narrow allow rule that uses the pod port.
