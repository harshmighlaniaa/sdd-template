# API Generation Runbook

## Purpose

This runbook explains how to use the repository's Copilot agents to turn a JIRA
requirements PDF into a reviewable Spring Boot API skeleton. It is written for
operators who do not need to understand the generated code.

The process has one planning activity and six controlled stages. Do not skip a
stage. Review the result at each checkpoint before continuing.

## What the process creates

For a run named `order-api-test`, use an output folder such as:

```text
runs/order-api-test/
  generation-context.json
  analysis-reports/
  openapi-spec/
  staging/
  project/
```

The `project/` folder is the generated Spring Boot application. The other
folders contain reports and intermediate artifacts used to explain and verify
how it was generated.

## Before you start

### Access

Confirm that you have:

- access to this repository
- access to GitHub Copilot
- permission to create a branch or Copilot workspace
- a supported Copilot client

Use one of these clients:

- **Copilot app or VS Code:** preferred because agent handoff buttons may be
  available.
- **GitHub Copilot agents:** open <https://github.com/copilot/agents>, select
  this repository, and switch stage agents manually. GitHub.com currently
  ignores custom-agent handoff buttons.

Always run generation on a new branch or isolated workspace. Do not generate
directly on `main`.

### Input checklist

Prepare:

- **Required:** one text-searchable JIRA PDF.
- **Optional:** an existing OpenAPI YAML or JSON file.
- **Optional:** a SQL database schema.
- **Optional:** architecture or integration documentation.
- **Optional:** authentication and authorization requirements.

The JIRA PDF should contain:

- the problem or user story
- acceptance criteria
- acceptance tests or examples
- business rules
- known error cases

Do not use a scanned image-only PDF. Export it from JIRA as a searchable PDF or
apply OCR first.

Do not upload secrets, passwords, production data, personal data, or restricted
documents. Use sanitized test material for the first run.

### Decisions to collect

Write down these values before opening the planner:

| Decision | Example |
| --- | --- |
| Project name | `order-api` |
| Java package | `com.example.order` |
| Build tool | `gradle` |
| Java version | `21` |
| Spring Boot version | `3.x` |
| Output folder | `runs/order-api-test` |
| Existing-file policy | Do not overwrite |

If you do not know a value, tell the planner that it is undecided. Do not guess.

### Optional Features

The framework supports 12 optional features organized in three tiers:

- **Tier 1 (Production Readiness)**: JWT Authentication, Flyway Migrations,
  Observability, Docker Support
- **Tier 2 (Framework Maturity)**: API Versioning, Conflict Resolution, Caching,
  Rate Limiting
- **Tier 3 (Developer Experience)**: Integration Tests, Troubleshooting Guide,
  Architecture Decision Records, Performance Testing

All features are **disabled by default** for initial runs. After your first
successful generation, you can enable features incrementally using
`features.yml` or environment variables. See "Enabling Optional Features"
section below.

## First test

For the first test, use a small, non-sensitive JIRA export with one to three
API operations. Omit optional inputs unless they are necessary. This makes
failures easier to understand.

**Important**: Optional features are **disabled by default**. This is intentional
for initial testing. After your first successful run, enable features
incrementally using the "Enabling Optional Features" section below.

Success means:

- all six stages reach `complete`
- every requirement has a source reference
- the OpenAPI document validates
- the generated application compiles
- generated tests compile
- unfinished business logic is reported honestly as TODOs or blocked tests

## Step 0: Start the planner

1. Open a new Copilot session for this repository from the latest `main`.
2. Create or select a new working branch.
3. Open the agent picker in the prompt box.
4. Select **API Generation Planner**.
5. Attach the JIRA PDF and any optional files (OpenAPI, schema, architecture docs).
6. Paste and update this prompt:

   > Plan a test generation run for project `order-api`, package
   > `com.example.order`, Java 21, Spring Boot 3.x, and Gradle. Use
   > `runs/order-api-test` as the output folder and do not overwrite existing
   > files. Use the attached JIRA PDF and supporting documents. Update
   > `plan.md`, list planning assumptions, and stop before Step 1. During
   > generation, keep full gap details only in `gap-analysis.md`.

7. Send the prompt and wait for the planner to finish.

### About Planner Intelligence

The API Generation Planner now includes domain-aware validation patterns that
detect architectural requirements such as:

- Multi-system abstraction and adapter patterns
- Hierarchical data structures and authorization inheritance
- Asynchronous request/response patterns for long-running operations
- Data source boundaries and out-of-scope exclusions
- Optional attribute expansion and filtering logic
- Rate limiting and resilience requirements
- Observability and auditability needs

If the planner identifies incomplete specifications for these patterns, it will
ask clarifying questions. Answer with business decisions; do not ask the agent
to guess. Examples:

- "The requirements mention multiple integrations. Is there an abstraction
  boundary normalizing requests and responses?"
- "Does accessing a parent fleet grant access to all child fleets?"
- "Should long-running operations use an async submit-and-poll pattern?"

### Planner checkpoint

Open `plan.md` and confirm:

- the project name and package are correct
- every supplied file is listed
- the output folder is unique for this run
- the overwrite policy says not to overwrite
- all assumptions are understandable
- no generated API files were created yet
- Step 1 is identified as the next eligible action

If a required fact is wrong or missing, reply to the planner:

> Update the plan with this correction: [describe the correction]. Do not start
> Step 1.

Continue only when the plan is accurate.

## Step 1: Analyze requirements

### Start

Use the **Run Step 1: Analyze requirements** handoff button.

If no button appears, select **Step 1 Requirements Analysis** from the agent picker
and send:

> Execute Step 1 from the approved `plan.md`. Read
> `.github/agent-docs/api-generation-workflow.md`, use the attached JIRA PDF,
> initialize the GenerationContext under the planned output folder, and stop
> after validating the Step 1 completion gate.

### Check

Confirm these files exist under the run output folder:

- `generation-context.json`
- `gap-analysis.md`
- `analysis-reports/requirements-analysis-report.json`

Confirm `generation-context.json` shows Step 1 as `complete`.

Review the report and check:

- acceptance criteria match the JIRA wording
- acceptance tests are present
- each record identifies its source page or section
- unclear or conflicting requirements have `gap_refs` pointing to full entries
  under the Stage 1 heading in `gap-analysis.md`
- the agent did not invent endpoints or business rules

If Step 1 is `blocked` or `failed`, read the recorded reason, correct the input,
and rerun Step 1. Do not continue to Step 2.

## Step 2: Normalize requirements

### Start

Use **Run Step 2: Normalize requirements**, or select
**Step 2 Requirements Normalization** and send:

> Execute Step 2 from the approved plan and completed Step 1 artifacts. Produce
> normalized requirements and the feature matrix, validate the completion gate,
> and stop.

### Check

Confirm this file exists:

- `analysis-reports/normalized-requirements.json`

Confirm Step 2 is `complete`, then review:

- proposed HTTP methods and paths
- request, response, and error behavior
- identified domain entities
- integrations and security needs
- the feature matrix mapping every acceptance criterion
- any `gap_refs` resolve to entries under the Stage 2 heading in
  `gap-analysis.md`

Ask the agent to correct the artifact if the proposed API does not match the
business intent. Do not continue until the corrections validate.

## Step 3: Build the OpenAPI contract

### Start

Use **Run Step 3: Build OpenAPI contract**, or select **Step 3 OpenAPI** and
send:

> Execute Step 3 from the approved plan and completed Step 2 artifacts.
> Generate or enhance the OpenAPI 3.x contract, validate it, write the
> validation report, and stop.

### Check

Confirm these files exist:

- `openapi-spec/{project}-openapi-3.0.yaml`
- `analysis-reports/openapi-validation.json`

Confirm Step 3 is `complete`, then review:

- every approved operation is present
- required fields and validation rules are correct
- expected success and error responses are present
- authentication appears only when requirements approve it
- the validation report has no unresolved errors

Do not continue if the OpenAPI contract is invalid or contains unapproved
behavior.

## Step 4: Generate the data model

### Start

Use **Run Step 4: Generate data model**, or select **Step 4 Data Model** and
send:

> Execute Step 4 from the validated OpenAPI contract and approved database
> schema, if supplied. Generate the staged data model and mapping report,
> validate the completion gate, and stop.

### Check

Confirm these outputs exist:

- `staging/data-model/`
- `analysis-reports/entity-mapping-report.json`

Confirm Step 4 is `complete`, then review:

- API DTOs are separate from persistence entities
- field names and types match the approved contract
- database relationships and required fields are represented
- conflicts between OpenAPI and the database are not silently resolved

Any unresolved contract/schema conflict must block Step 5.

## Step 5: Generate the API skeleton

### Start

Use **Run Step 5: Generate API skeleton**, or select
**Step 5 Code Generator** and send:

> Execute Step 5 from the approved plan, validated OpenAPI contract, and staged
> data model. Generate the Spring Boot skeleton, compile it, write the
> generation log, and stop.

### Check

Confirm these outputs exist:

- `project/`
- `analysis-reports/code-generation-log.json`

Confirm Step 5 is `complete`, then check that:

- the generation log says the project compiled
- controllers contain routing rather than business logic
- services contain clear TODOs for unspecified business logic
- no passwords, tokens, or environment-specific secrets were generated
- unrelated repository files were not overwritten

If compilation fails, keep the run at Step 5 until the generating agent fixes
all generation-caused errors.

## Step 6: Generate tests

### Start

Use **Run Step 6: Generate tests**, or select **Step 6 Test Generator** and
send:

> Execute Step 6 from the completed generated project and acceptance mappings.
> Generate tests and test configuration, compile and run executable checks,
> write the test-generation log, and stop.

### Check

Confirm this file exists:

- `analysis-reports/test-generation-log.json`

Confirm Step 6 is `complete`, then review:

- every test cites a requirement or acceptance-test ID
- generated tests compile
- executable generation checks passed
- tests waiting for business-logic TODOs are clearly marked as blocked
- assertions were not weakened simply to make tests pass

## Final review

Before sharing the generated project:

1. Open `generation-context.json` and confirm Steps 1 through 6 are `complete`.
2. Review all entries in `gap-analysis.md` and all `warnings`, `decisions`, and
   `failures` in `generation-context.json`.
3. Confirm the generated OpenAPI file matches the accepted API design.
4. Confirm the code-generation log reports a successful compile.
5. Confirm the test-generation log distinguishes passing checks from blocked
   business tests.
6. Ask a developer to review the generated application before deployment.
7. Commit the run artifacts on the working branch and open a pull request.

Do not deploy the generated project directly. Service implementations may
contain intentional TODOs that require developer work.

## Enabling Optional Features

After your first successful API generation, you can enable optional features to
add production-ready capabilities:

### Step 1: Check Current Feature Status

```bash
./scripts/check-features.sh
```

This shows all 12 features with their current status (✅ ENABLED or ⏸️ DISABLED).

### Step 2: Enable Features

**Option A: Edit configuration file**

```bash
vim features.yml

# Find the feature you want to enable, e.g.:
# security:
#   jwt-authentication:
#     enabled: false  ← change to: true

# Or observability:
#   metrics-collection:
#     enabled: false  ← change to: true
```

**Option B: Use environment variables**

```bash
# Enable JWT Authentication
export FEATURES_SECURITY_JWT_AUTHENTICATION_ENABLED=true

# Enable Observability
export FEATURES_OBSERVABILITY_METRICS_COLLECTION_ENABLED=true

# Run the generated application
cd runs/order-api-test/project/
./gradlew bootRun
```

### Step 3: Recommended Feature Enablement Order

**Phase 1 (Production Readiness)** – Enable for production deployments:
1. JWT Authentication (security)
2. Flyway Migrations (database versioning)
3. Observability (monitoring and metrics)
4. Docker (containerization)

**Phase 2 (Framework Maturity)** – Enable when scaling:
1. API Versioning (backward compatibility)
2. Caching (performance optimization)
3. Rate Limiting (abuse protection)

**Phase 3 (Developer Experience)** – Enable for team collaboration:
1. Integration Tests (quality assurance)
2. Architecture Decision Records (institutional knowledge)
3. Troubleshooting Guide (developer support)
4. Performance Testing (benchmarking)

### Step 4: Verify Feature Status

```bash
# Check that features are enabled
./scripts/check-features.sh

# View configuration
cat features.yml

# Expected output shows:
# Tier 1: Production Readiness
#   1. JWT Authentication
#      Status: ✅ ENABLED
#   2. Flyway Migrations
#      Status: ✅ ENABLED
#   ... etc
```

For detailed information on each feature, see `FEATURES.md`.

## Troubleshooting

| Problem | Action |
| --- | --- |
| Planner agent is missing | Confirm the repository and branch contain `.github/agents/api-generation-planner.agent.md`, then refresh the client |
| Handoff buttons are missing | Select each stage agent manually; GitHub.com ignores handoff definitions |
| PDF cannot be read | Export a text-searchable PDF or apply OCR, attach it again, and rerun Step 1 |
| Stage refuses to start | Open `generation-context.json` and complete or repair the named prerequisite |
| Agent asks for a business decision | Obtain the decision from the product owner; do not ask the agent to guess |
| Existing files would be overwritten | Choose a new run output folder or explicitly approve the intended overwrite |
| OpenAPI validation fails | Keep the run at Step 3 and resolve every reported contract error |
| Generated project does not compile | Keep the run at Step 5 and ask the code generator to fix generation-caused errors |
| Tests fail because services are TODOs | Confirm they are classified as blocked acceptance tests, then assign implementation to a developer |
| Agent changed unrelated files | Stop, discard those unrelated changes, and rerun with the owned-path restriction from the shared workflow contract |
| Feature not enabling | Verify `features.yml` has `enabled: true`, restart the application, and check with `./scripts/check-features.sh` |
| Planner asks unexpected questions | This indicates enhanced domain validation detected architectural patterns; answer with business decisions |

## Operator completion record

Record the run before handoff:

| Item | Value |
| --- | --- |
| Run name | |
| Working branch | |
| Operator | |
| JIRA reference | |
| Output folder | |
| Step 1 status | |
| Step 2 status | |
| Step 3 status | |
| Step 4 status | |
| Step 5 status | |
| Step 6 status | |
| Remaining gaps | |
| Developer reviewer | |
| Pull request | |
