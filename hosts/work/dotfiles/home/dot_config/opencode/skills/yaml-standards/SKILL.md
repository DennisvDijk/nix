---
name: yaml-standards
description: YAML best practices for configuration files, Kubernetes manifests, GitHub Actions, and infrastructure definitions. Use when writing, reviewing, or validating YAML files to ensure proper syntax, structure, and maintainability.
---

## What I do
- Validate YAML syntax and structure
- Enforce indentation and formatting standards
- Guide proper use of anchors and aliases
- Review schema compliance (Kubernetes, GitHub Actions, etc.)
- Suggest readability improvements

## When to use me
Use this skill when:
- Writing YAML configuration files
- Reviewing Kubernetes manifests
- Creating GitHub Actions workflows
- Editing Helm charts
- Validating Docker Compose files

## Core Principles

### Syntax and Formatting
- Use 2 spaces for indentation (never tabs)
- Use consistent line endings (LF)
- Quote strings containing special characters
- Use `|` for multi-line strings (preserves newlines)
- Use `>` for folded multi-line strings

### Document Structure
```yaml
# Good: Clear structure with comments
apiVersion: v1
kind: ConfigMap
metadata:
  name: my-config
  namespace: default
data:
  # Configuration values
  database_host: "postgres"
  database_port: "5432"
```

### Anchors and Aliases
Use for DRY (Don't Repeat Yourself):
```yaml
# Define anchor
common_labels: &common_labels
  app: myapp
  version: v1.0

# Reference anchor
metadata:
  labels:
    <<: *common_labels
    component: frontend
```

### Kubernetes Specific
- Always specify resource requests and limits
- Use labels consistently for selectors
- Define health checks (liveness/readiness probes)
- Use ConfigMaps for configuration, Secrets for sensitive data
- Follow security contexts (runAsNonRoot, readOnlyRootFilesystem)

### GitHub Actions
- Pin action versions to SHA (security)
- Use `workflow_dispatch` for manual triggers
- Define job dependencies clearly
- Use environments for secrets management
- Cache dependencies when possible

### Docker Compose
- Use environment variables for configuration
- Define health checks
- Use named volumes for data persistence
- Set resource limits in production
- Use profiles for optional services

## Validation
- Use `yamllint` for syntax checking
- Use schema validators (kubeval, actionlint)
- Validate with dry-run when possible

## Anti-patterns to Avoid
- Don't mix tabs and spaces
- Avoid deeply nested structures (>4 levels)
- Don't use YAML 1.1 specific features unnecessarily
- Avoid duplicate keys
- Don't commit secrets in plain YAML
