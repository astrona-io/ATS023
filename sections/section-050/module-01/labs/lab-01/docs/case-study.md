---
draft: true
exam_objectives:
- Troubleshoot services and networking
---
# Starting Environment

The Service selector names a release label that no application Pod has. Both application replicas are healthy, but the Service has no eligible backends.

Restore the original `probe` Service selector to `app: probe, release: probe`. Keep ClusterIP behavior, client TCP port 80, target port `http` and two healthy replicas. EndpointSlices must contain exactly two ready probe Pod backends and the original client must receive version one.
