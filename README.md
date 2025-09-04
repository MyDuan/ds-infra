# Data Science Agent Infrastructure

Terraform configuration for deploying a complete data science agent system on Google Cloud Platform.

## 📁 Project Structure

```text
ds-infra/
├── compositions/
│   └── ds-agent/              # Main deployment entry point
│       ├── main.tf           # Orchestrates all modules
│       ├── variables.tf      # Input variables
│       ├── outputs.tf        # Output values
│       └── terraform.tfvars.example
├── modules/                   # Reusable Terraform modules
│   ├── bigquery/             # BigQuery dataset and tables
│   ├── iam/                  # IAM roles and service accounts
│   ├── storage/              # Cloud Storage buckets
│   ├── vertex-ai/            # Vertex AI service accounts
│   └── data-science-setup/   # Agent building and deployment
├── configs/                   # Configuration files
│   ├── dev.tfvars           # Development template
│   └── dev.tfvars.local     # Your actual values (gitignored)
└── README.md                 # This file
```

## 🚀 Deployment Steps

### 1. Setup Configuration

```bash
# Copy configuration template
cp configs/dev.tfvars configs/dev.tfvars.local
```

Edit `configs/dev.tfvars.local`:

```hcl
project_id = "your-project-id"
location   = "us-east4"
environment = "dev"
bq_dataset_id = "forecasting_sticker_sales"
staging_bucket_name = "your-project-id-ds-agent-staging-dev"
recreate_rag_corpus = true
deploy_to_agent_engine = true
```

### 2. Deploy

```bash
cd compositions/ds-agent
terraform init
terraform apply -var-file="../../configs/dev.tfvars.local" -auto-approve
```

This will automatically:
- Create BigQuery dataset and load sample data
- Set up Cloud Storage and IAM
- Build RAG corpus
- Deploy agent to Vertex AI Agent Engine

### 3. Access Agent

Get agent details:
```bash
terraform output
```

Use in Python:
```python
import vertexai
agent_engine = vertexai.agent_engines.get('projects/PROJECT_ID/locations/LOCATION/reasoningEngines/AGENT_ID')
response = agent_engine.query(content="Analyze the sales data")
```

## 🛠️ What Gets Deployed

- **BigQuery**: Dataset with training/test data (229K+ rows)
- **Storage**: Staging bucket for agent artifacts  
- **IAM**: Service accounts with minimal permissions
- **RAG**: Knowledge corpus with documentation
- **Agent Engine**: Multi-agent system on Vertex AI

