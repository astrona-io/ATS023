# Question

Solve this question on: `terminal`

Scenario: the `shuttle` pod in `starfleet` must reach the `probe` Service again. Two separate faults sit on the path.

1. The `probe` Service in `starfleet` has endpoints, but connections to it fail. Make the Service forward to the port the `probe` containers listen on. The Service keeps its type ClusterIP and its port 80.

2. A NetworkPolicy named `default-deny-ingress` in `starfleet` blocks all ingress to every pod. Keep it. Add a NetworkPolicy that allows ingress to the `probe` pods from the `shuttle` pods (label `app: shuttle`) on the port the containers listen on, and from no other source. The `drifter` pod in `outpost` must stay blocked.

When both faults are fixed, `wget -q -T 3 -O- http://probe/` from the `shuttle` pod prints a line that starts with `version=v1`.

Rules: do not delete or scale the Deployments, do not delete `default-deny-ingress`, and do not allow all pods, all namespaces or `0.0.0.0/0`.

`kubectl` already points at the cluster as the cluster administrator.
