# terraform-vpc-github-actions
Create VPC using Terraform with GItHub-Actions as CICD


# terraform-vpc-github-actions

Create a complete AWS VPC infrastructure using Terraform, with deployment and CI/CD managed by GitHub Actions.

## Overview

This project automates the creation of a secure, production-ready AWS environment using Terraform modules and GitHub Actions for continuous integration and deployment. The infrastructure includes:

- **VPC with public subnets**
- **Internet Gateway and Route Tables**
- **Security Groups for HTTP and SSH (IPv4/IPv6 ready)**
- **EC2 Instances with custom user-data (serving a modern HTML status page)**
- **Application Load Balancer (ALB) with Target Groups and Listener**

All resources are provisioned through modular Terraform code located in `Terraform-VPC/modules/`, making the setup easy to customize and extend.

## Directory Structure

```
Terraform-VPC/
├── main.tf               # Root Terraform configuration
├── provider.tf           # AWS provider and backend config
├── modules/
│   ├── vpc/              # VPC, subnets, IGW, route tables
│   ├── sg/               # Security Groups
│   ├── ec2/              # EC2 instances (with HTML status page)
│   └── alb/              # Application Load Balancer
```

## Features

- **Modular Design**: Each AWS service is encapsulated as a module for easy maintenance and reuse.
- **CI/CD with GitHub Actions**: Automate Terraform plan/apply using real workflows.
- **Custom EC2 Bootstrap**: EC2 instances start an Apache server and show instance metadata in a styled HTML dashboard.
- **Production-ready Best Practices**: Security groups, public/private subnet separation, tagging, and outputs for integration.

## How It Works

1. **VPC Module**: Creates a VPC and multiple subnets, attaches an Internet Gateway, and configures route tables.
2. **Security Group Module**: Allows inbound HTTP and SSH traffic, easily extendable for other protocols.
3. **EC2 Module**: Provisions EC2 instances in the subnets, with each instance serving a custom HTML status page.
4. **ALB Module**: Deploys an Application Load Balancer, creates listener and target group, and attaches EC2 instances.

## Prerequisites

- Terraform v1.0+
- AWS Account and credentials (with S3 backend bucket for state)
- GitHub repository secrets for AWS keys (for CI/CD)

## Usage

### 1. Clone the repo
```sh
git clone https://github.com/kalpitmalviya/terraform-vpc-github-actions.git
cd terraform-vpc-github-actions/Terraform-VPC
```

### 2. Configure variables
Edit the variable files in each module to match your desired CIDR ranges, subnet names, etc.

### 3. Initialize and Apply (locally)
```sh
terraform init
terraform plan
terraform apply
```
> Or let GitHub Actions manage deployments for you.

### 4. Inspect Outputs
Terraform will print IDs for VPC, subnets, EC2 instances, and more.

## GitHub Actions CI/CD

The repository includes workflow files for automated `terraform plan` and `terraform apply` runs on push/PR. Ensure you add your AWS credentials as GitHub secrets.

## Customization

- **Add more EC2 instances**: Change the `ec2_names` variable in `modules/ec2/variables.tf`.
- **Modify security rules**: Edit `modules/sg/main.tf`.
- **Change subnet count or ranges**: Update `modules/vpc/variables.tf`.
- **Extend ALB config**: Add SSL, stickiness, etc., in `modules/alb/main.tf`.

## Outputs

- VPC ID
- Subnet IDs (list)
- EC2 instance IDs
- ALB DNS name

## License

MIT

---

*Made with Terraform & GitHub Actions by [kalpitmalviya](https://github.com/kalpitmalviya)*
