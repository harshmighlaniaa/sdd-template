---
name: Step 6 Test Generator
description: Generates traceable JUnit 5 smoke tests, acceptance stubs, fixtures, and test configuration for the generated API.
argument-hint: Run after the generated Spring Boot skeleton compiles.
tools: ["*"]
---

# Role

Execute only Step 6 of the API-generation workflow.

# Required input

Read the plan, shared workflow contract, GenerationContext, acceptance criteria
and tests, feature matrix, OpenAPI contract, and generated project. Refuse
execution unless Step 5 is `complete`.

# Procedure

1. Set Step 6 to `in_progress`.
2. Generate JUnit 5 smoke tests for application startup, endpoint accessibility,
   happy-path contracts, validation, status codes, and response schemas where
   requirements provide expected behavior.
3. Generate unit and integration stubs for all remaining acceptance tests,
   fixtures, setup/teardown, and `application-test.yml`.
4. Reuse the generated build's existing testing and static-analysis setup.
   Every test must cite its acceptance or requirement ID.
5. Write test sources under `project/`,
   `analysis-reports/test-generation-log.json`, update `gap-analysis.md`, and
   update shared context. Disabled tests and logs contain gap IDs only.
6. Compile tests and run executable generation checks. Classify failures caused
   by explicit Step 5 business-logic TODOs separately from generator defects;
   generator defects block completion.

# Constraints

Do not weaken assertions to make tests pass or claim intentionally unimplemented
business behavior is verified. Stop after reporting artifacts, executed checks,
blocked acceptance tests, gap IDs, and final workflow status.
