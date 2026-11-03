# Overview: Endpoints, Probes And NetworkPolicy (Playground)

This is a playground, not a lab. It starts a fresh cluster with a few workloads and Services, and then waits. There is no task, no `astrona submit` and no pass or fail. Change things, break them, run `astrona destroy`, and start again.

## What is running

- A single-node kind cluster running Kubernetes 1.35. `kubectl` points at it as the cluster administrator.
- In `starfleet`: the Deployment `probe` (two replicas, container port 8080 named `http`, readiness probe on `/ready`), the Service `probe` (port 80, target port `http`), the Service `probe-alt` (port 80, target port 9090, which is wrong on purpose) and the client Deployment `shuttle` (BusyBox).
- In `outpost`: the client Deployment `drifter` (BusyBox).
- No NetworkPolicy. The `probe` pods create `/tmp/not-ready` to turn the readiness answer to 503.

## Things to try

- Compare the EndpointSlices of `probe` and `probe-alt`. Which ports do they list?
- Fix `probe-alt` by changing its target port, and call it from `shuttle`.
- Make one `probe` pod unready with `touch /tmp/not-ready`, watch the slice, and restore it.
- Break the `probe` selector by adding a label that no pod has, read the empty slice, and repair it.
- Forward a local port to a `probe` pod and call it with `curl`.
- Run a temporary BusyBox pod in `outpost` with `kubectl run --rm -i --restart=Never` and call `probe.starfleet`.
- Create a NodePort Service and call the node address and port from `shuttle`.
- Apply a default-deny ingress policy and test whether the request fails. If it does not, the network plugin does not enforce policies.
- Allow only `shuttle` on port 8080, and check that `drifter` stays blocked. Then try to allow `drifter` with a namespace selector.
