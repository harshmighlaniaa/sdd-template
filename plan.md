# Plan: Six-Stage API Generation

## Objective

Use the repository's Copilot custom agents to turn a JIRA requirements PDF and
optional supporting documents into a traceable Spring Boot API skeleton. Each
stage owns a defined artifact set, validates its output, updates the shared
GenerationContext, and stops for review before the next stage.

## Inputs

- Required: JIRA requirements PDF containing acceptance criteria, acceptance
  tests, functional requirements, and business rules.
- Optional: OpenAPI YAML or JSON, database schema, architecture and integration
  documents, and security requirements.
- Project decisions: project name, Java package, build tool, output directory,
  Java version, Spring Boot version, and overwrite policy.

Project-specific values and file paths must be filled in by the API Generation
Planner before Step 1 begins. Missing business or security decisions remain
gaps; agents must not invent them.

## Execution plan

1. **Analyze source requirements**
   - Agent: `step1-static-analysis`
   - Produce `analysis-reports/static-analysis-report.json`.
   - Extract stable, source-linked IDs for requirements, criteria, tests,
     non-functional requirements, dependencies, edge cases, and ambiguities.
   - Gate: the required PDF parsed successfully and every extracted record has
     provenance.

2. **Normalize requirements**
   - Agent: `step2-requirements-normalization`
   - Produce `analysis-reports/requirements-analysis.json`.
   - Define proposed endpoints, entities, integrations, clarifications, and the
     feature-to-criteria matrix.
   - Gate: every Step 1 record is mapped, declared out of API scope, or retained
     as an unresolved gap.

3. **Build the API contract**
   - Agent: `step3-openapi`
   - Produce `openapi-spec/{project}-openapi-3.0.yaml` and
     `analysis-reports/openapi-validation.json`.
   - Generate or enhance OpenAPI operations, schemas, validation, errors, and
     approved security schemes.
   - Gate: the OpenAPI document validates and traces to normalized requirement
     IDs.

4. **Generate the data model**
   - Agent: `step4-data-model`
   - Produce staged Java artifacts under `staging/data-model/` and
     `analysis-reports/entity-mapping-report.json`.
   - Generate JPA entities, immutable record DTOs, relationships, validation,
     and mappers.
   - Gate: types and relationships are internally consistent and contract/schema
     conflicts are resolved or explicitly blocked.

5. **Generate the API skeleton**
   - Agent: `step5-code-generator`
   - Produce the Spring Boot application under `project/` and
     `analysis-reports/code-generation-log.json`.
   - Generate build files, thin controllers, services, repositories,
     configuration, exceptions, resources, and explicit business-logic TODOs.
   - Gate: the generated project compiles with no generation-caused failures.

6. **Generate tests**
   - Agent: `step6-test-generator`
   - Produce JUnit 5 tests and configuration under `project/` and
     `analysis-reports/test-generation-log.json`.
   - Generate smoke tests, acceptance-test stubs, fixtures, and existing
     static-analysis integration.
   - Gate: generated tests compile; executable checks pass; tests blocked by
     intentional business-logic TODOs are reported separately.

## Planner handoffs

| Label | Target | Prerequisite |
| --- | --- | --- |
| Run Step 1: Analyze requirements | `step1-static-analysis` | Approved input inventory and readable JIRA PDF |
| Run Step 2: Normalize requirements | `step2-requirements-normalization` | Step 1 complete |
| Run Step 3: Build OpenAPI contract | `step3-openapi` | Step 2 complete |
| Run Step 4: Generate data model | `step4-data-model` | Step 3 complete |
| Run Step 5: Generate API skeleton | `step5-code-generator` | Step 4 complete |
| Run Step 6: Generate tests | `step6-test-generator` | Step 5 complete |

Every handoff points to this plan, the shared contract at
`.github/agent-docs/api-generation-workflow.md`, the current
`generation-context.json`, required upstream artifacts, known gaps, exact
deliverables, and the target completion gate. Handoffs are review-before-send
and never trigger a later stage automatically.

## Error and recovery policy

- Set the current stage to `blocked` when required input or an upstream gate is
  missing, and to `failed` when execution or validation fails.
- Record an actionable reason, affected IDs, attempted validation, and required
  corrective action in GenerationContext.
- Preserve source artifacts and prior valid stage outputs.
- Resume from the failed stage after correction; do not rerun valid upstream
  stages unless their inputs or decisions changed.
