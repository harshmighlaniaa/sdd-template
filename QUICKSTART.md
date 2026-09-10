# Multi-Agent API Generation Framework - Quick Start Guide

## Overview
This guide shows you how to use the framework to transform a JIRA PDF into a fully functional Java/Spring Boot API.

---

## Step-by-Step Usage

### **Phase 1: Prepare Your Inputs**

#### Gather Required & Optional Documents

**Required:**
- 📄 **JIRA Requirements PDF** - Extract from JIRA containing:
  - Acceptance criteria
  - Acceptance tests (what should pass)
  - User stories/functional requirements
  - Any business rules
  
  *Example:* `b2b-order-api-requirements.pdf`

**Optional (but recommended):**
- 📋 **Sample Swagger/OpenAPI Spec** (.yaml/.json)
  - Helps framework understand your API design style
  - Framework enhances/validates this spec
  
  *Example:* `b2b-api-contract.yaml`

- 🗄️ **Database Schema** (.sql or description)
  - CREATE TABLE statements, or
  - Schema diagram description in text/markdown
  - Helps auto-generate JPA entities
  
  *Example:* `b2b_schema.sql`

- 📚 **Architecture/Integration Docs** (optional)
  - How this API connects to other services
  - Authentication requirements (OAuth2, JWT, etc.)
  - Performance/caching needs
  
  *Example:* `architecture.md`

---

### **Phase 2: Invoke the Framework**

#### Option A: Via CLI (Recommended for automation)

```bash
# Basic usage (only JIRA PDF)
./copilot-framework.sh \
  --project-name "b2b-order-api" \
  --jira-pdf ./b2b-order-api-requirements.pdf \
  --output-dir ./generated-api

# Enhanced usage (with optional docs)
./copilot-framework.sh \
  --project-name "b2b-order-api" \
  --jira-pdf ./b2b-order-api-requirements.pdf \
  --swagger ./b2b-api-contract.yaml \
  --db-schema ./b2b_schema.sql \
  --architecture ./architecture.md \
  --java-version 21 \
  --spring-boot-version 3.2 \
  --output-dir ./generated-api
```

#### Option B: Via Configuration File (Best for repeatable runs)

Create `generation-config.yaml`:
```yaml
project:
  name: b2b-order-api
  package: com.aax.micro.b2b.order
  description: B2B Order Management API

inputs:
  jira_pdf: ./b2b-order-api-requirements.pdf
  swagger: ./b2b-api-contract.yaml          # optional
  db_schema: ./b2b_schema.sql               # optional
  architecture_doc: ./architecture.md       # optional

technology:
  java_version: 21
  spring_boot_version: 3.2
  build_tool: gradle                        # or maven

output:
  directory: ./generated-api
  include_docker: false                     # Phase 2
  include_cicd: false                       # Phase 2

options:
  override_existing: false
  generate_smoke_tests: true
  include_static_analysis: true
```

Then run:
```bash
./copilot-framework.sh --config generation-config.yaml
```

#### Option C: Via GitHub Copilot Chat (Coming soon)

```
@copilot Generate API from JIRA

I have:
- JIRA PDF: b2b-order-api-requirements.pdf
- Swagger: b2b-api-contract.yaml
- DB Schema: b2b_schema.sql

Project: B2B Order Management API
Package: com.aax.micro.b2b.order
Tech: Spring Boot 3.2, Java 21
```

---

### **Phase 3: Framework Execution**

The orchestrator will run **6 agents sequentially**:

```
┌─────────────────────────────────────────────────────────────────┐
│ STEP 1: Static Code Analysis Agent                              │
├─────────────────────────────────────────────────────────────────┤
│ INPUT:  b2b-order-api-requirements.pdf                          │
│ PROCESS: Extract acceptance criteria, tests, requirements        │
│ OUTPUT:                                                          │
│   ✓ 15 acceptance criteria identified                          │
│   ✓ 8 smoke tests extracted                                    │
│   ✓ 5 non-functional requirements identified                  │
│ STATUS: ✅ PASSED                                              │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ STEP 2: Requirements Normalization Agent                         │
├─────────────────────────────────────────────────────────────────┤
│ INPUT:  Analysis from Step 1 + optional docs                   │
│ PROCESS: Normalize to structured format                         │
│ OUTPUT:                                                          │
│   ✓ 6 API endpoints designed                                   │
│   ✓ 8 domain entities identified                               │
│   ✓ Integration dependencies mapped                             │
│ STATUS: ✅ PASSED                                              │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ STEP 3: OpenAPI/Swagger Agent                                   │
├─────────────────────────────────────────────────────────────────┤
│ INPUT:  Normalized requirements + sample swagger (if provided)  │
│ PROCESS: Generate/enhance OpenAPI 3.x spec                      │
│ OUTPUT:                                                          │
│   ✓ Full OpenAPI 3.0 spec (b2b-order-api-openapi.yaml)        │
│   ✓ 6 endpoint schemas defined                                 │
│   ✓ Request/response models validated                          │
│ STATUS: ✅ PASSED                                              │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ STEP 4: Data Model Agent                                        │
├─────────────────────────────────────────────────────────────────┤
│ INPUT:  OpenAPI spec + db schema (if provided)                  │
│ PROCESS: Generate JPA entities & DTOs                           │
│ OUTPUT:                                                          │
│   ✓ 8 JPA entity classes generated                             │
│   ✓ 16 immutable DTO records created                           │
│   ✓ 8 MapStruct mappers generated                              │
│ STATUS: ✅ PASSED                                              │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ STEP 5: Code Generator Agent                                    │
├─────────────────────────────────────────────────────────────────┤
│ INPUT:  Data models + OpenAPI + requirements                    │
│ PROCESS: Generate Spring Boot project skeleton                  │
│ OUTPUT:                                                          │
│   ✓ 6 controller classes with @PostMapping/@GetMapping         │
│   ✓ 6 service interfaces + implementations                     │
│   ✓ 6 repository interfaces (Spring Data)                      │
│   ✓ Project structure + pom.xml/build.gradle                   │
│   ✓ application.yml with placeholders                          │
│ STATUS: ✅ PASSED                                              │
└─────────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────────┐
│ STEP 6: Test Generator Agent                                    │
├─────────────────────────────────────────────────────────────────┤
│ INPUT:  Requirements + generated code structure                 │
│ PROCESS: Create smoke tests & static analysis config            │
│ OUTPUT:                                                          │
│   ✓ ApiSmokeTests.java (8 parameterized tests)                 │
│   ✓ spotless.gradle / checkstyle.xml                           │
│   ✓ application-test.yml                                        │
│ STATUS: ✅ PASSED                                              │
└─────────────────────────────────────────────────────────────────┘
                              ↓
             ✅ GENERATION COMPLETE
    📦 Generated: aax-micro-b2b-order-api-v1.0.0.zip
    📋 Report: generation-report.html
```

---

### **Phase 4: Review Generated Output**

The framework outputs a **single ZIP file** containing:

```
aax-micro-b2b-order-api-v1.0.0.zip
│
├── aax-micro-b2b-order-api/
│   ├── src/main/java/com/aax/micro/b2b/order/
│   │   ├── controller/
│   │   │   ├── OrderController.java        ✅ REST endpoints
│   │   │   ├── CustomerController.java
│   │   │   └── ...
│   │   ├── service/
│   │   │   ├── OrderService.java           ✅ Business logic interface
│   │   │   ├── impl/
│   │   │   │   └── OrderServiceImpl.java    ✅ Service implementation (stubs with TODO)
│   │   │   └── ...
│   │   ├── model/
│   │   │   ├── CreateOrderRequest.java     ✅ Immutable DTOs (records)
│   │   │   ├── OrderResponse.java
│   │   │   └── ...
│   │   ├── entity/
│   │   │   ├── Order.java                  ✅ JPA entities
│   │   │   ├── Customer.java
│   │   │   └── ...
│   │   ├── repository/
│   │   │   ├── OrderRepository.java        ✅ Spring Data JPA
│   │   │   └── ...
│   │   ├── mapper/
│   │   │   ├── OrderMapper.java            ✅ MapStruct mappers
│   │   │   └── ...
│   │   ├── config/
│   │   │   ├── WebConfig.java
│   │   │   ├── SecurityConfig.java
│   │   │   └── ...
│   │   ├── exception/
│   │   │   ├── OrderNotFoundException.java
│   │   │   └── ...
│   │   └── util/
│   │       └── OrderValidator.java
│   │
│   ├── src/main/resources/
│   │   ├── application.yml                 ✅ Configuration (placeholders)
│   │   ├── application-dev.yml
│   │   ├── db/
│   │   │   └── migration/
│   │   │       ├── V001__create_tables.sql ✅ If DB schema provided
│   │   │       └── ...
│   │   └── logback-spring.xml
│   │
│   ├── src/test/java/com/aax/micro/b2b/order/
│   │   ├── smoke/
│   │   │   └── ApiSmokeTests.java          ✅ Executable smoke tests
│   │   ├── integration/
│   │   │   ├── OrderControllerIT.java      ✅ Integration test stubs
│   │   │   └── ...
│   │   ├── unit/
│   │   │   ├── OrderServiceTest.java       ✅ Unit test stubs
│   │   │   └── ...
│   │   └── config/
│   │       └── TestConfig.java
│   │
│   ├── build.gradle                        ✅ Gradle build config
│   ├── pom.xml                             ✅ Or Maven config
│   ├── settings.gradle
│   ├── .gitignore
│   ├── Dockerfile                          ❌ Phase 2
│   ├── docker-compose.yml                  ❌ Phase 2
│   ├── .github/workflows/                  ❌ Phase 2
│   │   ├── build.yml
│   │   └── deploy.yml
│   │
│   └── README.md                           ✅ Quick start guide
│
├── openapi-spec/
│   └── b2b-order-api-openapi-3.0.yaml     ✅ Full API contract
│
├── analysis-reports/
│   ├── static-analysis-report.json         ✅ Step 1 results
│   ├── requirements-analysis.json          ✅ Step 2 results
│   ├── openapi-validation.json             ✅ Step 3 results
│   ├── entity-mapping-report.json          ✅ Step 4 results
│   ├── code-generation-log.json            ✅ Step 5 results
│   └── test-generation-log.json            ✅ Step 6 results
│
├── GENERATION_REPORT.html                  ✅ Summary & quality metrics
└── README.md                               ✅ How to use generated API
```

---

### **Phase 5: Next Steps - Complete the API**

#### 1. **Review Generated Code** (30-60 min)
```bash
cd aax-micro-b2b-order-api
cat README.md                    # Framework's instructions
cat src/main/java/.../service/impl/OrderServiceImpl.java  # Find TODO comments
```

#### 2. **Run Smoke Tests** (to verify generation)
```bash
# Test that generated code compiles & smoke tests pass
./gradlew clean build            # Gradle
# or
mvn clean package               # Maven
```

#### 3. **Fill in Service Logic** (your work)
Each service implementation has placeholders:
```java
@Service
public class OrderServiceImpl implements OrderService {
    @Override
    public OrderResponse createOrder(CreateOrderRequest request) {
        // TODO: Implement business logic
        // Hint from requirements: validate customer exists, check inventory, etc.
        throw new NotImplementedException("Implement per acceptance criteria");
    }
}
```

**Framework provides hints:**
- Check `analysis-reports/static-analysis-report.json` for business rules
- Check acceptance criteria in `GENERATION_REPORT.html`
- Run smoke tests to understand expected behavior

#### 4. **Run Smoke Tests Against Your Implementation**
```bash
./gradlew test --tests "*SmokeTests"

# Example output:
# ✅ test_createOrder_validRequest_returns201
# ✅ test_getOrderById_existingId_returns200
# ✅ test_updateOrder_validRequest_returns200
# ... (8 tests from acceptance criteria)
```

#### 5. **Run Static Analysis**
```bash
./gradlew spotlessCheck           # Formatting
./gradlew checkstyleMain          # Style rules
./gradlew build                   # Full build with checks
```

#### 6. **Deploy to Dev**
```bash
# Once tests pass:
./gradlew bootBuild               # Create runnable JAR
java -jar build/libs/aax-micro-b2b-order-api-1.0.0.jar
```

---

## Real-World Example Walkthrough

### **Scenario: Generate B2B Order Management API**

**Input Files:**
```
📄 jira-extract.pdf (from Jira export)
📋 swagger-sample.yaml (from previous API version)
🗄️ b2b_schema.sql (your database team's design)
```

**Run:**
```bash
./copilot-framework.sh \
  --project-name "b2b-order-api" \
  --jira-pdf ./jira-extract.pdf \
  --swagger ./swagger-sample.yaml \
  --db-schema ./b2b_schema.sql \
  --output-dir ./generated
```

**Framework processes (2-5 minutes):**
1. ✅ **Step 1:** Extracts "Create Order", "Get Order", "Cancel Order" endpoints + 8 acceptance tests
2. ✅ **Step 2:** Normalizes to 5 entities (Order, OrderItem, Customer, Payment, Shipping)
3. ✅ **Step 3:** Generates OpenAPI 3.0 with all schemas (validates against your swagger-sample.yaml)
4. ✅ **Step 4:** Generates Order.java, OrderItem.java entities + DTOs (matches b2b_schema.sql)
5. ✅ **Step 5:** Generates OrderController, OrderService, OrderRepository (thin stubs)
6. ✅ **Step 6:** Generates 8 smoke tests + Gradle build config

**Output:**
```
generated/aax-micro-b2b-order-api-v1.0.0.zip
```

**You do (as developer):**
```java
// Fill in OrderServiceImpl.createOrder() with:
// - Validate customer exists (call customer service)
// - Validate inventory (call inventory service)
// - Create order in database
// - Publish event (order-created event)
// - Return OrderResponse

@Override
public OrderResponse createOrder(CreateOrderRequest request) {
    // Your implementation here
    Order order = new Order(request.getCustomerId(), request.getLineItems());
    return orderMapper.toResponse(orderRepository.save(order));
}
```

**Run tests:**
```bash
./gradlew test    # 8 smoke tests pass ✅
```

**Deploy:**
```bash
./gradlew bootRun  # API running on http://localhost:8080
```

---

## Key Benefits

| Benefit | Details |
|---------|---------|
| **Speed** | Generate weeks of boilerplate in 5 minutes |
| **Consistency** | Every API follows Spring Boot best practices (from fvh-insights) |
| **Traceability** | Every line of generated code links to a requirement |
| **Quality** | Static analysis built-in from day 1 |
| **Adaptability** | Skip optional inputs, framework adapts (no DB schema? No problem!) |
| **Flexibility** | Use generated code as-is or customize as needed |

---

## Troubleshooting

### **❌ "PDF parsing failed"**
- Ensure PDF is a text PDF (not scanned image)
- Check PDF has clear section headers (Acceptance Criteria, Test Cases, etc.)
- [Generate PDF from Jira wiki] export as PDF

### **❌ "Swagger validation failed"**
- Ensure swagger is valid OpenAPI 3.0 YAML/JSON
- Validate at: https://editor.swagger.io/
- Or skip it - framework generates from requirements

### **❌ "Database schema mapping failed"**
- Ensure SQL is valid CREATE TABLE statements
- Or provide schema as markdown table
- Or skip it - framework infers entities from API contracts

### **❌ "Smoke tests fail after generation"**
- This is expected! Service stubs throw `NotImplementedException`
- Tests should fail until you implement business logic
- Use test output to understand what to build

---

## Next Features (Phase 2)

- [ ] Liquibase migration auto-generation
- [ ] GitHub Actions CI/CD pipeline generation
- [ ] Docker containerization
- [ ] Kubernetes deployment manifests
- [ ] API documentation (Asciidoc/Swagger UI)
- [ ] Performance testing templates

---

## Support & Questions

📧 **Questions?** Check FRAMEWORK_DESIGN.md for architecture details  
🐛 **Issues?** Run with `--verbose` to see agent logs  
💡 **Suggestions?** Open a GitHub issue!

---

**Ready to generate your first API?** 🚀

```bash
./copilot-framework.sh --help
```

