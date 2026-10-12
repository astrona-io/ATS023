---
draft: true
exam_objectives:
- Manage and evaluate container output streams
---
# Manage and evaluate container output streams

During a rollout, two `probe` replicas can emit messages from different versions. A Deployment-level log shortcut can show only one selected Pod. Useful log diagnosis starts with an explicit Pod, container and time window.

The explanations identify the responsible components, compare intended and observed state, and work through the decisions needed to preserve the requirement. Read the worked examples as reasoning about a proposed system; no environment is started by this section.

Each module begins with its goals and ends with a summary. Reusable YAML knowledge checks follow the section summary and are registered separately for future presentation.

## Learning Outcomes

- Explain standard output and supported log retrieval.
- Select container, instance and observation window.
- Interpret restart and termination evidence.
- Protect sensitive records and preserve useful diagnostics.
