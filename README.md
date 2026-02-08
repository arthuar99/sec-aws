# Secure AWS Infrastructure with Terraform

![Terraform CI](https://github.com/arthuar99/sec-aws/actions/workflows/terraform-ci.yml/badge.svg)

This project provisions a secure, high-availability AWS infrastructure for a FastAPI application using Terraform.

## Architecture

![Architecture](https://github.com/arthuar99/sec-aws/blob/main/diagram.png?raw=true) <!-- Add architecture diagram link if available -->

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

## Traffic Flow Details

### Routing Layer (Route 53) 🌐

The user requests your Domain Name (e.g., www.mazen-cloud.com).

Route 53 directs the request based on the type:

- **Website/Static content request (Frontend)** ➔ Goes to CloudFront.
- **Data/API request (Backend)** ➔ Goes to the ALB.

### Edge Layer (Security & CDN) 🛡️

- **CloudFront**: Delivers static content (images, files) to the user at high speed via edge locations.
- **S3 Bucket**: The origin storage for files. It is completely locked down (Private) and allows access only to CloudFront via OAC (Origin Access Control).
- **WAF & Shield**: A firewall that filters malicious attacks (like SQLi, XSS) and DDoS attempts before they reach your servers.

### Application Layer (Compute) ⚙️

- **ALB (Public Subnet)**: Receives API requests and distributes the load.
- **EC2 Instances (Private Subnet)**: These run your FastAPI application. They are isolated and cannot be accessed directly from the internet.
- **Auto Scaling**: Automatically increases or decreases the number of instances based on traffic load.

### Data Layer (Storage & Caching) 💾

- **ElastiCache (Redis)**: Ultra-fast temporary memory (caching) to reduce the load on the main database.
- **RDS (Database)**: The primary database located in a strictly isolated network (Private DB Subnet).

### Private Channels (Management & Cost Optimization) 🔐

- **VPC Endpoints**: Allow your EC2 servers to talk to S3 and Systems Manager without leaving the AWS network (Higher security & saves NAT Gateway costs).
- **Systems Manager (SSM)**: Allows you (the engineer) to access and manage servers securely without opening Port 22 (SSH).

## Changelog

### v1.2.0 (Latest - London Region)
- **Region Migration**: Switched infrastructure from `us-east-1` to `eu-west-2` (London).
- **Secure Management**: Added Session Manager (SSM) support with VPC Endpoints for secure, keyless server access.
- **DNS**: Integrated Route 53 for domain management.
- **IAM**: Added strict IAM roles for EC2 instances.

### v1.0.0 (Stable)
- **High Availability Infrastructure**: Complete VPC with public/private subnets, Multi-AZ RDS, and Auto Scaling Group.
- **Security**: Strict Security Groups, WAF protection for ALB, and S3 Origin Access Control.
- **CI/CD Pipeline**: Automated GitHub Actions workflow for Terraform Plan/Validate on `main`, `stage`, and `test` branches.
- **Monitoring**: Added `enable_monitoring` variable to control resource monitoring.
- **Outputs**: Expoed `environment_name` to track deployments.
