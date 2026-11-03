# Question

Solve this question on: `terminal`

Scenario: the `shuttle` pod in `starfleet` and the `drifter` pod in `outpost` can no longer find the `probe` Service by name.

Repair cluster DNS so that these requests work again:

1. `nslookup probe.starfleet.svc.cluster.local` returns the cluster IP of the `probe` Service from the `shuttle` pod and from the `drifter` pod.
2. `wget -q -T 3 -O- http://probe/` works from the `shuttle` pod, with the short name.

Rules:

- Repair CoreDNS itself. Do not change the `dnsPolicy` or `dnsConfig` of any workload, do not change the `kube-dns` Service, and do not delete or scale the `probe`, `shuttle` or `drifter` Deployments.
- Keep the `errors` and `forward` plugins in the Corefile. CoreDNS must run two ready replicas, as in a normal cluster.

`kubectl` already points at the cluster as the cluster administrator.
