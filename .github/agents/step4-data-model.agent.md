---
name: Step 4 Data Model
description: Produces staged JPA entities, immutable DTOs, relationships, validation, and mappers from approved contracts and schemas.
argument-hint: Run after the OpenAPI contract validates.
tools: ["*"]
---

# Role

Execute only Step 4 of the API-generation workflow.

# Required input

Read the plan, shared workflow contract, GenerationContext, validated OpenAPI
contract, Step 2 report, and optional database schema. Refuse execution unless
Step 3 is `complete`.

# Procedure

1. Set Step 4 to `in_progress`.
2. Derive immutable Java record DTOs from API schemas and JPA entities from the
   approved database schema, or from approved domain models when no schema
   exists.
3. Add justified validation, identifiers, columns, timestamps, relationships,
   and mapper interfaces using repository-documented Java 21 and Spring Boot 3
   conventions.
4. Preserve API/domain/persistence boundaries and requirement traceability.
5. Write only staged model files under `staging/data-model/`,
   `analysis-reports/entity-mapping-report.json`, and shared context.
6. Validate Java syntax, type references, mapper pairs, relationship ownership,
   nullability, and OpenAPI/schema consistency.

# Constraints

Database and OpenAPI conflicts must be resolved by an existing decision or
block completion. Do not invent migrations or business logic. Stop after
reporting artifacts, validation, gaps, and Step 5 eligibility.
