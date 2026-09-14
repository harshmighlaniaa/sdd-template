# Implementation Roadmap - Building the Framework Step-by-Step

## Overview
This document provides a phased approach to building the multi-agent API generation framework. Start with Phase 1 (Minimum Viable Product) and expand from there.

---

## Phase 1: MVP (Weeks 1-3) - Foundation

### Goal
Generate a working Spring Boot API from a JIRA PDF with basic code scaffolding, smoke tests, and static analysis.

### What's Included
✅ PDF parsing (extract requirements)  
✅ OpenAPI spec generation  
✅ Entity + DTO generation  
✅ Basic code scaffolding (controllers, services, repositories)  
✅ Smoke tests (basic contract tests)  
✅ Static analysis configuration (Spotless, Checkstyle)  

### What's NOT Included ❌
- Database migration generation (Liquibase/Flyway)
- CI/CD pipeline generation
- Docker/Kubernetes manifests
- Advanced testing (integration tests, performance tests)

---

## Week 1: Setup & Step 1 Agent (PDF Parser)

### Tasks

#### 1.1: Project Structure
```bash
copilot-framework/
├── agents/
│   └── step1_static_analysis_agent.py      # START HERE
├── utils/
│   ├── pdf_parser.py
│   ├── text_extractor.py
│   └── validation.py
├── templates/
│   └── (populated later)
├── orchestrator.py
├── config.yaml
└── requirements.txt
```

#### 1.2: Build Step 1 Agent - Static Code Analysis

**Purpose:** Extract structured data from JIRA PDF

**Inputs:**
- JIRA requirements PDF

**Outputs:**
```json
{
  "acceptance_criteria": [
    {
      "id": "AC1",
      "description": "User can create an order",
      "preconditions": "User is authenticated",
      "steps": ["POST /orders with valid payload"],
      "expected_result": "Order created with 201 status"
    }
  ],
  "acceptance_tests": [
    {
      "id": "AT1",
      "name": "test_createOrder_validRequest_returns201",
      "steps": ["POST /api/v1/orders with CreateOrderRequest"],
      "assertions": ["HTTP 201", "response has orderId"]
    }
  ],
  "entities": ["Order", "Customer", "OrderItem"],
  "endpoints": [
    {"method": "POST", "path": "/orders", "description": "Create order"},
    {"method": "GET", "path": "/orders/{id}", "description": "Get order"}
  ],
  "non_functional_requirements": {
    "performance": "Response time < 200ms",
    "security": "OAuth2 required"
  }
}
```

**Implementation Approach:**

```python
# step1_static_analysis_agent.py
import pypdf
import json
from typing import Dict, List

class StaticAnalysisAgent:
    """
    Extracts structured requirements from JIRA PDF.
    Uses text extraction + regex patterns + LLM parsing.
    """
    
    def __init__(self):
        self.patterns = {
            'acceptance_criteria': r'(?:Acceptance Criteria|AC):?(.*?)(?=\n[A-Z])',
            'test_cases': r'(?:Test Case|TC|Acceptance Test):?(.*?)(?=\n[A-Z])',
            'endpoints': r'(?:API|Endpoint):?\s*(?:POST|GET|PUT|DELETE)\s+(/\w+)',
        }
    
    def parse_pdf(self, pdf_path: str) -> Dict:
        """Parse JIRA PDF and extract requirements."""
        # 1. Extract text from PDF
        text = self._extract_text(pdf_path)
        
        # 2. Use regex patterns to identify sections
        criteria = self._extract_section('acceptance_criteria', text)
        tests = self._extract_section('test_cases', text)
        endpoints = self._extract_endpoints(text)
        
        # 3. Return structured data
        return {
            'acceptance_criteria': criteria,
            'acceptance_tests': tests,
            'endpoints': endpoints,
            'raw_text': text
        }
    
    def _extract_text(self, pdf_path: str) -> str:
        """Extract text from PDF."""
        reader = pypdf.PdfReader(pdf_path)
        text = ""
        for page in reader.pages:
            text += page.extract_text()
        return text
    
    def _extract_section(self, section_name: str, text: str) -> List[Dict]:
        """Extract specific section using regex."""
        pattern = self.patterns[section_name]
        matches = re.findall(pattern, text, re.IGNORECASE | re.DOTALL)
        return [{'raw': match} for match in matches]
    
    def _extract_endpoints(self, text: str) -> List[Dict]:
        """Extract API endpoints."""
        # Simple regex-based extraction
        pattern = r'(POST|GET|PUT|DELETE)\s+(/[\w/{}]+)'
        matches = re.findall(pattern, text)
        return [
            {'method': method, 'path': path}
            for method, path in matches
        ]
```

**Dependencies:**
```
pypdf==3.17.0
pydantic==2.0.0
pytest==7.4.0
```

**Tests:**
```python
def test_parse_pdf_extracts_acceptance_criteria():
    agent = StaticAnalysisAgent()
    result = agent.parse_pdf("test_jira_export.pdf")
    assert len(result['acceptance_criteria']) > 0
    assert 'description' in result['acceptance_criteria'][0]

def test_parse_pdf_extracts_endpoints():
    agent = StaticAnalysisAgent()
    result = agent.parse_pdf("test_jira_export.pdf")
    assert any(e['method'] == 'POST' for e in result['endpoints'])
```

**Deliverable:**
- ✅ `step1_static_analysis_agent.py` (functional)
- ✅ Unit tests passing
- ✅ Sample PDF test file with known output
- ✅ `step1_output_example.json` (expected output)

---

## Week 2: Step 2-3 Agents (Requirements & OpenAPI)

### Tasks

#### 2.1: Build Step 2 Agent - Requirements Normalization

**Purpose:** Normalize extracted data into structured model

**Input:** Step 1 output  
**Output:** Normalized requirements model

```python
# step2_requirements_agent.py
class RequirementsNormalizationAgent:
    """
    Normalizes extracted requirements into structured format.
    - Standardizes endpoint definitions
    - Identifies entities & relationships
    - Maps acceptance criteria to endpoints
    """
    
    def normalize(self, raw_data: Dict) -> Dict:
        """
        Input: raw extraction from PDF
        Output: structured, deduplicated, validated requirements
        """
        endpoints = self._normalize_endpoints(raw_data['endpoints'])
        entities = self._extract_entities(endpoints, raw_data)
        criteria_mapping = self._map_criteria_to_endpoints(
            raw_data['acceptance_criteria'], 
            endpoints
        )
        
        return {
            'endpoints': endpoints,
            'entities': entities,
            'criteria_mapping': criteria_mapping,
            'quality_score': self._validate(endpoints, entities)
        }
    
    def _normalize_endpoints(self, raw_endpoints: List[Dict]) -> List[Dict]:
        """Standardize endpoint definitions."""
        normalized = []
        for ep in raw_endpoints:
            normalized.append({
                'method': ep['method'].upper(),
                'path': self._normalize_path(ep['path']),
                'entity': self._extract_entity_from_path(ep['path']),
                'operation': self._infer_operation(ep['method']),
            })
        return self._deduplicate(normalized)
    
    def _extract_entities(self, endpoints: List[Dict], raw_data: Dict) -> List[str]:
        """Extract domain entities from endpoints."""
        entities = set()
        for ep in endpoints:
            entities.add(ep['entity'])
        return sorted(list(entities))
```

#### 2.2: Build Step 3 Agent - OpenAPI Generator

**Purpose:** Generate full OpenAPI 3.0 specification

**Input:** Normalized requirements + optional sample Swagger  
**Output:** OpenAPI 3.0 YAML file

```python
# step3_openapi_agent.py
class OpenAPIAgent:
    """
    Generates OpenAPI 3.0 specification from requirements.
    - Creates endpoint schemas
    - Generates request/response models
    - Validates against sample swagger (if provided)
    """
    
    def generate_openapi(self, requirements: Dict, sample_swagger: Dict = None) -> Dict:
        """Generate complete OpenAPI spec."""
        spec = {
            'openapi': '3.0.0',
            'info': {
                'title': requirements.get('title', 'Generated API'),
                'version': '1.0.0'
            },
            'paths': {},
            'components': {'schemas': {}}
        }
        
        # Generate path definitions
        for endpoint in requirements['endpoints']:
            path_spec = self._generate_path_spec(endpoint, requirements)
            spec['paths'][endpoint['path']] = path_spec
        
        # Generate component schemas
        for entity in requirements['entities']:
            schema = self._generate_schema(entity, requirements)
            spec['components']['schemas'][entity] = schema
        
        # Validate against sample (if provided)
        if sample_swagger:
            self._validate_against_sample(spec, sample_swagger)
        
        return spec
    
    def _generate_path_spec(self, endpoint: Dict, requirements: Dict) -> Dict:
        """Generate OpenAPI path spec for endpoint."""
        return {
            endpoint['method'].lower(): {
                'summary': endpoint.get('description', ''),
                'operationId': f"{endpoint['operation']}_{endpoint['entity']}",
                'requestBody': {
                    'required': True,
                    'content': {'application/json': {...}}
                },
                'responses': {
                    '201': {'description': 'Created'},
                    '400': {'description': 'Bad Request'}
                }
            }
        }
```

**Deliverable:**
- ✅ `step2_requirements_agent.py` (functional)
- ✅ `step3_openapi_agent.py` (functional)
- ✅ Integration tests between Step 1 → Step 2 → Step 3
- ✅ Sample `openapi-output.yaml`

---

## Week 3: Step 4-6 Agents (Code Generation & Tests)

### Tasks

#### 3.1: Build Step 4 Agent - Data Model Generation

**Purpose:** Generate JPA entities and DTOs

```python
# step4_datamodel_agent.py
class DataModelAgent:
    """
    Generates JPA entities and DTOs from OpenAPI spec.
    - Creates entity classes with JPA annotations
    - Generates immutable DTO records
    - Creates MapStruct mapper interfaces
    """
    
    def generate_models(self, openapi_spec: Dict, db_schema: Dict = None) -> Dict:
        """Generate data models."""
        entities = {}
        dtos = {}
        mappers = {}
        
        for schema_name, schema_def in openapi_spec['components']['schemas'].items():
            # Generate entity
            entities[schema_name] = self._generate_entity(schema_name, schema_def)
            
            # Generate request DTO
            dtos[f"{schema_name}Request"] = self._generate_request_dto(schema_name, schema_def)
            
            # Generate response DTO
            dtos[f"{schema_name}Response"] = self._generate_response_dto(schema_name, schema_def)
            
            # Generate mapper
            mappers[f"{schema_name}Mapper"] = self._generate_mapper(schema_name)
        
        return {'entities': entities, 'dtos': dtos, 'mappers': mappers}
    
    def _generate_entity(self, name: str, schema: Dict) -> str:
        """Generate JPA entity class."""
        template = """
@Entity
@Table(name = "{table_name}")
@Data
@NoArgsConstructor
@AllArgsConstructor
@Builder
public class {entity_name} {{
    @Id
    @GeneratedValue(strategy = GenerationType.UUID)
    private UUID id;
    {fields}
    @CreationTimestamp
    private LocalDateTime createdAt;
    @UpdateTimestamp
    private LocalDateTime updatedAt;
}}
"""
        fields = self._generate_fields(schema)
        return template.format(
            table_name=self._to_snake_case(name),
            entity_name=name,
            fields=fields
        )
```

#### 3.2: Build Step 5 Agent - Code Generator

**Purpose:** Generate Spring Boot project skeleton

```python
# step5_codegen_agent.py
class CodeGeneratorAgent:
    """
    Generates complete Spring Boot project.
    - Controllers (thin, routing only)
    - Service interfaces & implementations (with TODO stubs)
    - Repository interfaces
    - Configuration classes
    - build.gradle / pom.xml
    """
    
    def generate_project(self, context: GenerationContext) -> str:
        """Generate complete project and return ZIP path."""
        project_dir = self._create_project_structure(context)
        
        # Generate code files
        for endpoint in context.endpoints:
            self._generate_controller(project_dir, endpoint)
            self._generate_service(project_dir, endpoint)
            self._generate_repository(project_dir, endpoint)
        
        # Generate build files
        self._generate_build_gradle(project_dir, context)
        self._generate_pom_xml(project_dir, context)
        
        # Generate configs
        self._generate_application_yml(project_dir, context)
        
        # ZIP and return
        return self._create_zip(project_dir)
```

#### 3.3: Build Step 6 Agent - Test Generator

**Purpose:** Generate smoke tests and static analysis config

```python
# step6_testgen_agent.py
class TestGeneratorAgent:
    """
    Generates smoke tests and test configuration.
    - Parameterized tests from acceptance criteria
    - Happy-path endpoint tests
    - Static analysis config (Spotless, Checkstyle)
    """
    
    def generate_tests(self, context: GenerationContext) -> Dict:
        """Generate test classes and config."""
        smoke_tests = self._generate_smoke_tests(context)
        test_config = self._generate_test_config(context)
        static_analysis_config = self._generate_static_analysis_config()
        
        return {
            'smoke_tests': smoke_tests,
            'test_config': test_config,
            'static_analysis': static_analysis_config
        }
    
    def _generate_smoke_tests(self, context: GenerationContext) -> str:
        """Generate ApiSmokeTests.java from acceptance criteria."""
        template = """
@ExtendWith(SpringExtension.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Slf4j
public class ApiSmokeTests {{
    @Autowired
    private TestRestTemplate restTemplate;
    
    {test_methods}
}}
"""
        test_methods = ""
        for i, criteria in enumerate(context.acceptance_criteria):
            test_methods += self._generate_test_method(criteria, i)
        
        return template.format(test_methods=test_methods)
```

**Deliverable:**
- ✅ `step4_datamodel_agent.py` (functional)
- ✅ `step5_codegen_agent.py` (functional)
- ✅ `step6_testgen_agent.py` (functional)
- ✅ Full integration test: PDF → ZIP (end-to-end)
- ✅ Sample generated project

---

## Phase 2: Enhanced Features (Weeks 4-6)

### Goal
Add advanced features: migrations, CI/CD, documentation, performance testing

### Features
- [ ] Liquibase/Flyway migration generation
- [ ] GitHub Actions CI/CD pipeline
- [ ] Docker & docker-compose generation
- [ ] Kubernetes manifests
- [ ] Performance test templates
- [ ] API documentation generation

---

## Quick Start for Implementation

### Step 1: Clone & Setup
```bash
git clone https://github.com/harshmighlaniaa/.copilot.git
cd .copilot

# Create agents directory
mkdir -p agents utils templates

# Install dependencies
pip install -r requirements.txt
```

### Step 2: Start Week 1
```bash
# Create Step 1 agent
touch agents/step1_static_analysis_agent.py

# Copy the code from this roadmap
# Run tests
pytest agents/test_step1_agent.py -v
```

### Step 3: Test with Sample PDF
```bash
# Get a sample JIRA export (or create one)
# Run Step 1
python agents/step1_static_analysis_agent.py --pdf sample_jira.pdf

# Verify output matches expected format
cat output/step1_analysis.json
```

---

## Testing Strategy

### Unit Tests (for each agent)
```python
# agents/test_step1_agent.py
def test_parse_simple_pdf():
    """Test PDF parsing with minimal PDF."""
    
def test_extract_acceptance_criteria():
    """Test AC extraction."""
    
def test_extract_endpoints():
    """Test endpoint extraction."""
```

### Integration Tests (agent to agent)
```python
# integration_tests/test_full_pipeline.py
def test_step1_to_step2():
    """Step 1 output → Step 2 input."""
    
def test_step1_to_step3():
    """End-to-end: Step 1 → Step 3."""
    
def test_full_pipeline_step1_to_step6():
    """Complete pipeline PDF → Generated Project."""
```

### Acceptance Tests
```python
# acceptance_tests/test_generated_api.py
def test_generated_api_compiles():
    """Generated project should compile without errors."""
    
def test_generated_smoke_tests_pass():
    """Generated smoke tests should pass."""
    
def test_generated_api_follows_conventions():
    """Verify fvh-insights patterns are followed."""
```

---

## Success Criteria

### Week 1 (Step 1)
- ✅ Extract 10+ acceptance criteria from sample PDF
- ✅ Extract 10+ test cases
- ✅ Identify 5+ endpoints
- ✅ Accuracy > 90% (manual verification)

### Week 2 (Steps 2-3)
- ✅ Normalize requirements without data loss
- ✅ Generate valid OpenAPI 3.0 YAML
- ✅ Validate against sample Swagger (if provided)

### Week 3 (Steps 4-6)
- ✅ Generate compilable Java classes
- ✅ Generated code follows Spring Boot conventions
- ✅ Smoke tests executable and meaningful
- ✅ Static analysis config working (spotless, checkstyle)

### End of Phase 1
- ✅ PDF → Generated Spring Boot API (end-to-end working)
- ✅ Smoke tests pass for generated API
- ✅ Code quality checks pass
- ✅ Framework is "plug-and-play"

---

## Repository Structure (After Implementation)

```
.copilot/
├── FRAMEWORK_DESIGN.md
├── QUICKSTART.md
├── TEMPLATES.md
├── IMPLEMENTATION_ROADMAP.md             # This file
├── AGENT_SPECS.md                         # Coming next
│
├── orchestrator.py                        # Main entry point
├── config.yaml                            # Default configuration
│
├── agents/
│   ├── __init__.py
│   ├── step1_static_analysis_agent.py
│   ├── step2_requirements_agent.py
│   ├── step3_openapi_agent.py
│   ├── step4_datamodel_agent.py
│   ├── step5_codegen_agent.py
│   ├── step6_testgen_agent.py
│   └── base_agent.py                     # Base class for all agents
│
├── utils/
│   ├── __init__.py
│   ├── pdf_parser.py
│   ├── template_renderer.py
│   ├── validation.py
│   ├── context_manager.py
│   └── logger.py
│
├── templates/
│   ├── code-templates/
│   ├── config-templates/
│   ├── project-templates/
│   └── openapi-templates/
│
├── tests/
│   ├── unit/
│   ├── integration/
│   └── acceptance/
│
└── examples/
    ├── sample_jira_export.pdf
    ├── sample_swagger.yaml
    └── sample_db_schema.sql
```

---

## Next Document

After this roadmap, we'll create:
- **AGENT_SPECS.md** - Detailed specs for Step 1 Agent (what it does, inputs, outputs, pseudocode)

This will give you a complete blueprint to start coding! 🚀

