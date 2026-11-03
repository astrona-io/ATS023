---
draft: true
exam_objectives:
- Monitor cluster and application resource usage
---
# Summary

Usage numbers travel from the kubelet, which reads container counters through cAdvisor, to metrics-server, which scrapes each kubelet on a fixed interval and keeps only the latest sample. The API server serves those samples as the `metrics.k8s.io` API through an APIService that points at the metrics-server Service. `kubectl top` and the HorizontalPodAutoscaler are two clients of the same API.

The APIService `Available` condition shows whether the API server can reach the backend. The reason `MissingEndpoints` points at a Pod that is not ready, and `FailedDiscoveryCheck` points at a backend that does not answer. An empty list right after a restart is normal for one sampling interval. Raw requests with `kubectl get --raw` separate a pipeline failure from a client formatting problem.

Most scrape failures come from the connection between metrics-server and a kubelet. A certificate the cluster authority did not sign needs the flag `--kubelet-insecure-tls` in a test cluster, and a node address that cannot be reached needs a different order in `--kubelet-preferred-address-types`. A repair edits one container argument and is proven by a working `kubectl top nodes`, not by a finished rollout.

<!-- astrona:playground:destroy -->
