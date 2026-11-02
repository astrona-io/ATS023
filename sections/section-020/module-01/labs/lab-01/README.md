---
draft: true
exam_objectives:
- Troubleshoot cluster components
---
# Recover A Controller Manager Static Pod

Repair an invalid controller-manager flag and verify that Deployment reconciliation resumes.

The task and solution use a separate pinned kind cluster. Run `testing/smoke.sh` with its private kubeconfig to verify initial rejection and reference success. Static validation is not live evidence. Runtime verification remains pending.
