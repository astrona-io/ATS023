---
draft: true
exam_objectives:
- Troubleshoot cluster components
---
# Troubleshoot cluster components

A Deployment is accepted, but its new Pods never receive a node assignment. Request storage succeeded while scheduling did not progress. Naming each component makes that difference explainable.

The explanations identify the responsible components, compare intended and observed state, and work through the decisions needed to preserve the requirement. Read the worked examples as reasoning about a proposed system; no environment is started by this section.

Each module begins with its goals and ends with a summary. Reusable YAML knowledge checks follow the section summary and are registered separately for future presentation.

## Learning Outcomes

- Identify API, controller, scheduler and datastore responsibilities.
- Trace the first failed workload transition.
- Use local static-Pod evidence when API access fails.
- Distinguish component startup from useful dependent operations.
