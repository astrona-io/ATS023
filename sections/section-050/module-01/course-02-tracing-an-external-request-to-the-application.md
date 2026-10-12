---
draft: true
exam_objectives:
- Troubleshoot services and networking
---
# Tracing An External Request To The Application

The frontend returns a routing error before the application logs a request. The request reached an intermediary, but that does not prove it reached `probe`. Diagnose hostname, path, certificate and backend selection as separate boundaries.

## Learning objectives

- Trace discovery, Service selection and backend ports.
- Distinguish readiness from process existence.
- Separate transport, routing and application failures.

## Before you start

This chapter is standalone reading material; no running cluster or installed tools are required. A Pod is the Kubernetes unit for running one or more containers, and a namespace groups namespaced objects. Treat the worked configurations as teaching examples rather than recorded observations from a provisioned environment.

## Responsible components and behavior

An external application request crosses several independently configured relationships. A client resolves a hostname, reaches an entry point, matches a route, reaches a Service backend and receives an application response. Diagnosing that path means finding the first relationship that fails, rather than changing every object that mentions the application's name.

## Begin With The Client Observation

A hostname resolution failure occurs before an ordinary request can reach the intended controller address. Domain Name System (DNS) records and client lookup behavior should be considered first. Changing a Deployment replica count cannot repair a missing external hostname record.

A connection timeout can mean the selected address is unreachable or filtered, or that the listener and network path do not accept the connection. It does not by itself identify a wrong Ingress path. Host and path routing decisions generally happen only after the request reaches an appropriate listener.

A certificate error concerns the secure connection contract. Transport Layer Security (TLS) verification can fail because the name, trust chain or validity does not satisfy the client. Ignoring verification may change a diagnostic observation but does not establish that the intended secure access has been configured correctly.

## Identify Who Produced The Response

A not-found response can come from the entry controller's default handling or from the application after a successful route. A server-side gateway error can reflect upstream connection failure rather than a process refusing an application operation. Status alone is therefore a clue; response identity and route or backend evidence help locate its source.

Check whether the selected Ingress belongs to the class handled by the running controller. A valid resource accepted by the application programming interface (API) server can still be ignored by that controller. Admission success and traffic configuration are different stages.

Compare the actual request host and path with the route. A test using only an address can send a host value different from the declared application hostname. An `Exact` rule for `/reports` does not behave like a prefix rule covering subordinate paths. The diagnostic request should represent the intended consumer's operation.

## Inspect Service And Endpoint Relationships

The Ingress backend refers to a Service and one of its exposed ports. That Service must select the intended Pods or use another valid backend arrangement. EndpointSlice resources describe Service backend information for supported cases. A Service with no ready eligible endpoints can exist and have the expected name while providing no useful application capacity.

A Pod readiness failure and a selector mismatch can both produce missing usable backends, but they have different corrections. If labels do not match, changing readiness thresholds will not select the Pod. If a correct Pod is unready because a dependency is absent, relabelling it will not make it safe to serve traffic.

Port names and numbers need consistent mapping. The Service's `port` belongs to the client-facing Service contract; `targetPort` identifies the backend listener according to its supported representation. A declared container port documents the Pod configuration but does not make the process bind that port.

## Examine The Remaining Network And Application Path

NetworkPolicy can control allowed connections to or from selected Pods when the network implementation enforces it. Evaluate the controller-to-backend source and the backend's applicable policies, not just an assumed external client address. Source representation can depend on the traffic path and implementation.

The application must listen on an address reachable through the Pod network. Listening only on loopback can support requests from another container in the same Pod while preventing ordinary requests to the Pod address. A successful local health test does not prove that the Service backend target is reachable.

Finally, inspect the path and protocol the application receives. A route match can deliver a path that the backend does not recognize, and TLS termination can leave a plain backend protocol unless additional configuration changes it. Correct the broken relationship while preserving the intended host, path and security contract. Then evaluate a meaningful application response, rather than only the existence of a network object.

## Work through the decision

Traefik can respond when no route matches or when its backend path fails. An application can also return an error after the controller successfully forwards to it. The response status alone does not identify the failing component. Compare route configuration, controller evidence, backend endpoints and application records.

For TLS, the client needs a certificate chain it trusts and a hostname covered by that certificate. The practice uses a local certificate with a Subject Alternative Name (SAN) for `probe.local`. The trusted matching name should succeed, while a different hostname should fail verification. Disabling verification would remove the property being tested. The local certificate is temporary practice trust, not a production public certificate deployment.

```mermaid
flowchart TB
    C["Client trust and hostname"] --> T["TLS frontend connection"]
    T --> R["Ingress route match"]
    R --> S["Service and endpoints"]
    S --> A["Application handler"]
    A --> O["Attributed response"]
```

Frontend trust, route matching and backend processing can fail independently along one external request.

You can now attribute an external symptom to a specific request boundary. Repeat the intended hostname and operation with verification enabled after correcting the responsible setting.

## Common pitfalls

> [!WARNING]
> Distinguish client lookup, transport, route matching, backend selection and application errors. A valid Ingress resource or Running Pod does not prove the full external request path works.
