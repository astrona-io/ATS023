# Overview: Requests, Limits, OOM Kills And Quotas

This is a playground, not a lab. It has no task and no grading. Start it, inspect the workloads, change the settings and start again.

## What is running

- A single-node kind cluster with Kubernetes 1.35 and metrics-server. `kubectl` is set to the context `kind-astro-ats-023-playground-030-03`.
- In `starfleet`, the ResourceQuota `compute-quota` (`requests.cpu` 1, `requests.memory` 512Mi, `limits.memory` 768Mi, `pods` 10) and the LimitRange `container-limits` (default limit 128Mi, default request 20m CPU and 32Mi memory, maximum 256Mi memory per container).
- `probe` in `starfleet`: requests equal limits for CPU and memory, so it is `Guaranteed`.
- `shuttle` in `starfleet`: a busy loop with a CPU limit of `100m`, so the kernel throttles it.
- `scout` in `starfleet`: allocates about 150 MiB with a memory limit of 96 MiB, so it is `OOMKilled` and restarts.
- In `outpost`, the ResourceQuota `outpost-quota` and the Deployment `drifter` with two replicas. `drifter` sets no requests or limits and `outpost` has no LimitRange, so the quota rejects its Pods.

## What to try

- Read the class of every Pod with `kubectl -n starfleet get pods -o custom-columns=NAME:.metadata.name,QOS:.status.qosClass`.
- Read `lastState.terminated` of the `scout` Pod and find the reason and the exit code.
- Raise the `scout` limit with `kubectl -n starfleet set resources deployment/scout --limits=memory=200Mi` and watch it run. Then raise it to `512Mi` and read the LimitRange error from the ReplicaSet events.
- Compare `kubectl top pods -n starfleet` with the CPU limit of `shuttle`, and read `/sys/fs/cgroup/cpu.stat` inside it.
- Read `kubectl -n outpost describe quota` and the ReplicaSet events of `drifter`. Fix `drifter` once by adding a LimitRange and once by setting resources in the Deployment.
- Read `kubectl describe node` and compare the allocated requests with the allocatable memory.
