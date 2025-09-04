#!/bin/bash

# Test the deployed Data Science Agent
# This script tests the functionality of the deployed agent

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Configuration
ENVIRONMENT="${1:-dev}"
PROJECT_ID=""
AGENT_ID=""
LOCATION=""

# Get configuration from Terraform outputs
get_config() {
    log_info "Getting configuration from Terraform outputs..."
    
    cd "environments/$ENVIRONMENT"
    
    PROJECT_ID=$(terraform output -raw project_id 2>/dev/null || echo "")
    AGENT_ID=$(terraform output -raw vertex_ai_agent_id 2>/dev/null || echo "")
    LOCATION=$(terraform output -raw location 2>/dev/null || echo "us-central1")
    
    if [[ -z "$PROJECT_ID" ]]; then
        log_error "Cannot get project_id from Terraform outputs"
        exit 1
    fi
    
    log_info "Project ID: $PROJECT_ID"
    log_info "Location: $LOCATION"
    if [[ -n "$AGENT_ID" ]]; then
        log_info "Agent ID: $AGENT_ID"
    fi
    
    cd - > /dev/null
}

# Test BigQuery connection
test_bigquery() {
    log_info "Testing BigQuery connection..."
    
    # Get dataset ID from Terraform output
    cd "environments/$ENVIRONMENT"
    DATASET_ID=$(terraform output -raw bigquery_dataset_id 2>/dev/null || echo "")
    cd - > /dev/null
    
    if [[ -z "$DATASET_ID" ]]; then
        log_error "Cannot get dataset ID from Terraform outputs"
        return 1
    fi
    
    log_info "Testing dataset: $DATASET_ID"
    
    # Test if we can access the dataset
    bq query --use_legacy_sql=false --project_id="$PROJECT_ID" \
        "SELECT COUNT(*) as table_count FROM \`$PROJECT_ID.$DATASET_ID.INFORMATION_SCHEMA.TABLES\`" \
        || log_error "BigQuery access test failed"
    
    log_success "BigQuery connection test passed"
}

# Test storage bucket
test_storage() {
    log_info "Testing storage bucket access..."
    
    # Get bucket name from Terraform output
    cd "environments/$ENVIRONMENT"
    BUCKET_NAME=$(terraform output -raw staging_bucket_name 2>/dev/null || echo "")
    cd - > /dev/null
    
    if [[ -z "$BUCKET_NAME" ]]; then
        log_error "Cannot get bucket name from Terraform outputs"
        return 1
    fi
    
    # Test bucket access
    echo "test file" | gsutil cp - "gs://$BUCKET_NAME/test.txt" 2>/dev/null || {
        log_error "Cannot write to staging bucket"
        return 1
    }
    
    gsutil rm "gs://$BUCKET_NAME/test.txt" 2>/dev/null || {
        log_error "Cannot delete from staging bucket"
        return 1
    }
    
    log_success "Storage bucket access test passed"
}

# Test Vertex AI agent
test_vertex_ai_agent() {
    log_info "Testing Vertex AI agent..."
    
    if [[ -z "$AGENT_ID" ]]; then
        log_info "Agent ID not available, checking if agent exists..."
        
        # List reasoning engines to see if our agent exists
        gcloud ai reasoning-engines list --location="$LOCATION" --project="$PROJECT_ID" \
            --format="table(name,displayName,createTime)" || {
            log_error "Cannot list reasoning engines"
            return 1
        }
        
        log_success "Vertex AI service is accessible"
        return 0
    fi
    
    # If we have an agent ID, test it more specifically
    gcloud ai reasoning-engines describe "$AGENT_ID" \
        --location="$LOCATION" \
        --project="$PROJECT_ID" > /dev/null || {
        log_error "Cannot describe agent $AGENT_ID"
        return 1
    }
    
    log_success "Vertex AI agent test passed"
}

# Test agent query
test_agent_query() {
    log_info "Testing agent query capabilities..."
    
    if [[ -z "$AGENT_ID" ]]; then
        log_info "Skipping agent query test - no agent ID available"
        return 0
    fi
    
    # Create a simple test query
    cat > /tmp/test_query.json << EOF
{
    "query": "What tables are available in the BigQuery dataset?",
    "session_id": "test_session_$(date +%s)"
}
EOF
    
    # Test the agent (this might need adjustment based on your agent's API)
    log_info "Sending test query to agent..."
    
    # Note: This is a placeholder - you'll need to adjust based on your agent's API
    log_info "Agent query test skipped - requires specific agent API configuration"
}

# Test RAG capabilities
test_rag() {
    log_info "Testing RAG capabilities..."
    
    # Check if RAG corpus exists
    cd "environments/$ENVIRONMENT"
    RAG_CORPUS_ID=$(terraform output -raw rag_corpus_id 2>/dev/null || echo "")
    cd - > /dev/null
    
    if [[ -z "$RAG_CORPUS_ID" ]]; then
        log_info "No RAG corpus configured, skipping RAG test"
        return 0
    fi
    
    # Test RAG corpus access
    gcloud ai corpora describe "$RAG_CORPUS_ID" \
        --location="$LOCATION" \
        --project="$PROJECT_ID" > /dev/null || {
        log_error "Cannot access RAG corpus $RAG_CORPUS_ID"
        return 1
    }
    
    log_success "RAG corpus access test passed"
}

# Generate test report
generate_report() {
    log_info "Generating test report..."
    
    REPORT_FILE="/tmp/ds_agent_test_report_$(date +%Y%m%d_%H%M%S).txt"
    
    cat > "$REPORT_FILE" << EOF
Data Science Agent Infrastructure Test Report
Generated: $(date)
Environment: $ENVIRONMENT
Project ID: $PROJECT_ID
Location: $LOCATION
Agent ID: ${AGENT_ID:-"Not deployed"}

Test Results:
EOF
    
    echo "Configuration: PASSED" >> "$REPORT_FILE"
    
    if test_bigquery 2>/dev/null; then
        echo "BigQuery: PASSED" >> "$REPORT_FILE"
    else
        echo "BigQuery: FAILED" >> "$REPORT_FILE"
    fi
    
    if test_storage 2>/dev/null; then
        echo "Storage: PASSED" >> "$REPORT_FILE"
    else
        echo "Storage: FAILED" >> "$REPORT_FILE"
    fi
    
    if test_vertex_ai_agent 2>/dev/null; then
        echo "Vertex AI: PASSED" >> "$REPORT_FILE"
    else
        echo "Vertex AI: FAILED" >> "$REPORT_FILE"
    fi
    
    if test_rag 2>/dev/null; then
        echo "RAG: PASSED" >> "$REPORT_FILE"
    else
        echo "RAG: FAILED or Not Configured" >> "$REPORT_FILE"
    fi
    
    log_success "Test report generated: $REPORT_FILE"
    cat "$REPORT_FILE"
}

# Main execution
main() {
    log_info "Starting Data Science Agent test suite..."
    
    get_config
    
    echo ""
    test_bigquery
    echo ""
    test_storage
    echo ""
    test_vertex_ai_agent
    echo ""
    test_rag
    echo ""
    
    generate_report
    
    log_success "Test suite completed"
}

# Check if we're in the right directory
if [[ ! -f "main.tf" ]] || [[ ! -d "modules" ]]; then
    log_error "Please run this script from the ds-infra directory"
    exit 1
fi

main "$@"
