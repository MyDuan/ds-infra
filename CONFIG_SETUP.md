# Configuration Setup Guide

This directory contains template configurations for different environments. Follow these steps to set up your actual configurations:

## Quick Start

1. **Copy the example configurations:**

   ```bash
   # For development environment
   cp configs/dev.tfvars configs/dev.tfvars.local
   cp environments/dev/terraform.tfvars.example environments/dev/terraform.tfvars
   
   # For production environment
   cp configs/prod.tfvars configs/prod.tfvars.local
   cp environments/prod/terraform.tfvars.example environments/prod/terraform.tfvars
   ```

2. **Edit the configurations with your actual values:**
   - Replace `YOUR_PROJECT_ID` with your actual GCP project ID
   - Replace `YOUR_DATASET_ID` with your BigQuery dataset ID
   - Update other placeholders as needed

3. **Deploy:**

   ```bash
   # Using the deployment script
   ./deploy.sh -c configs/dev.tfvars.local apply
   
   # Or manually
   cd environments/dev
   terraform init
   terraform apply -var-file="../../configs/dev.tfvars.local"
   ```

## Configuration Files

### Template Files (committed to Git)

- `configs/*.tfvars` - Environment configuration templates
- `environments/*/terraform.tfvars.example` - Variable templates
- `compositions/*/terraform.tfvars.example` - Composition templates

### Local Files (gitignored)

- `configs/*.tfvars.local` - Your actual configurations
- `environments/*/terraform.tfvars` - Environment-specific variables
- `compositions/*/terraform.tfvars` - Composition-specific variables

## Security Notes

- All `*.tfvars` files (except `.example` files) are gitignored to prevent accidentally committing sensitive data
- Use `.local` suffix for your actual configuration files
- Always review what you're committing before pushing to GitHub

## Environment Variables

You can also use environment variables instead of tfvars files:

```bash
export TF_VAR_project_id="your-project-id"
export TF_VAR_environment="dev"
export TF_VAR_bq_dataset_id="your-dataset"
```
