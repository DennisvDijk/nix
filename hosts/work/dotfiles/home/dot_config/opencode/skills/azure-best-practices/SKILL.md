---
name: azure-best-practices
description: Microsoft Azure cloud best practices including resource management, security, cost optimization, ARM templates, Bicep, and Azure CLI. Use when designing, deploying, or managing Azure infrastructure.
---

## What I do
- Guide Azure resource architecture
- Enforce security best practices
- Optimize costs and performance
- Review ARM/Bicep templates
- Troubleshoot Azure deployments

## When to use me
Use this skill when:
- Designing Azure architectures
- Writing ARM/Bicep templates
- Configuring Azure resources
- Reviewing security settings
- Optimizing costs

## Core Principles

### Resource Organization
- Use Management Groups for governance
- Organize with Resource Groups
- Apply consistent naming conventions
- Use tags for cost allocation
- Implement resource locks

### Security
```bicep
// Key Vault with RBAC
resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enableRbacAuthorization: true
    enablePurgeProtection: true
  }
}
```

### Network Security
- Use NSGs and ASGs
- Implement Azure Firewall
- Configure Private Endpoints
- Use Service Endpoints
- Implement DDoS protection

### Identity and Access
- Use Managed Identities
- Implement RBAC
- Apply least privilege
- Use Conditional Access
- Enable MFA

### Cost Optimization
- Use Reserved Instances
- Implement auto-shutdown
- Right-size resources
- Use Spot VMs where appropriate
- Monitor with Cost Management

## Common Patterns

### Resource Naming
```
rg-{app}-{env}-{region}-{instance}
vm-{app}-{env}-{number}
sql-{app}-{env}-{region}
```

### ARM Template Structure
```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "environmentName": {
      "type": "string",
      "allowedValues": ["dev", "staging", "prod"]
    }
  },
  "variables": {
    "namingPrefix": "[concat(parameters('projectName'), '-', parameters('environmentName'))]"
  },
  "resources": [],
  "outputs": {}
}
```

### Bicep Module
```bicep
param location string = resourceGroup().location
param environment string

module storage 'modules/storage.bicep' = {
  name: 'storageDeployment'
  params: {
    location: location
    environment: environment
  }
}
```

## Anti-patterns to Avoid
- Don't hardcode secrets in templates
- Don't use classic deployment model
- Don't ignore resource limits
- Don't expose services publicly without NSGs
- Don't use Owner/Contributor for apps
- Don't ignore backup strategies

## Tools
- Azure CLI
- Bicep CLI
- ARM Templates
- Azure PowerShell
- Azure Portal
- Azure Cost Management
