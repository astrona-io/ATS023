---
draft: true
exam_objectives:
- Troubleshoot services and networking
---
# Summary

A Service forwards only to the addresses in its EndpointSlices. The EndpointSlice controller builds the slices from the Service selector and lists a pod as ready only when its readiness checks pass. A selector that matches nothing gives an empty slice. A failing readiness probe gives an endpoint that is not ready, and `kube-proxy` stops sending traffic to it while the container keeps running.

Three port numbers must agree. The Service `port` is what clients use, the `targetPort` is where the connection arrives on the pod, and the process in the container must listen on that port. A `containerPort` only declares a port. A wrong `targetPort` leaves healthy-looking endpoints on the wrong port, and the client gets a fast refusal.

Each test cuts the path at a different place. `kubectl port-forward` skips the Service, the endpoints and `kube-proxy`, so it tests the pod alone. A temporary debug pod in the failing namespace tests the path that real clients use, including the resolver and policies when its labels match. A NodePort Service opens a port on every node, and `kube-proxy` programs the rules for both the cluster IP and the node port.

A NetworkPolicy isolates the pods it selects for the directions it lists, and then only allows what its rules name. Policies add together and never deny. A rule uses the pod port, and a rule without a namespace selector matches only the policy's own namespace. A cluster enforces policies only when its network plugin does, so a drop must be shown by a test, not assumed. A dropped connection gives a timeout, and a closed port gives a refusal.

The repair for each fault is small: fix the selector, the target port, the readiness probe or one allow rule. Prove it from the real client, and never delete a deny policy or open every source to end a timeout.

<!-- astrona:playground:destroy -->
