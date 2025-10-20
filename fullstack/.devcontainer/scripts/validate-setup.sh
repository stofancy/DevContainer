#!/bin/bash

# DevContainer Setup Validation Script
# Run this script to validate that all components are working correctly

# Set strict error handling
set -euo pipefail

# Color codes for output formatting
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Counters
PASSED=0
FAILED=0
WARNINGS=0

# Function to log test results
log_test() {
    local status="$1"
    local message="$2"
    
    case "$status" in
        "PASS")
            echo -e "${GREEN}✅ PASS:${NC} $message"
            ((PASSED++))
            ;;
        "FAIL")
            echo -e "${RED}❌ FAIL:${NC} $message"
            ((FAILED++))
            ;;
        "WARN")
            echo -e "${YELLOW}⚠️  WARN:${NC} $message"
            ((WARNINGS++))
            ;;
        "INFO")
            echo -e "${BLUE}ℹ️  INFO:${NC} $message"
            ;;
    esac
}

echo "🔍 DevContainer Setup Validation"
echo "================================="
echo ""

# Test 1: Check if required commands are available
log_test "INFO" "Testing required dependencies..."

required_commands=("git" "node" "npm" "sqlcmd" "ssh" "ssh-keygen")
for cmd in "${required_commands[@]}"; do
    if command -v "$cmd" >/dev/null 2>&1; then
        log_test "PASS" "$cmd is available"
    else
        log_test "FAIL" "$cmd is not available"
    fi
done

echo ""

# Test 2: Check Node.js setup
log_test "INFO" "Testing Node.js setup..."

if command -v node >/dev/null 2>&1; then
    node_version=$(node --version)
    log_test "PASS" "Node.js version: $node_version"
    
    if command -v npm >/dev/null 2>&1; then
        npm_version=$(npm --version)
        log_test "PASS" "npm version: $npm_version"
    else
        log_test "FAIL" "npm is not available"
    fi
else
    log_test "FAIL" "Node.js is not available"
fi

echo ""

# Test 3: Check SSH setup
log_test "INFO" "Testing SSH setup..."

if [ -f ~/.ssh/id_rsa ]; then
    log_test "PASS" "SSH private key exists"
    
    if [ -f ~/.ssh/id_rsa.pub ]; then
        log_test "PASS" "SSH public key exists"
        
        # Check key permissions
        private_perms=$(stat -c "%a" ~/.ssh/id_rsa 2>/dev/null || echo "unknown")
        public_perms=$(stat -c "%a" ~/.ssh/id_rsa.pub 2>/dev/null || echo "unknown")
        
        if [ "$private_perms" = "600" ]; then
            log_test "PASS" "SSH private key has correct permissions (600)"
        else
            log_test "WARN" "SSH private key permissions: $private_perms (should be 600)"
        fi
        
        if [ "$public_perms" = "644" ]; then
            log_test "PASS" "SSH public key has correct permissions (644)"
        else
            log_test "WARN" "SSH public key permissions: $public_perms (should be 644)"
        fi
        
        # Validate key format
        if ssh-keygen -l -f ~/.ssh/id_rsa.pub >/dev/null 2>&1; then
            log_test "PASS" "SSH public key format is valid"
        else
            log_test "FAIL" "SSH public key format is invalid"
        fi
    else
        log_test "FAIL" "SSH public key does not exist"
    fi
else
    log_test "WARN" "SSH private key does not exist (SSH authentication not available)"
fi

# Check SSH config
if [ -f ~/.ssh/config ]; then
    log_test "PASS" "SSH config file exists"
else
    log_test "WARN" "SSH config file does not exist"
fi

# Check known hosts
if [ -f ~/.ssh/known_hosts ]; then
    log_test "PASS" "SSH known hosts file exists"
    
    hosts_count=$(wc -l < ~/.ssh/known_hosts 2>/dev/null || echo "0")
    log_test "INFO" "Known hosts entries: $hosts_count"
else
    log_test "WARN" "SSH known hosts file does not exist"
fi

echo ""

# Test 4: Check SQL Server connectivity
log_test "INFO" "Testing SQL Server connectivity..."

# Load environment variables
if [ -f ".devcontainer/.env" ]; then
    set -a
    # shellcheck source=/dev/null
    source <(grep -v '^#' .devcontainer/.env | grep -v '^$')
    set +a
    log_test "PASS" ".env file loaded"
else
    log_test "WARN" ".devcontainer/.env file not found"
fi

if [ -n "${MSSQL_SA_PASSWORD:-}" ]; then
    log_test "PASS" "MSSQL_SA_PASSWORD is set"
    
    # Test SQL Server connection
    if echo "SELECT @@VERSION" | sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -d master >/dev/null 2>&1; then
        log_test "PASS" "SQL Server connection successful"
        
        # Get SQL Server version
        sql_version=$(echo "SELECT @@VERSION" | sqlcmd -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -d master -h -1 2>/dev/null | head -1 | tr -d '\n\r' || echo "unknown")
        log_test "INFO" "SQL Server version: ${sql_version:0:50}..."
    else
        log_test "FAIL" "SQL Server connection failed"
    fi
else
    log_test "WARN" "MSSQL_SA_PASSWORD is not set"
fi

echo ""

# Test 5: Check Git configuration
log_test "INFO" "Testing Git configuration..."

if git config --get user.name >/dev/null 2>&1; then
    git_name=$(git config --get user.name)
    log_test "PASS" "Git user.name is set: $git_name"
else
    log_test "WARN" "Git user.name is not set"
fi

if git config --get user.email >/dev/null 2>&1; then
    git_email=$(git config --get user.email)
    log_test "PASS" "Git user.email is set: $git_email"
else
    log_test "WARN" "Git user.email is not set"
fi

echo ""

# Summary
echo "================================="
echo "🔍 Validation Summary"
echo "================================="
echo -e "${GREEN}✅ Passed: $PASSED${NC}"
echo -e "${YELLOW}⚠️  Warnings: $WARNINGS${NC}"
echo -e "${RED}❌ Failed: $FAILED${NC}"
echo ""

if [ $FAILED -eq 0 ]; then
    if [ $WARNINGS -eq 0 ]; then
        echo -e "${GREEN}🎉 All tests passed! Your DevContainer is fully configured.${NC}"
        exit 0
    else
        echo -e "${YELLOW}✅ Setup is functional with some warnings. Check the warnings above.${NC}"
        exit 0
    fi
else
    echo -e "${RED}❌ Some critical tests failed. Please review the errors above.${NC}"
    echo ""
    echo "Common fixes:"
    echo "• Rebuild the DevContainer if configuration changes were made"
    echo "• Check .devcontainer/.env for missing environment variables"
    echo "• Ensure SQL Server container is running and healthy"
    echo "• Run the SSH setup script if SSH keys are missing"
    exit 1
fi
