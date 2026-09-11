# Multi-Agent API Generation Framework

## Overview
A plug-and-play orchestrator that transforms JIRA PDF extracts into fully functional Java/Spring Boot APIs, ready for review and dev deployment.

**Input:** JIRA requirements PDF + optional Swagger spec + optional supporting docs  
**Output:** Spring Boot microservice with controllers, services, entities, and smoke tests

---

## Architecture

### Sequential Agent Workflow

```
┌────────────────────────────────────────────────────────────────────┐
│                        ORCHESTRATOR AGENT                          │
│  • Manages sequential execution                                    │
│  • Maintains shared state and context                              │
│  • Error handling and recovery                                     │
│  • Coordinates input/output between agents                         │
└────────────────────────────────────────────────────────────────────┘
                                 │
        ┌────────────────────────┼────────────────────────┐
        ▼                        ▼                        ▼
   ┌─────────────┐         ┌──────────────┐       ┌──────────────┐
   │   STEP 1    │         │   STEP 2     │       │   STEP 3     │
   │Requirements │────────▶│Requirements  │──────▶│ OpenAPI/    │
   │Analysis Agent         │Analysis Agent        │Swagger Agent │
   │             │         │              │       │              │
   └─────────────┘         └──────────────┘       └──────────────┘
                                                          │
        ┌────────────────────────┬─────────────────────────┘
        ▼                        ▼
   ┌──────────────┐       ┌──────────────┐
   │   STEP 4     │       │   STEP 5     │
   │Data Model    │───────│Code Generator│
   │Agent         │       │Agent         │
   │              │       │              │
   └──────────────┘       └──────────────┘
                                 │
                                 ▼
                          ┌──────────────┐
                          │   STEP 6     │
                          │Test Generator│
                          │Agent         │
                          │              │
                          └──────────────┘
                                 │
                                 ▼
                          ┌──────────────┐
                          │   Generated  │
                          │   API Code   │
                          │   (Ready for │
                          │    Review)   │
                          └──────────────┘
```

---

## Agents & Responsibilities

### **Step 1: Requirements Analysis Agent**
**Input:** JIRA PDF extract  
**Output:** Structured analysis (acceptance criteria, acceptance tests, edge cases, non-functional requirements)

**Responsibilities:**
- Extract acceptance criteria from PDF
- Identify functional requirements
- Extract acceptance tests (smoke tests)
- Extract non-functional requirements (performance, security, scalability)
- Identify dependencies and integrations
- Flag missing or ambiguous requirements

**Optional Inputs Considered:**
- Existing database schema (if provided)
- Architecture/integration docs (if provided)

---

### **Step 2: Requirements Normalization Agent**
**Input:** Structured analysis from Step 1 + Optional supporting docs  
**Output:** Normalized requirements model

**Responsibilities:**
- Normalize acceptance criteria format
- Identify API endpoints (method, path, input/output contracts)
- Extract data entities/domain models
- Map optional supporting docs to requirements (DB schema → entities)
- Generate clarifications list (for ambiguous requirements)
- Create feature matrix (which endpoints map to which criteria)

**Optional Inputs Considered:**
- Database schema diagram → auto-derive entities
- Authentication/security docs → identify auth patterns
- Integration specs → identify dependencies

---

### **Step 3: OpenAPI/Swagger Agent**
**Input:** Normalized requirements + Optional sample Swagger spec  
**Output:** Complete OpenAPI 3.x specification

**Responsibilities:**
- Design API contracts (request/response models)
- If sample Swagger provided: validate and enhance with derived endpoints
- If no Swagger provided: generate from scratch
- Create request/response DTOs
- Add validation annotations (for OpenAPI code generation)
- Include security schemes
- Generate OpenAPI JSON/YAML spec
- Flag design gaps or conflicts

---

### **Step 4: Data Model Agent**
**Input:** OpenAPI spec + Optional database schema  
**Output:** Java entity/POJO classes

**Responsibilities:**
- Generate JPA/Hibernate entity classes
- If DB schema provided: map schema to entities
- If no schema: infer from OpenAPI models
- Add validation annotations (@NotNull, @Size, etc.)
- Create immutable `record` DTOs (per fvh-insights patterns)
- Generate mapping interfaces (Mapper)
- Identify relationships (1:1, 1:N, N:N)

---

### **Step 5: Code Generator Agent**
**Input:** OpenAPI spec + Data models + Requirements  
**Output:** Spring Boot project skeleton

**Responsibilities:**
- Generate controller classes (thin, with routing only)
- Generate service interfaces (business logic placeholders)
- Generate service implementations (stubs with TODO comments)
- Generate repository interfaces (Spring Data)
- Generate configuration classes (if needed)
- Create project structure (Maven/Gradle, pom.xml/build.gradle)
- Generate application.yml with placeholders
- Include dependency injection setup

**Generates (matching fvh-insights patterns):**
```
src/main/java/com/{org}/{service}/
  ├── controller/      # REST endpoints (thin)
  ├── service/         # Business logic interfaces
  ├── service/impl/    # Service implementations (stubs)
  ├── model/           # Request/response DTOs
  ├── entity/          # JPA entities
  ├── repository/      # Spring Data interfaces
  ├── mapper/          # MapStruct/manual mappers
  ├── config/          # Spring beans & config
  ├── exception/       # Custom exceptions
  └── util/            # Utilities

src/main/resources/
  ├── application.yml  # Configuration (placeholders)
  └── db/
      └── migration/   # Liquibase/Flyway (if DB schema provided)

src/test/java/...
  └── [smoke tests + stubs]

build.gradle / pom.xml
```

---

### **Step 6: Test Generator Agent**
**Input:** Requirements + Code structure  
**Output:** JUnit 5 smoke tests + stubs

**Responsibilities:**
- Generate smoke test class (basic API contract tests)
- Create happy-path tests from acceptance criteria
- Add static code analysis suite (via Gradle/Maven tasks)
- Generate test stubs for all acceptance tests
- Include setup/teardown for test data
- Create test configuration (application-test.yml)

**Test Output:**
```
src/test/java/.../
  ├── smoke/           # Smoke tests (executable)
  │   └── ApiSmokeTests.java
  ├── integration/     # Integration test stubs
  ├── unit/            # Unit test stubs
  └── config/
      └── TestConfig.java
```

---

## Input Types & Handling

### **Required Inputs**
1. **JIRA PDF Extract** (.pdf)
   - Must contain: acceptance criteria, acceptance tests, requirements
   - Framework extracts and normalizes

### **Optional Inputs** (Framework adapts automatically)
1. **Sample Swagger/OpenAPI Spec** (.json/.yaml)
   - If provided: framework validates & enhances
   - If missing: generated from requirements

2. **Database Schema** (SQL script / diagram description / schema.sql)
   - If provided: auto-generates entities and Liquibase migrations
   - If missing: entities inferred from API contracts

3. **Architecture/Integration Docs** (markdown, diagrams, ADR)
   - If provided: identifies dependencies, auth patterns, caching needs
   - If missing: defaults to standard Spring patterns

4. **Security/Authentication Spec** (OAuth2, JWT, mTLS, etc.)
   - If provided: generates AuthZed config, security filter chains
   - If missing: adds placeholder security bean

---

## Output Deliverables

### **Phase 1 (Implemented)**
✅ Static code analysis  
✅ Smoke test generation  
✅ API code skeleton (controllers + services + entities)

### **Phase 2 (To be added)**
- Liquibase/Flyway migration generation
- CI/CD pipeline (GitHub Actions, etc.)
- Docker containerization
- Deployment configs (k8s, etc.)
- API documentation generation (Asciidoc, etc.)

---

## Technical Specifications

### **Technology Stack**
- **Framework:** Spring Boot 3.x
- **Java:** 21+
- **Build Tool:** Gradle (or Maven)
- **Patterns:**
  - Constructor injection (final dependencies)
  - Immutable `record` DTOs
  - MapStruct/manual mappers
  - Spring Data JPA repositories
  - Result4J for optional/error handling
  - OpenAPI 3.x code generation

### **Generated Code Style** (per `.github/copilot-instructions.md`)
- Thin controllers (routing only)
- Business logic in services
- Immutable domain models
- No field injection, no static mutable state
- Configuration from `application.yml` (no hardcoded values)
- Constructor injection with `@RequiredArgsConstructor`

### **Smoke Tests**
- JUnit 5 parameterized tests
- Happy-path contract verification
- Endpoint accessibility tests
- Response schema validation

### **Static Code Analysis**
- Spotless (formatting & linting)
- Checkstyle (style rules)
- SonarQube integration (optional)
- Maven/Gradle check tasks

---

## State & Context Management

### **Shared State**
All agents share a **"GenerationContext"** that includes:

```
{
  "projectName": "aax-micro-{service}",
  "packageRoot": "com.aax.micro.{service}",
  "springBootVersion": "3.x",
  "javaVersion": 21,
  
  // From Step 1
  "acceptanceCriteria": [...],
  "acceptanceTests": [...],
  "nfRequirements": {...},
  
  // From Step 2
  "endpoints": [...],          // {method, path, dto}
  "entities": [...],           // {name, fields}
  "integrations": [...],       // {service, type}
  
  // From Step 3
  "openApiSpec": {...},        // Full spec object
  "models": [...],             // Request/response models
  
  // From Step 4
  "entityClasses": [...],      // Generated entity code
  "mapperClasses": [...],      // Generated mapper code
  
  // From Step 5
  "controllerClasses": [...],  // Generated controller code
  "serviceClasses": [...],     // Generated service code
  "projectStructure": {...},   // File tree
  
  // Metadata
  "inputDocuments": [...],     // Uploaded files
  "gaps": [...],               // Unresolved requirements
  "warnings": [...]            // Quality flags
}
```

### **Error Handling**
- Each agent validates its output
- If validation fails: raise detailed error with corrective action
- Orchestrator can retry or escalate for human review
- All errors logged with context for debugging

---

## Usage Example

### **User Input**
```
project_name: "B2B Order Management API"
jira_pdf: "b2b-requirements-extract.pdf"
sample_swagger: "b2b-api-v1.yaml"        # optional
db_schema: "b2b_schema.sql"              # optional
```

### **Orchestrator Execution**
```
1. Requirements Analysis Agent
   ✓ Parsed 25 acceptance criteria from PDF
   ✓ Identified 8 smoke tests
   ✓ Extracted 4 non-functional requirements
   
2. Requirements Normalization Agent
   ✓ Normalized 8 endpoints
   ✓ Identified 12 entities
   ✓ Mapped DB schema → 12 JPA entities
   
3. OpenAPI Agent
   ✓ Generated OpenAPI 3.0 spec (enhanced with provided swagger)
   ✓ Created 24 request/response models
   ✓ Validated contracts
   
4. Data Model Agent
   ✓ Generated 12 JPA entity classes
   ✓ Created 24 DTO classes (immutable records)
   ✓ Generated 12 MapStruct mappers
   
5. Code Generator Agent
   ✓ Generated 4 controller classes
   ✓ Generated 4 service interfaces + 4 implementations
   ✓ Generated 4 repository interfaces
   ✓ Created project structure + pom.xml/build.gradle
   
6. Test Generator Agent
   ✓ Generated smoke tests (8 tests)
   ✓ Generated static analysis config
   ✓ Created test fixtures
   
📦 Generated artifact: aax-micro-b2b-order-management-api-v1.0.0.zip
✅ Ready for review and dev deployment
```

---

## Next Steps

1. **Implementation:** Build each agent (Step 1-6) with sample implementations
2. **Integration:** Wire agents through orchestrator
3. **Testing:** End-to-end workflow with real JIRA PDFs
4. **Docs:** User guide + example walkthroughs
5. **Enhancements:** Add Phase 2 features (migrations, CI/CD, etc.)
