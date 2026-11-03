# Question

Solve this question on: `terminal`

This is the capstone for troubleshooting services and networking: one integrated task, no step-by-step guidance.

Scenario: the `shuttle` pod in `starfleet` must reach the Services `probe` and `scout` in `starfleet` by short name, for example `http://probe/` and `http://scout/`. Both Services listen on port 80. Both Deployments have two replicas and their containers listen on port 8080. Today neither request works.

Requirements:

1. `nslookup probe.starfleet.svc.cluster.local` and `nslookup scout.starfleet.svc.cluster.local` from the `shuttle` pod return the Service cluster IPs.
2. Each Service has two ready endpoints.
3. `wget -q -T 3 -O- http://probe/` and `wget -q -T 3 -O- http://scout/` from the `shuttle` pod print a line that starts with `version=v1`.
4. Ingress to the `probe` and `scout` pods stays restricted. Only the `shuttle` pods may connect, and only on the port the containers listen on. The default-deny policy stays. No pod in another namespace, such as `drifter` in `outpost`, may be allowed.

Rules: do not delete or scale the application Deployments or Services, do not remove readiness probes, and do not change `dnsPolicy` or `dnsConfig`.

`kubectl` already points at the cluster as the cluster administrator.
