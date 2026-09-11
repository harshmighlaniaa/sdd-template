# .copilot

Multi-agent framework for API generation from JIRA requirements -
documentation, OpenAPI, Spring Boot skeleton, and test generation.

## Copilot custom agents

Start with **API Generation Planner** from the Copilot agent picker. Give it the
JIRA requirements PDF and any optional OpenAPI, database schema, architecture,
integration, or security documents. It researches the inputs and writes an
approved repository-root `plan.md` without generating application code.

The planner exposes six review-before-send handoffs:

1. Step 1 Static Analysis
2. Step 2 Requirements Normalization
3. Step 3 OpenAPI
4. Step 4 Data Model
5. Step 5 Code Generator
6. Step 6 Test Generator

The workflow is sequential even though every handoff is visible. Each stage
checks its upstream completion gate, updates the durable GenerationContext, and
stops after producing its owned artifacts. See
[the shared workflow contract](.github/agent-docs/api-generation-workflow.md)
for paths, traceability rules, and completion gates.

Custom-agent profiles are in `.github/agents/` and are automatically discovered
by supported Copilot clients. Handoff buttons are supported in VS Code and
compatible clients; GitHub.com cloud-agent execution currently ignores the
`handoffs` property, so stage profiles can also be selected directly.

For a complete non-technical operating procedure and first-test checklist, see
[API Generation Runbook](RUNBOOK.md).
