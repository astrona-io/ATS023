# Overview: Cluster DNS Troubleshooting (Playground)

This is a playground, not a lab. It starts a fresh cluster with the default CoreDNS and a few example workloads, and then waits. There is no task, no `astrona submit` and no pass or fail. Change things, break them, run `astrona destroy`, and start again.

## What is running

- A single-node kind cluster running Kubernetes 1.35. `kubectl` points at it as the cluster administrator.
- The `coredns` Deployment (two replicas), the `kube-dns` Service and the `coredns` ConfigMap in `kube-system`.
- In `starfleet`: the Deployment `probe` (two replicas, listens on 8080), the Service `probe` on port 80, and the client Deployment `shuttle` (BusyBox).
- In `outpost`: the client Deployment `drifter` (BusyBox).

## Things to try

- Read the Corefile and name what each plugin does.
- Read `/etc/resolv.conf` in `shuttle` and in `drifter`, and compare the `search` lines.
- Resolve `probe.starfleet.svc.cluster.local` from both clients and compare the answer with the Service cluster IP.
- Run `wget -q -T 3 -O- http://probe/` from `drifter` and explain the error. Then use `http://probe.starfleet/`.
- Add the `log` plugin to the Corefile, run a few lookups and read the CoreDNS logs.
- Scale `coredns` to zero, look at the `kube-dns` EndpointSlice, run a lookup and scale it back.
- Break the zone on the `kubernetes` line, wait for the reload, and see which lookups still work. Put it back.
- Create a pod with `dnsConfig` that sets `ndots` to 1 and compare its `resolv.conf`.
