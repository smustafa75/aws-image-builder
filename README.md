# AWS Image Builder - Golden AMI Creation Framework

This repository provides a comprehensive framework for automating the creation and distribution of Golden AMIs using AWS Image Builder. Organizations currently using Ansible, Terraform, or Packer for image creation can leverage this solution as a centralized platform for their automated Golden Image creation process.

## Architecture Overview

The framework consists of several key components:

- **Network Module**: Creates a dedicated VPC with public and private subnets, NAT Gateway, and necessary VPC endpoints for secure image building
- **Roles Module**: Establishes IAM roles, instance profiles, and S3 buckets for assets and logging
- **Image Builder Module**: Configures the image recipes, components, pipelines, and distribution settings

## Prerequisites

- AWS Account with appropriate permissions
- Terraform v0.14+ installed
- AWS CLI v2 configured
- S3 bucket for Terraform state (optional)

## Getting Started

1. Clone this repository
2. Configure your AWS credentials
3. Review and update the variables in the Terraform files
4. Initialize and apply the Terraform configuration

```bash
terraform init
terraform plan
terraform apply
```

## Key Features

- **Secure Network Architecture**: Isolated VPC with private subnets for image building
- **Automated Component Installation**: Pre-configured components for common tools and agents
- **Customizable Image Recipes**: Easily modify recipes to include your organization's required software
- **Flexible Distribution**: Configure AMI distribution across accounts and regions
- **Comprehensive Logging**: Built-in logging to S3 and CloudWatch

## Important Configuration Notes

- If not using the default VPC, you must provide subnet IDs and security groups for instance launching
- An S3 bucket for storing assets is created automatically to hold binaries, installers, and configuration files
- Create a local folder for your binaries and update the paths in the Terraform scripts to upload them to the assets S3 bucket
- Several configuration lines are commented out to allow for customization (search for `#` in the code)

## Components

The framework includes pre-configured components for:

- Windows Updates
- AWS CLI installation
- PowerShell modules
- CloudWatch Agent
- Kinesis Agent
- NewRelic Agent (customizable)
- Custom component support

## Customization

To customize the image building process:

1. Update the base AMI ID in `imgbldr/main.tf`
2. Modify component versions and configurations as needed
3. Add or remove components from the image recipe
4. Update the local paths for your installation files
5. Configure distribution settings for your target accounts

## Security Considerations

- All network traffic is controlled via security groups
- VPC endpoints are used for AWS service access
- Flow logs are enabled for network monitoring
- KMS encryption support is available (commented out by default)

## Maintenance and Updates

Regular maintenance tasks:

- Update base AMI references to the latest versions
- Keep component versions current with security patches
- Review and update IAM permissions as needed

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
