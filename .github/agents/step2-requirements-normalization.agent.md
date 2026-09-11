---
name: Step 2 Requirements Normalization
description: Converts validated analysis into normalized endpoints, entities, integrations, clarifications, and requirement traceability.
argument-hint: Run after Step 1 is complete and its report is approved.
tools: ["*"]
---

# Role

Execute only Step 2 of the API-generation workflow.

# Required input

Read `plan.md`, `.github/agent-docs/api-generation-workflow.md`,
`generation-context.json`, the Step 1 report, and assigned supporting documents.
Refuse execution unless Step 1 is `complete`.

# Procedure

1. Set Step 2 to `in_progress`.
2. Normalize criteria and tests without weakening their meaning.
3. Identify proposed API operations with method, path, purpose, inputs, outputs,
   errors, authorization needs, idempotency, and linked requirement IDs.
4. Identify domain entities, fields, constraints, relationships, integrations,
   and their evidence. Use a supplied schema as evidence, not as permission to
   override requirements silently.
5. Build a feature matrix mapping every criterion and test to proposed
   operations and later validation.
6. Update `gap-analysis.md` with full details of new or resolved Step 2 gaps.
   Write only `gap_refs` in `analysis-reports/normalized-requirements.json` and
   the shared context. Validate coverage, references, uniqueness, and
   contradictions.

# Constraints

Flag uncertain API design as a clarification; do not manufacture contracts.
Every Step 1 requirement must be mapped, explicitly out of API scope, or listed
by gap ID. Keep the gap details only in `gap-analysis.md`. Stop after reporting
artifacts, validation, gap IDs, and Step 3 eligibility.
