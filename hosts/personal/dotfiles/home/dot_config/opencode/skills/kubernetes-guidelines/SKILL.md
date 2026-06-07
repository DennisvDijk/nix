---
name: kubernetes-guidelines
description: Kubernetes best practices for manifests, deployments, security, networking, and cluster management. Use when writing, reviewing, or troubleshooting Kubernetes YAML configurations, Helm charts, and kubectl commands.
---

## What I do
- Enforce Kubernetes best practices and security
- Guide proper resource configuration
- Review deployment strategies
- Optimize resource usage
- Troubleshoot common issues

## When to use me
Use this skill when:
- Writing Kubernetes manifests
- Creating Helm charts
- Reviewing K8s configurations
- Troubleshooting pod issues
- Designing cluster architecture

## Core Principles

### Resource Configuration
- Always set resource requests and limits
- Use appropriate QoS classes
- Configure health checks (liveness/readiness)
- Set graceful shutdown periods
- Use ConfigMaps for configuration

### Security Best Practices
```yaml
# Security Context Example
apiVersion: v1
kind: Pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    fsGroup: 2000
    seccompProfile:
      type: RuntimeDefault
  containers:
  - name: app
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
```

### Deployment Strategies
- Use RollingUpdate for zero-downtime
- Configure maxSurge and maxUnavailable
- Implement PodDisruptionBudgets
- Use affinity/anti-affinity rules
- Configure HorizontalPodAutoscaler

### Networking
- Use Services for internal communication
- Configure NetworkPolicies
- Use Ingress for external access
- Implement service mesh when needed
- Configure DNS policies

### Storage
- Use PersistentVolumes for stateful apps
- Configure appropriate access modes
- Implement backup strategies
- Use volume snapshots
- Consider storage classes

## Common Patterns

### Health Checks
```yaml
livenessProbe:
  httpGet:
    path: /healthz
    port: 8080
  initialDelaySeconds: 30
  periodSeconds: 10

readinessProbe:
  httpGet:
    path: /ready
    port: 8080
  initialDelaySeconds: 5
  periodSeconds: 5
```

### Resource Limits
```yaml
resources:
  requests:
    memory: "128Mi"
    cpu: "100m"
  limits:
    memory: "256Mi"
    cpu: "200m"
```

### ConfigMap Usage
```yaml
env:
- name: DATABASE_URL
  valueFrom:
    configMapKeyRef:
      name: app-config
      key: database.url
```

## Anti-patterns to Avoid
- Don't run containers as root
- Don't use latest tag
- Don't expose sensitive data in env vars
- Don't ignore resource limits
- Don't use host networking
- Don't mount sensitive host paths
- Don't ignore security contexts

## Tools
- kubectl - Cluster management
- helm - Package management
- kustomize - Configuration management
- stern - Log aggregation
- kubectx/kubens - Context switching
