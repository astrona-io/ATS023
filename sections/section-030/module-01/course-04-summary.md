---
draft: true
exam_objectives:
- Monitor cluster and application resource usage
---
# Summary

A declaration, a status and a measurement are three different facts. The specification says what is wanted, the status says what a controller observed, and the Metrics API says how much CPU and memory containers used in a short window. A good diagnosis names the source of each fact and checks the cluster context before it trusts any output.

Requests, limits and usage answer different questions. The scheduler uses requests to place a Pod. The kubelet and the kernel enforce limits, which can throttle CPU or kill a container that exceeds its memory limit. Measured usage informs the choice of both values but changes with every sample.

The effective demand of a Pod is the sum of its regular containers, adjusted for init containers and defaults from a LimitRange. Read the stored Pod and not only the template. A measurement carries a timestamp and a window, so store both when you keep it as evidence.

<!-- astrona:playground:destroy -->
