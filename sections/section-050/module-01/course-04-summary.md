---
draft: true
exam_objectives:
- Troubleshoot services and networking
---
# Summary

A request crosses independently configured stages: name resolution, the Service address, endpoint selection, forwarding to a port and the application itself. A different component owns each stage. CoreDNS answers names, `kube-proxy` programs the forwarding rules, the EndpointSlice controller builds the list of backends, and the application listens on a port. A successful stage rules out its own explanations and nothing else.

Three faults look alike from the client: a selector that matches no pod, pods that are not ready, and a wrong `targetPort`. The evidence tells them apart. A selector fault leaves an empty EndpointSlice next to healthy pods. A readiness fault leaves endpoints that are not ready. A port fault leaves ready endpoints on the wrong port. Each has its own repair, and changing the wrong object does not help.

An external request adds a host name, a listener, a route match and a backend reference. An Ingress object is accepted by the API server whether or not a controller serves it, so acceptance proves nothing about traffic. The status code and body of a response help to find the sender: a controller can answer on its own when no rule matches or when its backend fails.

Always repeat the original request from the original client after a repair. A test from another namespace or from your own machine can bypass the cause. Keep the intended host, port and operation unchanged, and change only the object that the evidence names.

<!-- astrona:playground:destroy -->
