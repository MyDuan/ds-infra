#!/bin/bash

# Data Science Agent Infrastructure Deployment Script
# This script automates the deployment of the data science agent infrastructure

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Default values
CONFIG_FILE=""
FORCE_INIT=false
AUTO_APPROVE=false
VERBOSE=false

# Functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

show_usage() {
    cat << EOF
Usage: $0 [OPTIONS] COMMAND

Commands:
    init        Initialize Terraform backend and providers
    plan        Show what Terraform will do
    apply       Apply the Terraform configuration
    destroy     Destroy the infrastructure
    validate    Validate the Terraform configuration
    test        Run post-deployment tests

Options:
    -c, --config FILE       Custom config file path [default: configs/dev.tfvars]
    -f, --force-init        Force Terraform re-initialization
    -y, --auto-approve      Auto-approve Terraform operations
    -v, --verbose           Enable verbose output
    -h, --help             Show this help message

Examples:
    $0 init                     # Initialize with default config
    $0 plan                     # Plan deployment
    $0 apply -y                 # Apply with auto-approval
    $0 apply -c configs/custom.tfvars  # Use custom config
    $0 destroy -y               # Destroy with auto-approval

Configuration:
    Default config: configs/dev.tfvars

EOF
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -c|--config)
                CONFIG_FILE="$2"
                shift 2
                ;;
            -f|--force-init)
                FORCE_INIT=true
                shift
                ;;
            -y|--auto-approve)
                AUTO_APPROVE=true
                shift
                ;;
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -h|--help)
                show_usage
                exit 0
                ;;
            init|plan|apply|destroy|validate|test)
                COMMAND="$1"
                shift
                ;;
            *)
                log_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    if [[ -z "$COMMAND" ]]; then
        log_error "No command specified"
        show_usage
        exit 1
    fi
}

# Check prerequisites
check_prerequisites() {
    log_info "Checking prerequisites..."

    # Check if terraform is installed
    if ! command -v terraform &> /dev/null; then
        log_error "Terraform is not installed. Please install Terraform."
        exit 1
    fi

    # Check if gcloud is installed and authenticated
    if ! command -v gcloud &> /dev/null; then
        log_error "Google Cloud SDK is not installed. Please install gcloud."
        exit 1
    fi

    # Check if authenticated
    if ! gcloud auth list --filter=status:ACTIVE --format="value(account)" | grep -q .; then
        log_error "Not authenticated with Google Cloud. Run 'gcloud auth login'"
        exit 1
    fi

    # Set working directory to composition
    WORK_DIR="compositions/ds-agent"
    if [[ ! -d "$WORK_DIR" ]]; then
        log_error "Composition directory '$WORK_DIR' does not exist"
        exit 1
    fi

    # Determine config file
    if [[ -n "$CONFIG_FILE" ]]; then
        if [[ ! -f "$CONFIG_FILE" ]]; then
            log_error "Custom config file '$CONFIG_FILE' does not exist"
            exit 1
        fi
        TFVARS_FILE="$CONFIG_FILE"
    else
        TFVARS_FILE="configs/dev.tfvars"
        if [[ ! -f "$TFVARS_FILE" ]]; then
            log_error "Default config file '$TFVARS_FILE' does not exist"
            log_info "Available configs: $(ls configs/*.tfvars 2>/dev/null | tr '\n' ' ')"
            exit 1
        fi
    fi

    log_success "Prerequisites check passed"
    log_info "Working directory: $WORK_DIR"
    log_info "Config file: $TFVARS_FILE"
}

# Initialize Terraform
terraform_init() {
    log_info "Initializing Terraform..."
    
    cd "$WORK_DIR"
    
    if [[ "$FORCE_INIT" == true ]]; then
        log_info "Force initialization - removing .terraform directory"
        rm -rf .terraform
    fi

    if [[ "$VERBOSE" == true ]]; then
        terraform init
    else
        terraform init > /dev/null
    fi

    log_success "Terraform initialized successfully"
    cd - > /dev/null
}

# Validate Terraform configuration
terraform_validate() {
    log_info "Validating Terraform configuration..."
    
    cd "$WORK_DIR"
    
    if terraform validate; then
        log_success "Terraform configuration is valid"
    else
        log_error "Terraform configuration validation failed"
        cd - > /dev/null
        exit 1
    fi
    
    cd - > /dev/null
}

# Plan Terraform deployment
terraform_plan() {
    log_info "Planning Terraform deployment..."
    
    cd "$WORK_DIR"
    
    # Use the config file
    terraform plan -var-file="../../$TFVARS_FILE" -out=tfplan
    
    log_success "Terraform plan completed. Review the output above."
    cd - > /dev/null
}

# Apply Terraform configuration
terraform_apply() {
    log_info "Applying Terraform configuration..."
    
    cd "$WORK_DIR"
    
    if [[ "$AUTO_APPROVE" == true ]]; then
        terraform apply -var-file="../../$TFVARS_FILE" -auto-approve
    else
        terraform apply -var-file="../../$TFVARS_FILE"
    fi
    
    if [[ $? -eq 0 ]]; then
        log_success "Terraform apply completed successfully"
        
        # Show outputs
        log_info "Infrastructure outputs:"
        terraform output
    else
        log_error "Terraform apply failed"
        cd - > /dev/null
        exit 1
    fi
    
    cd - > /dev/null
}

# Destroy Terraform infrastructure
terraform_destroy() {
    log_warning "This will destroy all infrastructure"
    
    if [[ "$AUTO_APPROVE" != true ]]; then
        read -p "Are you sure you want to continue? (yes/no): " confirm
        if [[ "$confirm" != "yes" ]]; then
            log_info "Destruction cancelled"
            exit 0
        fi
    fi
    
    cd "$WORK_DIR"
    
    if [[ "$AUTO_APPROVE" == true ]]; then
        terraform destroy -var-file="../../$TFVARS_FILE" -auto-approve
    else
        terraform destroy -var-file="../../$TFVARS_FILE"
    fi
    
    if [[ $? -eq 0 ]]; then
        log_success "Infrastructure destroyed successfully"
    else
        log_error "Terraform destroy failed"
        cd - > /dev/null
        exit 1
    fi
    
    cd - > /dev/null
}

# Test deployment
test_deployment() {
    log_info "Running post-deployment tests..."
    
    cd "$WORK_DIR"
    
    # Get outputs for testing
    PROJECT_ID=$(terraform output -raw project_id 2>/dev/null || echo "")
    AGENT_ID=$(terraform output -raw vertex_ai_agent_id 2>/dev/null || echo "")
    
    if [[ -z "$PROJECT_ID" ]]; then
        log_error "Cannot get project_id from Terraform outputs"
        cd - > /dev/null
        exit 1
    fi
    
    log_info "Testing project: $PROJECT_ID"
    
    # Test 1: Check if APIs are enabled
    log_info "Checking if required APIs are enabled..."
    APIS=("aiplatform.googleapis.com" "bigquery.googleapis.com" "storage.googleapis.com")
    
    for api in "${APIS[@]}"; do
        if gcloud services list --enabled --filter="name:$api" --format="value(name)" | grep -q "$api"; then
            log_success "API $api is enabled"
        else
            log_error "API $api is not enabled"
        fi
    done
    
    # Test 2: Check if storage bucket exists
    BUCKET_NAME=$(terraform output -raw staging_bucket_name 2>/dev/null || echo "")
    if [[ -n "$BUCKET_NAME" ]]; then
        if gsutil ls "gs://$BUCKET_NAME" &>/dev/null; then
            log_success "Staging bucket $BUCKET_NAME exists"
        else
            log_error "Staging bucket $BUCKET_NAME not accessible"
        fi
    fi
    
    # Test 3: Check BigQuery dataset
    DATASET_ID=$(terraform output -raw bigquery_dataset_id 2>/dev/null || echo "")
    if [[ -n "$DATASET_ID" ]]; then
        if bq ls "$PROJECT_ID:$DATASET_ID" &>/dev/null; then
            log_success "BigQuery dataset $DATASET_ID exists"
        else
            log_error "BigQuery dataset $DATASET_ID not accessible"
        fi
    fi
    
    log_success "Post-deployment tests completed"
    cd - > /dev/null
}

# Main execution
main() {
    log_info "Starting deployment script for Data Science Agent Infrastructure"
    
    # Check if we're in the right directory
    if [[ ! -f "deploy.sh" ]] || [[ ! -d "modules" ]]; then
        log_error "Please run this script from the ds-infra directory"
        exit 1
    fi
    
    parse_args "$@"
    check_prerequisites
    
    case "$COMMAND" in
        init)
            terraform_init
            ;;
        validate)
            terraform_validate
            ;;
        plan)
            terraform_init
            terraform_validate
            terraform_plan
            ;;
        apply)
            terraform_init
            terraform_validate
            terraform_plan
            terraform_apply
            ;;
        destroy)
            terraform_destroy
            ;;
        test)
            test_deployment
            ;;
        *)
            log_error "Unknown command: $COMMAND"
            show_usage
            exit 1
            ;;
    esac
    
    log_success "Script completed successfully"
}

# Run main function with all arguments
main "$@"
