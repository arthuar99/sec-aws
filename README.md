# Secure AWS Infrastructure with Terraform

![Terraform CI](https://github.com/arthuar99/sec-aws/actions/workflows/terraform-ci.yml/badge.svg)

This project provisions a secure, high-availability AWS infrastructure for a FastAPI application using Terraform.

## Architecture

![Architecture](https://github.com/user-attachments/assets/...) <!-- Add architecture diagram link if available -->

Key components:
- **VPC**: Custom VPC with public and private subnets across 2 Availability Zones.
- **Networking**:
  - `Public Subnets`: ALB, NAT Gateway, Bastion (optional).
  - `Private App Subnets`: ECS/EC2 instances for FastAPI application.
  - `Private DB Subnets`: RDS (PostgreSQL) and ElastiCache (Redis).
- **Security**:
  - **WAF**: Web Application Firewall attached to ALB.
  - **Security Groups**: Strict ingress/egress rules.
  - **S3 + CloudFront**: For static content, with Origin Access Control (OAC) to restrict direct S3 access.
  - **VPC Endpoints**: For secure S3 access from private subnets.
- **Storage**:
  - **RDS**: Multi-AZ PostgreSQL database.
  - **ElastiCache**: Redis cluster for caching.
  - **S3**: Encrypted bucket for static assets.

## CI/CD

This repository includes a GitHub Actions workflow `.github/workflows/terraform-ci.yml` that runs on push to `main`, `stage`, and `test` branches.

### Workflow Steps:
1. **Checkout Code**
2. **Setup Terraform**
3. **Configure AWS Credentials** (using GitHub Secrets)
4. **Terraform Init**
5. **Terraform Format Check** (`terraform fmt -check`)
6. **Terraform Validate**
7. **Terraform Plan** (No apply)

## Setup

1. **Install Terraform**: [Download Terraform](https://developer.hashicorp.com/terraform/downloads)
2. **Configure AWS Credentials**:
   - Create an IAM User with appropriate permissions.
   - Set `AWS_ACCESS_KEY_ID` and `AWS_SECRET_ACCESS_KEY` environment variables or use `aws configure`.
3. **Initialize Terraform**:
   ```bash
   terraform init
   ```
4. **Plan Infrastructure**:
   ```bash
   terraform plan
   ```
5. **Apply Infrastructure** (Manual step):
   ```bash
   terraform apply
   ```

## GitHub Secrets

For CI/CD to work, add the following secrets to your GitHub repository:
- `AWS_ACCESS_KEY_ID`
- `AWS_SECRET_ACCESS_KEY`
- `DB_PASSWORD` (Database password)

## Inputs

| Name | Description | Default |
|------|-------------|---------|
| `aws_region` | AWS Region | `us-east-1` |
| `project_name` | Project Name | `fastapi-app` |
| `environment` | Environment (dev, stage, prod) | `dev` |
| `db_password` | Database Master Password | **Required** |

## Outputs

After applying, Terraform will output:
- `alb_dns_name`: Load Balancer DNS
- `cloudfront_domain_name`: CloudFront Domain
- `rds_endpoint`: Database Endpoint
- `redis_endpoint`: Redis Endpoint
