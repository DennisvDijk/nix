---
name: terraform-guidelines
description: Infrastructure-as-Code best practices for Terraform including module design, state management, security hardening, and multi-environment strategies. Use when writing, reviewing, or refactoring Terraform configurations.
---

## What I do
- Enforce Terraform best practices and coding standards
- Guide module composition and reusability
- Review security configurations
- Suggest state management strategies
- Recommend provider version constraints

## When to use me
Use this skill when:
- Writing new Terraform configurations
- Refactoring existing infrastructure code
- Code reviewing .tf files
- Setting up Terraform projects
- Troubleshooting state issues

## Core Principles

### Code Organization
- Use consistent file naming: `main.tf`, `variables.tf`, `outputs.tf`, `versions.tf`
- Group related resources in separate files
- Use `locals.tf` for complex local values
- Keep modules focused and reusable
- Use meaningful resource names (avoid a, b, c)

### Module Design
- Create reusable modules for common patterns
- Version modules explicitly (git tags or registry)
- Document all variables in README.md
- Use sensible defaults
- Output all relevant resource attributes

### State Management
- Use remote state (S3, GCS, Azure Blob)
- Enable state locking (DynamoDB, etc.)
- Never commit .tfstate files to git
- Use workspaces or separate state paths for environments
- Regular state backups

### Security Best Practices
- Never hardcode secrets (use variables)
- Use data sources for AMI IDs, etc.
- Enable encryption at rest and in transit
- Apply principle of least privilege
- Regular provider updates for security patches

### Variables and Outputs
```hcl
# variables.tf
variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
  
  validation {
    condition     = var.instance_count > 0
    error_message = "Instance count must be positive."
  }
}

# outputs.tf
output "instance_ips" {
  description = "IP addresses of created instances"
  value       = aws_instance.main[*].public_ip
  sensitive   = false
}
```

### Version Constraints
```hcl
# versions.tf
terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}
```

## Environment Strategy
- Use separate directories or workspaces per environment
- Share modules across environments
- Use tfvars files for environment-specific values
- Consider terragrunt for complex setups

## Common Patterns

### Conditional Resources
```hcl
count = var.enabled ? 1 : 0
```

### Dynamic Blocks
```hcl
dynamic "ingress" {
  for_each = var.allowed_ports
  content {
    from_port   = ingress.value
    to_port     = ingress.value
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
```

## Anti-patterns to Avoid
- Don't use `terraform apply -auto-approve` in production
- Avoid complex nested conditionals
- Don't ignore provider deprecation warnings
- Avoid manual state edits
- Don't reference resources by index when possible
