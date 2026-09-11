# API Generation Agent Workflow

This is the shared contract for the API-generation custom agents. Repository
design details remain authoritative in `FRAMEWORK_DESIGN.md`.

## Execution order

Run stages sequentially:

1. Static requirement analysis
2. Requirements normalization
3. OpenAPI generation
4. Data-model generation
5. API skeleton generation
6. Test generation

An agent must not execute when its upstream stage is incomplete or invalid.
It must report the missing prerequisite instead of guessing or producing a
success-shaped partial artifact.

## Workspace

The approved root `plan.md` defines `output_root`. Use `generated/` when the
plan does not specify one. Keep coordination artifacts under:

```text
{output_root}/
  generation-context.json
  gap-analysis.md
  analysis-reports/
  openapi-spec/
  staging/
  project/
```

Agents may update `generation-context.json`, `gap-analysis.md`, and their owned
paths only. Write generated application code under `project/`; never overwrite
unrelated source files. If an owned path already exists, follow the plan's
overwrite policy or stop for a decision.

## Gap analysis

`gap-analysis.md` is the only generated artifact that contains full details of
missing fields, missing context, ambiguities, conflicts, or unresolved
decisions. Step 1 creates it, and every stage reads and updates it.

Use stable IDs in the form `GAP-S{stage}-{sequence}`, for example
`GAP-S1-001`. Organize entries by stage:

```markdown
# Gap Analysis

## Stage 1

<a id="gap-s1-001"></a>
### GAP-S1-001 — Short summary

- Status: open
- Type: missing-field
- Source: REQ-001; jira-export.pdf, page 3
- Affected artifacts: requirements-analysis-report.json
- Missing fields or context: Exact details that are absent or unclear.
- Impact: What cannot be specified, generated, or validated.
- Decision needed: The precise question that must be answered.
- Owner: Product owner
- Resolution: Pending

## Stage 2
```

Allowed types are `missing-field`, `missing-context`, `ambiguity`, `conflict`,
and `dependency`. Allowed statuses are `open`, `resolved`, and `deferred`.
Resolving a gap updates the existing entry with the decision, source, owner, and
timestamp; entries are never deleted or renumbered. Put a stable lowercase HTML
anchor immediately before each heading so references remain valid if its summary
changes.

All other generated artifacts contain references only:

- JSON artifacts use `gap_refs`, for example `["GAP-S1-001"]`.
- OpenAPI uses `x-gap-refs` only where a contract element is affected.
- Generated code and tests cite the gap ID in a TODO or disabled-test reason
  only when the gap directly blocks implementation.
- `generation-context.json` records the register path and stage-level gap IDs,
  but never duplicates gap descriptions or missing-field details.

Do not copy gap descriptions into reports, specifications, logs, source files,
tests, warnings, failures, or completion summaries. Refer readers to
`gap-analysis.md#gap-s1-001` for the full context.

## Generation context

`generation-context.json` is the durable handoff contract:

```json
{
  "schema_version": "1.0",
  "project": {
    "name": "",
    "package_root": "",
    "description": "",
    "java_version": 21,
    "spring_boot_version": "3.x",
    "build_tool": "gradle"
  },
  "inputs": [
    {
      "path": "",
      "type": "jira_pdf|openapi|database_schema|architecture|security|other",
      "required": false,
      "sha256": ""
    }
  ],
  "requirements": {
    "acceptance_criteria": [],
    "acceptance_tests": [],
    "functional": [],
    "non_functional": [],
    "endpoints": [],
    "entities": [],
    "integrations": [],
    "feature_matrix": []
  },
  "contracts": {
    "openapi_path": null,
    "models": []
  },
  "generated": {
    "data_model_manifest": null,
    "project_root": null,
    "test_manifest": null
  },
  "stages": {
    "step1": {"status": "pending", "artifacts": [], "gap_refs": [], "validated_at": null},
    "step2": {"status": "pending", "artifacts": [], "gap_refs": [], "validated_at": null},
    "step3": {"status": "pending", "artifacts": [], "gap_refs": [], "validated_at": null},
    "step4": {"status": "pending", "artifacts": [], "gap_refs": [], "validated_at": null},
    "step5": {"status": "pending", "artifacts": [], "gap_refs": [], "validated_at": null},
    "step6": {"status": "pending", "artifacts": [], "gap_refs": [], "validated_at": null}
  },
  "gap_analysis_path": "gap-analysis.md",
  "warnings": [],
  "decisions": [],
  "failures": []
}
```

Requirement records must have stable IDs, source references, and confidence.
Generated endpoints, models, classes, and tests must cite the IDs they satisfy.
Gap details live only in `gap-analysis.md`; all other artifacts carry gap IDs.
Never remove a gap or warning without recording the resolving decision.

## Status and failure rules

Valid stage statuses are `pending`, `in_progress`, `blocked`, `failed`, and
`complete`. Set `in_progress` before writing stage artifacts. Set `complete`
only after validation succeeds. A blocked or failed stage records:

- stage and timestamp
- actionable reason
- affected requirement or artifact IDs
- attempted validation
- required user or upstream action

Do not catch broad failures, silently use placeholder inputs, or mark incomplete
output as valid.

## Stage ownership and gates

| Stage | Owned output | Completion gate |
| --- | --- | --- |
| Step 1 | `gap-analysis.md`, `analysis-reports/requirements-analysis-report.json` | Required PDF parsed; extracted records have IDs and sources; gaps registered and referenced |
| Step 2 | `analysis-reports/normalized-requirements.json` | Endpoints, entities, integrations, and feature matrix validate and trace to Step 1 |
| Step 3 | `openapi-spec/{project}-openapi-3.0.yaml`, `analysis-reports/openapi-validation.json` | OpenAPI 3.x validates; operations and schemas trace to normalized requirements |
| Step 4 | `staging/data-model/`, `analysis-reports/entity-mapping-report.json` | Java model artifacts are internally consistent; schema conflicts are resolved or blocked |
| Step 5 | `project/`, `analysis-reports/code-generation-log.json` | Selected build compiles or all generation-caused failures are fixed |
| Step 6 | Test paths under `project/`, `analysis-reports/test-generation-log.json` | Generated tests compile; executed checks and intentionally blocked tests are distinguished |

Every completion response lists changed artifacts, validation performed, open
gap IDs with a link to `gap-analysis.md`, and the next eligible stage. It must
not duplicate gap details or start the next stage.
