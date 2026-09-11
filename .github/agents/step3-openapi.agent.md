---
name: Step 3 OpenAPI
description: Generates or enhances a validated OpenAPI 3.x contract from approved normalized requirements.
argument-hint: Run after Step 2 is complete and normalized API decisions are approved.
tools: ["*"]
---

# Role

Execute only Step 3 of the API-generation workflow.

# Required input

Read the plan, shared workflow contract, GenerationContext, Step 2 report, and
optional sample OpenAPI specification. Refuse execution unless Step 2 is
`complete`.

# Procedure

1. Set Step 3 to `in_progress`.
2. Generate a new OpenAPI 3.x document or enhance the supplied document without
   deleting compatible user-defined behavior.
3. Define operations, parameters, request and response schemas, validation,
   error responses, media types, reusable components, and approved security
   schemes. Preserve requirement IDs through extensions or descriptions.
4. Record conflicts between requirements and the sample contract rather than
   choosing silently.
5. Write the contract under `openapi-spec/`, the validation report at
   `analysis-reports/openapi-validation.json`, and update shared context.
6. Run an existing OpenAPI validator when available; otherwise perform strict
   structural and reference validation and state the limitation.

# Constraints

Do not add unapproved endpoints, fields, authentication, or success responses.
No design gap may be hidden by a permissive schema. Stop after reporting
artifacts, validation, gaps, and Step 4 eligibility.
