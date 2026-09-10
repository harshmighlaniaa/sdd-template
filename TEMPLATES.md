# Project Template Structure & Configuration Files

This directory contains reusable templates for the multi-agent API generation framework.

## Directory Structure

```
templates/
│
├── README.md                                    # This file
│
├── project-templates/
│   ├── spring-boot-gradle/                      # Gradle-based template
│   │   ├── build.gradle.template
│   │   ├── settings.gradle.template
│   │   ├── gradle.properties.template
│   │   ├── .gitignore
│   │   └── src/
│   │       ├── main/
│   │       │   ├── java/{package}/
│   │       │   │   ├── controller/
│   │       │   │   ├── service/
│   │       │   │   ├── service/impl/
│   │       │   │   ├── model/
│   │       │   │   ├── entity/
│   │       │   │   ├── repository/
│   │       │   │   ├── mapper/
│   │       │   │   ├── config/
│   │       │   │   ├── exception/
│   │       │   │   └── util/
│   │       │   └── resources/
│   │       │       ├── application.yml.template
│   │       │       ├── application-dev.yml.template
│   │       │       ├── application-test.yml.template
│   │       │       ├── logback-spring.xml.template
│   │       │       └── db/migration/
│   │       └── test/
│   │           ├── java/{package}/
│   │           │   ├── smoke/
│   │           │   ├── integration/
│   │           │   ├── unit/
│   │           │   └── config/
│   │           └── resources/
│   │               └── application-test.yml
│   │
│   └── spring-boot-maven/                       # Maven-based template
│       ├── pom.xml.template
│       ├── .gitignore
│       └── src/
│           ├── main/
│           │   ├── java/{package}/...
│           │   └── resources/...
│           └── test/
│               ├── java/{package}/...
│               └── resources/...
│
├── code-templates/
│   ├── controller.template.java                 # REST Controller template
│   ├── service-interface.template.java          # Service interface template
│   ├── service-impl.template.java               # Service implementation template
│   ├── entity.template.java                     # JPA Entity template
│   ├── dto-request.template.java                # Request DTO (record) template
│   ├── dto-response.template.java               # Response DTO (record) template
│   ├── repository.template.java                 # Spring Data Repository template
│   ├── mapper.template.java                     # MapStruct Mapper template
│   ├── exception.template.java                  # Custom Exception template
│   ├── smoke-tests.template.java                # Smoke Tests template
│   ├── integration-tests.template.java          # Integration Tests template
│   └── unit-tests.template.java                 # Unit Tests template
│
├── config-templates/
│   ├── gradle/
│   │   ├── spotless.gradle.template             # Code formatting rules
│   │   ├── checkstyle.gradle.template           # Code style rules
│   │   ├── testing.gradle.template              # Test configuration
│   │   └── dependencies.gradle.template         # Dependency management
│   ├── maven/
│   │   ├── spotless-maven.template.xml
│   │   ├── checkstyle-maven.template.xml
│   │   └── testing-maven.template.xml
│   └── spring/
│       ├── application.yml.template
│       ├── application-dev.yml.template
│       ├── application-test.yml.template
│       └── logback-spring.xml.template
│
├── openapi-templates/
│   └── openapi-3.0.template.yaml                # OpenAPI 3.0 specification template
│
├── docs-templates/
│   ├── README.md.template                       # Generated API README
│   ├── ARCHITECTURE.md.template                 # Architecture guide
│   ├── API_GUIDE.md.template                    # API usage guide
│   └── DEVELOPMENT.md.template                  # Development guide
│
└── orchestrator/
    ├── orchestrator-agent.py                    # Main orchestrator agent
    ├── agents/
    │   ├── step1-static-analysis-agent.py       # Step 1: Static code analysis
    │   ├── step2-requirements-agent.py          # Step 2: Requirements normalization
    │   ├── step3-openapi-agent.py               # Step 3: OpenAPI generation
    │   ├── step4-datamodel-agent.py             # Step 4: Data model generation
    │   ├── step5-codegen-agent.py               # Step 5: Code generation
    │   └── step6-testgen-agent.py               # Step 6: Test generation
    ├── utils/
    │   ├── pdf-parser.py                        # PDF parsing utilities
    │   ├── template-renderer.py                 # Template rendering engine
    │   ├── validation.py                        # Validation utilities
    │   └── context-manager.py                   # Shared context management
    └── config/
        └── default-config.yaml                  # Default configuration

```

---

## Key Files Explained

### **Build Configuration Templates**

#### `build.gradle.template`
Spring Boot 3.x Gradle configuration with:
- Spring Boot plugin
- Dependency management
- Testing setup (JUnit 5, Testcontainers, Mockito)
- Static analysis (Spotless, Checkstyle)
- Code coverage (JaCoCo)

**Placeholders:**
- `${PROJECT_NAME}` - Your API name
- `${PACKAGE_ROOT}` - Base package (e.g., com.aax.micro.b2b.order)
- `${SPRING_BOOT_VERSION}` - Version (e.g., 3.2.0)
- `${JAVA_VERSION}` - Version (e.g., 21)

#### `pom.xml.template`
Maven equivalent with:
- Spring Boot parent POM
- Plugin management
- Dependency plugins (Spotless, Checkstyle)
- Build profiles (dev, test, prod)

---

### **Code Templates**

#### `controller.template.java`
```java
@RestController
@RequestMapping(value = "${API_ENDPOINT}", produces = "application/json")
@RequiredArgsConstructor
@Slf4j
@Validated
public class ${ENTITY_NAME}Controller {
    
    private final ${ENTITY_NAME}Service ${SERVICE_VAR};
    
    @Operation(summary = "${ENDPOINT_SUMMARY}")
    @PostMapping("${ENDPOINT_PATH}")
    public ResponseEntity<${RESPONSE_DTO}> ${METHOD_NAME}(
            @Valid @RequestBody ${REQUEST_DTO} request) {
        log.info("Received request: {}", request);
        // Thin routing layer - business logic in service
        ${RESPONSE_DTO} response = ${SERVICE_VAR}.${BUSINESS_METHOD}(request);
        return new ResponseEntity<>(response, HttpStatus.CREATED);
    }
}
```

#### `service-impl.template.java`
```java
@Service
@RequiredArgsConstructor
@Slf4j
public class ${ENTITY_NAME}ServiceImpl implements ${ENTITY_NAME}Service {
    
    private final ${ENTITY_NAME}Repository ${REPOSITORY_VAR};
    private final ${ENTITY_NAME}Mapper ${MAPPER_VAR};
    
    @Override
    public ${RESPONSE_DTO} ${METHOD_NAME}(${REQUEST_DTO} request) {
        // TODO: Implement business logic
        // Acceptance Criteria from JIRA:
        // 1. [criteria 1]
        // 2. [criteria 2]
        // See analysis-reports/static-analysis-report.json for details
        
        log.debug("Processing: {}", request);
        ${ENTITY_NAME} entity = ${MAPPER_VAR}.toEntity(request);
        ${ENTITY_NAME} saved = ${REPOSITORY_VAR}.save(entity);
        return ${MAPPER_VAR}.toResponse(saved);
    }
}
```

#### `entity.template.java`
```java
@Entity
@Table(name = "${TABLE_NAME}")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class ${ENTITY_NAME} {
    
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    
    @Column(nullable = false)
    private String name;
    
    // Additional fields generated from DB schema or OpenAPI spec
    
    @CreationTimestamp
    @Column(nullable = false, updatable = false)
    private LocalDateTime createdAt;
    
    @UpdateTimestamp
    @Column(nullable = false)
    private LocalDateTime updatedAt;
}
```

#### `dto-request.template.java`
```java
public record ${REQUEST_DTO}(
    @NotBlank(message = "Name is required")
    String name,
    
    @NotNull(message = "Amount is required")
    @Positive(message = "Amount must be positive")
    BigDecimal amount
) {}
```

---

### **Configuration Templates**

#### `application.yml.template`
```yaml
spring:
  application:
    name: ${PROJECT_NAME}
    version: ${PROJECT_VERSION}
  
  datasource:
    url: jdbc:${DB_TYPE}://${DB_HOST}:${DB_PORT}/${DB_NAME}
    username: ${DB_USER}
    password: ${DB_PASSWORD}
    hikari:
      maximum-pool-size: 10
      minimum-idle: 5
  
  jpa:
    hibernate:
      ddl-auto: validate
    properties:
      hibernate:
        dialect: ${DB_DIALECT}
        format_sql: false
  
  cache:
    type: caffeine
    caffeine:
      spec: maximumSize=500,expireAfterWrite=600s

server:
  port: 8080
  servlet:
    context-path: /api

logging:
  level:
    root: INFO
    com.aax: DEBUG
  pattern:
    console: "%d{yyyy-MM-dd HH:mm:ss} - %msg%n"

management:
  endpoints:
    web:
      exposure:
        include: health,metrics,info
  endpoint:
    health:
      show-details: when-authorized
```

---

### **OpenAPI Template**

#### `openapi-3.0.template.yaml`
```yaml
openapi: 3.0.0
info:
  title: ${API_TITLE}
  description: ${API_DESCRIPTION}
  version: ${API_VERSION}
  contact:
    name: API Support
    email: support@example.com

servers:
  - url: http://localhost:8080/api
    description: Development server
  - url: https://api.example.com
    description: Production server

paths:
  ${ENDPOINTS_PLACEHOLDER}:
    post:
      summary: ${ENDPOINT_SUMMARY}
      operationId: ${OPERATION_ID}
      requestBody:
        required: true
        content:
          application/json:
            schema:
              $ref: '#/components/schemas/${REQUEST_DTO}'
      responses:
        '201':
          description: Created successfully
          content:
            application/json:
              schema:
                $ref: '#/components/schemas/${RESPONSE_DTO}'

components:
  schemas:
    ${REQUEST_DTO}:
      type: object
      required:
        - ${REQUIRED_FIELDS}
      properties:
        ${PROPERTIES_PLACEHOLDER}

security:
  - bearerAuth: []

components:
  securitySchemes:
    bearerAuth:
      type: http
      scheme: bearer
      bearerFormat: JWT
```

---

## How Agents Use These Templates

### **Step 5: Code Generator Agent**
1. Loads `controller.template.java`
2. Replaces placeholders with actual values
3. Generates `OrderController.java`, `CustomerController.java`, etc.

```python
# Example from step5-codegen-agent.py
template = load_template("controller.template.java")
for endpoint in context.endpoints:
    code = render_template(template, {
        "ENTITY_NAME": endpoint.entity,
        "API_ENDPOINT": endpoint.path,
        "METHOD_NAME": endpoint.method_name,
        "REQUEST_DTO": endpoint.request_dto,
        "RESPONSE_DTO": endpoint.response_dto,
    })
    write_file(f"src/main/java/.../controller/{endpoint.entity}Controller.java", code)
```

### **Step 6: Test Generator Agent**
1. Loads `smoke-tests.template.java`
2. Generates test methods for each acceptance criterion
3. Creates parameterized tests with test data

---

## Usage in Your Workflow

### **For the Framework Developer:**
1. Update templates as coding standards evolve
2. Add new templates for new features (Docker, K8s, etc.)
3. Version templates (templates-v1.0.0, templates-v2.0.0)

### **For End Users:**
Templates are **internal** — you just provide JIRA PDF + optional docs. The framework handles all template usage.

---

## Extending Templates

To add a new template (e.g., for event-driven patterns):

1. Create `event-publisher.template.java` in `code-templates/`
2. Define placeholders clearly in comments
3. Update `step5-codegen-agent.py` to use it when appropriate
4. Test with a sample generation

Example:
```java
// event-publisher.template.java
@Component
@RequiredArgsConstructor
@Slf4j
public class ${AGGREGATE_NAME}EventPublisher {
    
    private final ApplicationEventPublisher eventPublisher;
    
    public void publish${EVENT_NAME}(${AGGREGATE_NAME} aggregate) {
        log.info("Publishing event: {}", aggregate.getId());
        ${EVENT_NAME} event = new ${EVENT_NAME}(aggregate);
        eventPublisher.publishEvent(event);
    }
}
```

---

## Next Steps

1. **Create Sample Templates** - Start with Gradle + Spring Boot 3.2 + Java 21
2. **Implement Agents** - Build each agent that uses these templates
3. **Test Generation** - Run framework against real JIRA PDFs
4. **Iterate & Refine** - Update templates based on generated code quality

---

**All templates follow AAX.com standards from `fvh-insights` reference repo.**
