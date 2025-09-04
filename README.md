# Data Science Agent Infrastructure

This Terraform configuration deploys a complete data science agent infrastructure on Google Cloud Platform (GCP), including:

- **Vertex AI Agent** for AI-powered data science tasks
- **BigQuery** for data storage and analytics
- **Cloud Storage** for staging and temporary data
- **IAM** roles and service accounts for secure access
- **RAG (Retrieval-Augmented Generation)** support (optional)

## 🚀 Quick Start

### Prerequisites

- GCP Project with billing enabled
- Terraform >= 1.0 installed
- `gcloud` CLI configured with appropriate permissions
- Required GCP APIs enabled:
  - Vertex AI API
  - BigQuery API
  - Cloud Storage API
  - IAM API

### 1. Configuration Setup

First, set up your configuration files:

```bash
# Copy template configurations
cp configs/dev.tfvars configs/dev.tfvars.local
cp environments/dev/terraform.tfvars.example environments/dev/terraform.tfvars
```

Edit `configs/dev.tfvars.local` and replace placeholders:

```hcl
project_id = "your-actual-project-id"
bq_dataset_id = "your_dataset_name"
# ... other configurations
```

> 📝 See [CONFIG_SETUP.md](./CONFIG_SETUP.md) for detailed configuration instructions.

### 2. Deploy Infrastructure

Using the deployment script (recommended):

```bash
./deploy.sh -c configs/dev.tfvars.local init
./deploy.sh -c configs/dev.tfvars.local apply
```

Or manually:

```bash
cd environments/dev
terraform init
terraform apply -var-file="../../configs/dev.tfvars.local"
```

### 3. Test Deployment

```bash
./test-agent.sh dev
```

## 📁 Project Structure

```text
ds-infra/
├── compositions/           # High-level compositions
│   └── ds-agent/          # Main data science agent composition
├── modules/               # Reusable Terraform modules
│   ├── bigquery/         # BigQuery resources
│   ├── iam/              # IAM roles and service accounts
│   ├── rag/              # RAG corpus management
│   ├── storage/          # Cloud Storage buckets
│   └── vertex-ai/        # Vertex AI agent
├── environments/          # Environment-specific configurations
│   ├── dev/              # Development environment
│   └── prod/             # Production environment
├── configs/              # Configuration templates
│   ├── dev.tfvars        # Development config template
│   └── prod.tfvars       # Production config template
├── deploy.sh             # Deployment automation script
├── test-agent.sh         # Testing script
└── .gitignore           # Git ignore rules for sensitive files
```

## 🔧 Configuration

### Environment Variables

All configuration can be provided via:

- Terraform variable files (`.tfvars`)
- Environment variables (prefixed with `TF_VAR_`)
- Command line arguments

### Key Variables

| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| `project_id` | GCP Project ID | ✅ | - |
| `environment` | Environment name | ✅ | - |
| `bq_dataset_id` | BigQuery dataset ID | ✅ | - |
| `location` | GCP region | ❌ | `us-central1` |
| `staging_bucket_name` | Staging bucket name | ❌ | Auto-generated |

## 🔒 Security

- **Sensitive data protection**: All actual configuration values are gitignored
- **IAM best practices**: Principle of least privilege
- **Deletion protection**: Configurable for production environments
- **Encryption**: All data encrypted at rest and in transit

## 🌍 Multi-Environment Support

The infrastructure supports multiple environments:

- **Development** (`dev`): Fast iteration, minimal resources
- **Production** (`prod`): High availability, enhanced security

Each environment has its own:

- State file
- Configuration
- Resource naming

## 📚 Documentation

- [Configuration Setup Guide](./CONFIG_SETUP.md)
- [Deployment Modes](./DEPLOYMENT_MODES.md)
- [Best Practices](./README_BEST_PRACTICES.md)
- [Terraform Concepts](./TERRAFORM_CONCEPTS.md)
- [Usage Examples](./USAGE_EXAMPLES.md)

## 🛠️ Advanced Usage

### Custom Modules

Add your own modules in the `modules/` directory and reference them in compositions.

### Remote State

Configure remote state storage for team collaboration:

```hcl
terraform {
  backend "gcs" {
    bucket = "your-terraform-state-bucket"
    prefix = "terraform/ds-agent/dev"
  }
}
```

### CI/CD Integration

The deployment script supports automation:

```bash
./deploy.sh -c configs/prod.tfvars.local -a apply  # Auto-approve
```

## 🐛 Troubleshooting

### Common Issues

1. **Permission denied**: Ensure your GCP credentials have the required roles
2. **API not enabled**: Enable required GCP APIs in your project
3. **Resource conflicts**: Check for existing resources with similar names

### Getting Help

1. Check the logs: `terraform plan` for validation issues
2. Validate configuration: `./deploy.sh validate`
3. Run tests: `./test-agent.sh dev`

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.
