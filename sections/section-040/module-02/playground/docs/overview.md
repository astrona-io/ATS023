---
draft: true
exam_objectives:
- Manage and evaluate container output streams
---
# Playground: Multi-Container Logs And Debug Access

This environment is ungraded. Nothing is submitted. It is a single-node Kubernetes 1.35 cluster with the `starfleet` and `outpost` namespaces and four workloads you can read and debug.

## What is running

- Deployment `scout` in `starfleet`: two replicas with the label `app=scout`. Each prints a heartbeat line every five seconds.
- Pod `bridge` in `starfleet`: container `app` writes events to the file `/var/log/app/events.log` on a shared `emptyDir` volume. Container `log-streamer` runs `tail -F` on that file, so the events appear in its standard output.
- Pod `probe` in `starfleet`: container `api` prints a request line, and container `worker` prints an error with the code `E-4417`.
- Pod `shuttle` in `starfleet`: init container `prepare` runs once and finishes, then container `main` runs.

## What to try

1. Run `kubectl -n starfleet logs probe` and read the notice about the default container. Then read each container with `-c`.
2. Read every container of `probe` at once with `--all-containers --prefix`.
3. Read both `scout` replicas with `-l app=scout --prefix --tail=3`.
4. Read the finished init container with `kubectl -n starfleet logs shuttle -c prepare`.
5. Read the sidecar stream with `kubectl -n starfleet logs bridge -c log-streamer` and read the file itself with `kubectl -n starfleet exec bridge -c app -- cat /var/log/app/events.log`.
6. Attach an ephemeral container to `probe` with `kubectl -n starfleet debug -it probe --image=busybox:1.37.0 --target=worker -- sh`, then run `ps` and leave with `exit`.
7. Make a debug copy of `bridge` with `kubectl -n starfleet debug bridge -it --copy-to=bridge-debug --container=app -- sh` and delete the copy when you finish.

Remove the environment with `astrona destroy ats-023-playground-040-02`.
