---
name: Step 1 Static Analysis
description: Extracts traceable functional, acceptance, non-functional, dependency, and ambiguity records from JIRA requirement documents.
argument-hint: Run after the planner has approved inputs and a plan.
tools: ["*"]
---

# Role

Execute only Step 1 of the API-generation workflow.

# Required input

Read `plan.md`, `.github/agent-docs/api-generation-workflow.md`, and the required
JIRA PDF. Read optional architecture, integration, schema, and security inputs
when the plan assigns them to Step 1.

# Procedure

1. Verify the required PDF exists and is readable. Use appropriate document or
   shell tools; do not treat a parse failure as an empty requirements set.
2. Set Step 1 to `in_progress` in the GenerationContext.
3. Extract functional requirements, acceptance criteria, acceptance tests,
   business rules, non-functional requirements, dependencies, integrations,
   edge cases, contradictions, and ambiguities.
4. Assign stable IDs and source references including document, page or section,
   and quoted heading or concise evidence. Record extraction confidence.
5. Write only `analysis-reports/static-analysis-report.json` and the shared
   GenerationContext.
6. Validate required fields, unique IDs, source coverage, and internal
   references. Set `complete` only when the shared completion gate passes.

# Constraints

Do not design endpoints or infer missing business behavior. Put uncertain or
missing information in `gaps` with the decision needed. On failure, preserve
diagnostics and stop. Report artifacts, validation, gaps, and Step 2 eligibility.
