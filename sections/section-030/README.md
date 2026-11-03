---
draft: true
exam_objectives:
- Monitor cluster and application resource usage
---
# Monitor cluster and application resource usage

A `kubectl top` table, a Pod that restarts with exit code 137 and a Deployment that creates no Pods are three symptoms of resource use. This section teaches how to measure usage, how the measurement reaches the terminal, and how requests, limits and namespace policy shape what runs. Each module has a playground for free practice, and a graded lab follows the reading it practises.

## Learning Outcomes

- Compare specification, status, events and metrics, and confirm the context before trusting output.
- Distinguish measured usage from allocation and enforcement.
- Account for the complete workload when you calculate a Pod's resource demand.
- Trace a usage number from the kubelet through metrics-server and the API server to `kubectl top`.
- Read the metrics APIService, query the Metrics API with `kubectl get --raw` and repair a metrics-server that cannot scrape the kubelets.
- Assign a Quality of Service class and explain CPU throttling and memory out-of-memory kills.
- Diagnose an `OOMKilled` container with exit code 137.
- Read a ResourceQuota and a LimitRange, explain a rejection and fix it without removing policy.
- Compare node allocatable capacity with the requests placed on it.

## Modules

The first module separates declarations, status, events and measurements, explains units, requests and limits, and ends with a guided capture of live Pod metrics. The second module covers metrics-server and the Metrics API: the path from the kubelet to `kubectl top`, the APIService, the autoscaler dependency, and the repair of a broken installation. The third module covers requests, limits, Quality of Service, out-of-memory kills, ResourceQuota and LimitRange, and node capacity.

A capstone combines all three modules in one unguided task, and a knowledge check closes the section.
