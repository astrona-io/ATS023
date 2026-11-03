---
estimated_duration: 20m
---

# Lab: Collect A Container Error And Fix An Init Container

Graded lab for the multi-container logs module. **Status: UNTESTED - never run against a live cluster.**

The cluster starts with Pod `bridge` (two containers, one logs an error code) and Deployment `shuttle` whose init container fails because `MODE` is `draft`. The task is in `question.md`; the walkthrough is in `solution.md`.

## Run it

```sh
astrona run -c sections/section-040/module-02/labs/lab-01
astrona submit -c sections/section-040/module-02/labs/lab-01
astrona destroy ats-023-lab-040-02-01
```

Authors prove the reference solution with `astrona test -c <lab>`.

## Checks

| Script | What it proves |
| --- | --- |
| `validate-error-report.sh` | ConfigMap `error-report` names container `worker` and the code in the live log of `bridge` |
| `validate-init-container-fixed.sh` | `shuttle` has an available replica and its running Pod finished `fetch-config` with exit code 0 |
| `validate-no-shortcut.sh` | The init container and its check are kept and Pod `bridge` is unchanged |

`validate-no-shortcut.sh` passes on the start state. It fails if the fix removes the init container or changes its check.
