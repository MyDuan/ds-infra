#!/bin/bash

# Security check script to ensure no sensitive data is committed
# Run this before pushing to GitHub

set -e

echo "🔍 Checking for sensitive data in ds-infra..."

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

ISSUES_FOUND=0

# Check for specific sensitive patterns
check_pattern() {
    local pattern="$1"
    local description="$2"
    local files
    
    files=$(grep -r "$pattern" . --exclude-dir=.git --exclude="*.log" --exclude="security-check.sh" --exclude="*CLEANUP.md" --exclude="README.md" --exclude="CONFIG_SETUP.md" 2>/dev/null || true)
    
    if [[ -n "$files" ]]; then
        echo -e "${RED}❌ Found $description:${NC}"
        echo "$files"
        echo
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
}

# Check for common sensitive patterns
echo "Checking for sensitive patterns..."

check_pattern "sj-analyticsplatform" "hardcoded project references"
check_pattern "forecasting_sticker_sales" "hardcoded dataset names"
check_pattern "@gmail\.com" "email addresses"
check_pattern "AKIA[0-9A-Z]{16}" "AWS access keys"
check_pattern "AIza[0-9A-Za-z_-]{35}" "Google API keys"
check_pattern "sk-[a-zA-Z0-9]{48}" "OpenAI API keys"
check_pattern "xoxb-[0-9]{13}-[0-9]{13}-[a-zA-Z0-9]{24}" "Slack bot tokens"

# Check for files that should not be committed
echo "Checking for files that should not be committed..."

if [[ -f "terraform.tfstate" ]]; then
    echo -e "${RED}❌ Found terraform.tfstate file${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

if [[ -f ".terraform/terraform.tfstate" ]]; then
    echo -e "${RED}❌ Found .terraform/terraform.tfstate file${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
fi

# Check for actual tfvars files (not templates)
find . -name "*.tfvars" -not -name "*.tfvars.example" -not -path "./.git/*" | while read -r file; do
    if [[ -s "$file" ]]; then  # File exists and is not empty
        echo -e "${YELLOW}⚠️  Found non-empty tfvars file: $file${NC}"
        echo "   Consider moving actual values to .local files"
        ISSUES_FOUND=$((ISSUES_FOUND + 1))
    fi
done

# Check if .gitignore exists and has required patterns
if [[ ! -f ".gitignore" ]]; then
    echo -e "${RED}❌ No .gitignore file found${NC}"
    ISSUES_FOUND=$((ISSUES_FOUND + 1))
else
    echo "✅ .gitignore file exists"
    
    # Check for important patterns in .gitignore
    required_patterns=("*.tfstate" "*.tfvars" ".terraform/" "terraform.tfplan")
    
    for pattern in "${required_patterns[@]}"; do
        if ! grep -q "$pattern" .gitignore; then
            echo -e "${YELLOW}⚠️  Pattern '$pattern' not found in .gitignore${NC}"
        fi
    done
fi

# Summary
echo
echo "🔍 Security check complete!"

if [[ $ISSUES_FOUND -eq 0 ]]; then
    echo -e "${GREEN}✅ No security issues found. Safe to commit!${NC}"
    exit 0
else
    echo -e "${RED}❌ Found $ISSUES_FOUND security issue(s). Please fix before committing.${NC}"
    echo
    echo "💡 Tips:"
    echo "  - Use placeholder values like 'YOUR_PROJECT_ID' in committed files"
    echo "  - Keep actual values in .local files or environment variables"
    echo "  - Make sure .gitignore includes all sensitive file patterns"
    exit 1
fi
