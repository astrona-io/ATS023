---
draft: true
exam_objectives:
- Troubleshoot clusters and nodes
---
# Troubleshoot clusters and nodes

A node stops reporting readiness while some existing containers continue running. The reporting path and the container execution path can fail separately. A NotReady condition is therefore a starting symptom rather than one universal diagnosis.

The explanations identify the responsible components, compare intended and observed state, and work through the decisions needed to preserve the requirement. Read the worked examples as reasoning about a proposed system; no environment is started by this section.

Each module begins with its goals and ends with a summary. Reusable YAML knowledge checks follow the section summary and are registered separately for future presentation.

## Learning Outcomes

- Distinguish unready, unschedulable and stale reporting.
- Trace kubelet and runtime dependencies.
- Interpret pressure, trust and connectivity evidence.
- Verify restored node responsibility without undoing intended policy.
