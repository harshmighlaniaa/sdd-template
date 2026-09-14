#!/bin/bash

# SDD Template - Feature Status Checker
# This script displays the status of all optional features

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
FEATURES_FILE="$PROJECT_ROOT/features.yml"

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  Spec-Driven Development Template - Feature Status Report     ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

if [ ! -f "$FEATURES_FILE" ]; then
    echo "❌ Error: features.yml not found at $FEATURES_FILE"
    echo ""
    echo "Create it using:"
    echo "  cp features.yml.example features.yml"
    exit 1
fi

# Parse YAML and display features
# This is a simple bash script - for production use yq or similar tool

echo "📋 Tier 1: Production Readiness"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  1. JWT Authentication"
if grep -q "jwt-authentication:" "$FEATURES_FILE"; then
    if grep -A1 "jwt-authentication:" "$FEATURES_FILE" | grep -q "enabled: true"; then
        echo "     Status: ✅ ENABLED"
    else
        echo "     Status: ⏸️  DISABLED"
    fi
fi
echo ""

echo "  2. Flyway Migrations"
if grep -q "flyway-migrations:" "$FEATURES_FILE"; then
    if grep -A1 "flyway-migrations:" "$FEATURES_FILE" | grep -q "enabled: true"; then
        echo "     Status: ✅ ENABLED"
    else
        echo "     Status: ⏸️  DISABLED"
    fi
fi
echo ""

echo "  3. Observability & Monitoring"
if grep -q "metrics-collection:" "$FEATURES_FILE"; then
    if grep -A1 "metrics-collection:" "$FEATURES_FILE" | grep -q "enabled: true"; then
        echo "     Status: ✅ ENABLED"
    else
        echo "     Status: ⏸️  DISABLED"
    fi
fi
echo ""

echo "  4. Docker Support"
if grep -q "docker:" "$FEATURES_FILE"; then
    if grep -A1 "^  docker:" "$FEATURES_FILE" | grep -q "enabled: true"; then
        echo "     Status: ✅ ENABLED"
    else
        echo "     Status: ⏸️  DISABLED"
    fi
fi
echo ""
echo ""

echo "📋 Tier 2: Framework Maturity"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  5. API Versioning"
if grep -q "versioning:" "$FEATURES_FILE"; then
    if grep -A1 "versioning:" "$FEATURES_FILE" | grep -q "enabled: true"; then
        echo "     Status: ✅ ENABLED"
    else
        echo "     Status: ⏸️  DISABLED"
    fi
fi
echo ""

echo "  6. Multi-Feature Conflict Resolution"
if grep -q "dependency-management:" "$FEATURES_FILE"; then
    if grep -A1 "dependency-management:" "$FEATURES_FILE" | grep -q "enabled: true"; then
        echo "     Status: ✅ ENABLED"
    else
        echo "     Status: ⏸️  DISABLED"
    fi
fi
echo ""

echo "  7. Caching Strategy"
if grep -q "caching:" "$FEATURES_FILE"; then
    if grep -A1 "caching:" "$FEATURES_FILE" | grep -q "enabled: true"; then
        echo "     Status: ✅ ENABLED"
    else
        echo "     Status: ⏸️  DISABLED"
    fi
fi
echo ""

echo "  8. Rate Limiting"
if grep -q "rate-limiting:" "$FEATURES_FILE"; then
    if grep -A1 "rate-limiting:" "$FEATURES_FILE" | grep -q "enabled: true"; then
        echo "     Status: ✅ ENABLED"
    else
        echo "     Status: ⏸️  DISABLED"
    fi
fi
echo ""
echo ""

echo "📋 Tier 3: Developer Experience"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "  9. Integration Test Suite"
if grep -q "integration-tests:" "$FEATURES_FILE"; then
    if grep -A1 "integration-tests:" "$FEATURES_FILE" | grep -q "enabled: true"; then
        echo "     Status: ✅ ENABLED"
    else
        echo "     Status: ⏸️  DISABLED"
    fi
fi
echo ""

echo "  10. Troubleshooting Guide"
if grep -q "troubleshooting-guide:" "$FEATURES_FILE"; then
    if grep -A1 "troubleshooting-guide:" "$FEATURES_FILE" | grep -q "enabled: true"; then
        echo "     Status: ✅ ENABLED"
    else
        echo "     Status: ⏸️  DISABLED"
    fi
fi
echo ""

echo "  11. Architecture Decision Records (ADRs)"
if grep -q "adrs:" "$FEATURES_FILE"; then
    if grep -A1 "adrs:" "$FEATURES_FILE" | grep -q "enabled: true"; then
        echo "     Status: ✅ ENABLED"
    else
        echo "     Status: ⏸️  DISABLED"
    fi
fi
echo ""

echo "  12. Performance Testing Framework"
if grep -q "performance-benchmarks:" "$FEATURES_FILE"; then
    if grep -A1 "performance-benchmarks:" "$FEATURES_FILE" | grep -q "enabled: true"; then
        echo "     Status: ✅ ENABLED"
    else
        echo "     Status: ⏸️  DISABLED"
    fi
fi
echo ""
echo ""

# Count enabled features
ENABLED_COUNT=$(grep -c "enabled: true" "$FEATURES_FILE" || echo "0")
TOTAL_COUNT=12

echo "╔════════════════════════════════════════════════════════════════╗"
echo "║  Summary                                                       ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║  Enabled Features:  $ENABLED_COUNT / $TOTAL_COUNT                                       ║"
echo "║  Coverage:          $((ENABLED_COUNT * 100 / TOTAL_COUNT))%                                            ║"
echo "╠════════════════════════════════════════════════════════════════╣"
echo "║  To enable a feature:                                          ║"
echo "║  1. Edit features.yml                                          ║"
echo "║  2. Set 'enabled: true' for the desired feature                ║"
echo "║  3. Restart the application                                    ║"
echo "║                                                                ║"
echo "║  Or use environment variables:                                 ║"
echo "║  export FEATURES_SECURITY_JWT_AUTHENTICATION_ENABLED=true      ║"
echo "╚════════════════════════════════════════════════════════════════╝"
echo ""

if [ "$ENABLED_COUNT" -eq 0 ]; then
    echo "💡 Tip: Start with Tier 1 features for production readiness"
    echo "📚 See FEATURES.md for detailed information on each feature"
fi

echo ""
