# API Specification Framework

## Purpose

Use this framework when creating or reviewing OpenAPI contracts for generated
APIs. It captures reusable conventions from the reference specification without
prescribing business-specific resources or endpoints.

The contract is the source of truth for request validation, generated DTOs,
controller interfaces, client generation, tests, and API documentation. A
requirement that cannot be represented in OpenAPI must be stated in a
description and mapped to an executable test.

## OpenAPI baseline

- Use OpenAPI `3.0.3` or a later version supported by the selected generators.
- Define `info.title`, `info.version`, and a concise service description.
- Expose relative server URLs so deployment hosts remain environment-specific.
- Serve and accept `application/json` unless a requirement explicitly needs
  another media type.
- Group operations by audience or capability with tags.
- Give every operation a stable, unique, lower-camel-case `operationId`.
- Put reusable schemas, parameters, responses, examples, and security schemes
  under `components`.

## Base path and resource paths

Use this logical path structure:

```text
/{service-base}/{audience}/api/v{major}/{resources}
```

Apply these rules:

- Keep the deployment-specific service prefix in `servers[].url`.
- Keep the API audience, major version, and resource path in `paths`.
- Use lowercase path segments and hyphens for multiword segments.
- Use plural nouns for collections and identifiers for individual resources.
- Model hierarchy through resource relationships rather than action-heavy path
  names.
- Do not place environment names, hostnames, implementation technologies, or
  minor/patch versions in paths.
- Introduce a new major path version only for a breaking contract change.
- Do not repeat a segment already supplied by `servers[].url`.

## HTTP methods

- Use `GET` for safe, idempotent retrieval where filters fit clearly in query
  parameters.
- Use `POST` for creation or for complex searches requiring a structured JSON
  body. Describe search operations as safe when they do not mutate state.
- Use `PUT` for complete replacement and `PATCH` for partial updates.
- Use `DELETE` for removal and state whether repeated deletion is idempotent.
- Do not choose a method solely to work around URL-length or framework
  limitations; record the reason for a body-based search.

## Parameter design

### Parameter location

| Input | Location | Rule |
| --- | --- | --- |
| Resource identity | Path | Required and validated by format |
| Simple filtering or lookup | Query | Optionality and combination rules must be explicit |
| Complex filtering or lists | JSON body | Define a reusable request schema |
| Authentication | Header via security scheme | Do not define ad hoc token parameters |
| Correlation or tracing | Header | Use a reusable parameter and document propagation |

Parameter names and JSON properties use `lowerCamelCase`. Schema names use
`UpperCamelCase`. Enum values use `UPPER_SNAKE_CASE`.

### Alternative identifiers

When a resource may be located by more than one identifier:

- document whether exactly one, at least one, or a priority order is required;
- reject unsupported combinations with `400`;
- apply the same normalization and authorization regardless of identifier;
- never silently choose one conflicting identifier over another; and
- use schema-level constraints where supported and an operation description
  plus tests where OpenAPI cannot express the cross-field rule.

### Query semantics

Every query parameter must define:

- type and format;
- whether it is required;
- accepted values or validation constraints;
- case sensitivity and normalization;
- repeated-value or array serialization behavior;
- interaction with other parameters;
- default behavior when omitted; and
- an example that satisfies all constraints.

Unknown query parameters should be rejected when the server framework supports
strict binding. Empty strings are not equivalent to an omitted value unless the
contract explicitly says so.

## Data validation

Validation belongs in component schemas so generated server and client models
share the same rules.

### Common scalar profiles

| Value category | OpenAPI constraints |
| --- | --- |
| UUID | `type: string`, `format: uuid` |
| Timestamp | `type: string`, `format: date-time`, UTC examples |
| Epoch timestamp | `type: integer`, `format: int64`, unit stated explicitly |
| Tenant or account code | Uppercase alphanumeric pattern with an explicit length bound |
| Registration-like identifier | Uppercase alphanumeric pattern with a domain-approved length |
| VIN-like identifier | Exactly 17 uppercase characters, excluding ambiguous letters |
| Count | `type: integer`, `minimum: 0` |
| Percentage | Numeric type, `minimum: 0`, `maximum: 100` |
| Bounded score | Integer with documented `minimum`, `maximum`, and meaning of each value |
| Latitude | Numeric type, `minimum: -90`, `maximum: 90` |
| Longitude | Numeric type, `minimum: -180`, `maximum: 180` |
| Currency amount | Decimal representation and currency/rounding rules stated explicitly |

Do not rely on descriptions alone for machine-enforceable bounds. Add
`minLength`, `maxLength`, `pattern`, `minimum`, `maximum`, `minItems`,
`maxItems`, and `uniqueItems` as applicable.

### Objects

- List mandatory fields in `required`; property presence is optional otherwise.
- Use `nullable: true` only when `null` has a distinct documented meaning.
- Distinguish an omitted collection from an empty collection.
- Consider `additionalProperties: false` for request objects when forwards
  compatibility does not require unknown fields.
- Use `$ref` for shared identifiers, metadata, counts, paging, and errors.
- Describe business invariants that OpenAPI cannot enforce, such as one count
  equalling the sum of category counts.

### Arrays

- Define `items` for every array.
- Use `minItems: 1` for a required filter list that must not be empty.
- Use `uniqueItems: true` when duplicates have no valid meaning.
- State whether order is stable and meaningful.
- State how invalid, duplicate, or unauthorized members affect the whole
  request; default to rejecting the request rather than partially applying it.

### Enums

- Use enums for closed status, category, and source-code sets.
- Document the meaning of each value in the schema description.
- Include an `UNKNOWN` value when upstream data can introduce an unrecognized
  value and clients must remain compatible.
- Treat removal or semantic reuse of an enum value as a breaking change.

### Cross-field and scope validation

Document and test rules such as:

- an optional child identifier must belong to the supplied parent scope;
- the caller must be authorized for every requested scope;
- aggregate totals must match their component counts;
- only one alternative identifier may be supplied; and
- nested-scope queries include or exclude descendants consistently.

Return `400` for malformed values or contradictory inputs, `403` for valid
identities outside the caller's authorization, and `404` only when revealing
non-existence does not leak protected information.

## Pagination

Use page-number pagination for bounded administrative datasets. Prefer cursor
pagination for high-volume or rapidly changing datasets.

### Page-number contract

Request fields:

| Field | Type | Rule |
| --- | --- | --- |
| `pageNumber` | integer | Optional, one-based, default `1`, minimum `1` |
| `pageSize` | integer | Optional, default `50`, minimum `1`, maximum set by service policy |

Response fields:

| Field | Type | Rule |
| --- | --- | --- |
| `pageNumber` | integer | Same one-based value used for the request |
| `pageSize` | integer | Effective size after applying defaults |
| `totalElements` | integer | Non-negative total matching the filters |
| `totalPages` | integer | Non-negative page count derived from effective size |

Return collection results as:

```json
{
  "data": [],
  "page": {
    "pageNumber": 1,
    "pageSize": 50,
    "totalElements": 0,
    "totalPages": 0
  }
}
```

Additional rules:

- Never mix zero-based and one-based page numbering.
- Reject a page size above the documented maximum with `400`; do not silently
  clamp it.
- Return `200` with an empty `data` array for an empty collection page.
- Define a stable default sort and deterministic tie-breaker.
- Keep filter and sort semantics stable between pages.
- Use `204` only for a successful single-resource lookup with no representation,
  not for an empty collection.

### Cursor contract

When cursor pagination is selected, define opaque `cursor` and `nextCursor`
values, a bounded `pageSize`, cursor expiry behavior, and invalid-cursor errors.
Clients must not parse or construct cursors.

## Response conventions

### Success

- Use `200` for successful retrieval or body-based search.
- Use `201` for creation and provide the resource location where applicable.
- Use `202` only for accepted asynchronous work with a status resource.
- Use `204` for successful operations that intentionally have no response body.
- Return typed response schemas for all responses with content.
- Include realistic examples for normal, empty, and important edge cases.

### Errors

Define reusable responses for at least:

| Status | Meaning |
| --- | --- |
| `400` | Invalid parameters, payload, or cross-field combination |
| `401` | Missing, expired, or invalid authentication |
| `403` | Authenticated caller lacks permission |
| `404` | Resource is not found and disclosure is safe |
| `409` | Request conflicts with current resource state |
| `429` | Rate limit exceeded |
| `500` | Unexpected internal failure |
| `502` / `503` / `504` | Upstream or availability failure when exposing that distinction is useful |

Use one error shape consistently:

```yaml
type: object
required: [code, message]
properties:
  code:
    type: string
    description: Stable machine-readable error code.
  message:
    type: string
    description: Safe human-readable explanation.
  traceId:
    type: string
    description: Correlation identifier for support.
  details:
    type: array
    items:
      $ref: "#/components/schemas/ValidationError"
```

Error messages must not expose tokens, authorization relationships, stack
traces, database keys, or upstream implementation details. Map upstream
failures to the most accurate gateway or availability status rather than
describing every dependency failure as an internal error.

## Security and authorization

- Define bearer authentication once as an HTTP bearer security scheme with the
  expected token format.
- Apply security globally when all operations share it; override only deliberate
  public operations.
- Treat authentication and authorization as separate checks.
- Validate authorization for the requested tenant, parent, child, and resource
  scope before returning data.
- Return only authorized records; never reveal hidden parents or siblings
  through hierarchy metadata.
- Document whether partial authorization rejects the request or filters results.
- Do not include example tokens or secrets in the specification.

## Descriptions, examples, and metadata

- Summaries state the capability, not an implementation detail.
- Descriptions define scope, hierarchy behavior, omission semantics,
  authorization filtering, aggregation, and invariants.
- Examples must satisfy the declared schema and must use fictional data.
- Timestamps identify their format and timezone; epoch values identify their
  unit.
- Metadata such as trace ID, schema version, and generation timestamp should use
  a reusable component when included across payloads.
- Do not promise ordering, freshness, or descendant aggregation unless the
  service implements and tests it.

## Compatibility rules

Usually non-breaking:

- adding an optional response property;
- adding an optional request property with no behavior change;
- adding a new operation; and
- broadening a documented numeric range where clients tolerate it.

Breaking:

- removing or renaming a field or operation;
- making an optional input required;
- narrowing a valid range or pattern;
- changing identifier, paging, sorting, or nullability semantics;
- changing the meaning of an enum value; and
- adding an enum value when generated clients use closed enums without an
  unknown-value strategy.

Breaking changes require a new major API version or an approved migration plan.

## Generation and review checklist

Before approving a specification:

1. Validate the document with the repository's OpenAPI validator.
2. Confirm every operation has a unique `operationId`, tags, security, request
   contract, success response, and reusable error responses.
3. Confirm all examples validate against their schemas.
4. Confirm request constraints are represented as keywords, not prose only.
5. Confirm alternative-identifier and cross-field rules have negative tests.
6. Confirm pagination uses one indexing convention and enforces a maximum size.
7. Confirm required, optional, nullable, empty, and omitted states are distinct.
8. Confirm all `$ref` values resolve and component names are unique.
9. Confirm errors use one shape and do not leak implementation details.
10. Confirm generated Java types preserve formats, constraints, enum handling,
    nullability, and collection semantics.
11. Map each operation and validation rule to its source requirement and
    acceptance test.
12. Record unresolved design decisions as clarifications; do not invent them.

