---
draft: true
exam_objectives:
- Monitor cluster and application resource usage
---
# Monitor cluster and application resource usage

The `probe` Deployment requests two replicas, its status reports current availability, and metrics report recent resource usage. These are three different observations. Choosing the right one makes a troubleshooting claim precise.

The explanations identify the responsible components, compare intended and observed state, and work through the decisions needed to preserve the requirement. Read the worked examples as reasoning about a proposed system; no environment is started by this section.

Each module begins with its goals and ends with a summary. Reusable YAML knowledge checks follow the section summary and are registered separately for future presentation.

## Learning Outcomes

- Compare specification, status, events and metrics.
- Confirm observation context and permissions.
- Distinguish measured usage from allocation and enforcement.
- Account for complete workload capacity requirements.
