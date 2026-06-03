---
name: docker-security
description: Container security best practices for Docker, Kubernetes pod security, and image hardening. Use when building Dockerfiles, reviewing container configurations, or implementing runtime security.
---

## What I do
- Guide secure Dockerfile writing
- Review container image security
- Implement Kubernetes pod security
- Guide image vulnerability scanning
- Recommend runtime security practices

## When to use me
Use this skill when:
- Writing or reviewing Dockerfiles
- Building container images
- Configuring Kubernetes pod security
- Implementing image scanning
- Hardening container runtime

## Secure Dockerfile Patterns

### Multi-Stage Build with Non-Root User
```dockerfile
# Build stage
FROM python:3.12-slim AS builder

WORKDIR /app

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir --user -r requirements.txt

COPY src/ ./src/

# Runtime stage
FROM python:3.12-slim AS runtime

# Create non-root user
RUN groupadd --gid 1000 appuser && \
    useradd --uid 1000 --gid 1000 --shell /bin/bash --create-home appuser

WORKDIR /app

# Copy only necessary files from builder
COPY --from=builder --chown=appuser:appuser /root/.local /home/appuser/.local
COPY --from=builder --chown=appuser:appuser /app/src ./src

# Set environment
ENV PATH=/home/appuser/.local/bin:$PATH \
    PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

# Switch to non-root user
USER appuser

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:8000/health')"

EXPOSE 8000

ENTRYPOINT ["python", "-m", "src.main"]
```

### Distroless Images (Most Secure)
```dockerfile
FROM golang:1.22 AS builder

WORKDIR /app
COPY . .
RUN CGO_ENABLED=0 GOOS=linux go build -o /app/server

# Distroless has no shell, no package manager - minimal attack surface
FROM gcr.io/distroless/static-debian12

COPY --from=builder /app/server /server

USER nonroot:nonroot

ENTRYPOINT ["/server"]
```

## Dockerfile Security Checklist

### DO
- [ ] Use specific base image tags (not `latest`)
- [ ] Use multi-stage builds
- [ ] Run as non-root user
- [ ] Use `COPY` instead of `ADD`
- [ ] Clean up apt/apk caches
- [ ] Set `HEALTHCHECK`
- [ ] Use `.dockerignore`
- [ ] Pin dependency versions

### DON'T
```dockerfile
# BAD: Running as root
FROM python:latest
COPY . .
RUN pip install -r requirements.txt
CMD ["python", "app.py"]

# BAD: Hardcoded secrets
ENV API_KEY=sk-1234567890

# BAD: Installing unnecessary packages
RUN apt-get install -y vim curl wget

# BAD: Using ADD for local files (COPY is safer)
ADD . /app
```

## Image Vulnerability Scanning

### Trivy
```bash
# Scan image for vulnerabilities
trivy image --severity HIGH,CRITICAL myapp:latest

# Scan in CI/CD (fail on critical)
trivy image --exit-code 1 --severity CRITICAL myapp:latest

# Generate SBOM
trivy image --format cyclonedx --output sbom.json myapp:latest
```

### Scan Integration in CI
```yaml
# GitHub Actions
- name: Scan image
  uses: aquasecurity/trivy-action@master
  with:
    image-ref: ghcr.io/${{ github.repository }}:${{ github.sha }}
    format: 'sarif'
    output: 'trivy-results.sarif'
    severity: 'CRITICAL,HIGH'

- name: Upload scan results
  uses: github/codeql-action/upload-sarif@v2
  with:
    sarif_file: 'trivy-results.sarif'
```

## Kubernetes Pod Security

### Pod Security Standards (PSS)
```yaml
# Restricted (most secure)
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
    runAsGroup: 1000
    fsGroup: 1000
    seccompProfile:
      type: RuntimeDefault
  containers:
    - name: app
      image: myapp:v1.0.0
      securityContext:
        allowPrivilegeEscalation: false
        readOnlyRootFilesystem: true
        capabilities:
          drop:
            - ALL
      resources:
        limits:
          cpu: "500m"
          memory: "128Mi"
        requests:
          cpu: "100m"
          memory: "64Mi"
      volumeMounts:
        - name: tmp
          mountPath: /tmp
  volumes:
    - name: tmp
      emptyDir: {}
```

### Network Policies
```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-network-policy
  namespace: production
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
    - Ingress
    - Egress
  ingress:
    - from:
        - podSelector:
            matchLabels:
              app: ingress-nginx
      ports:
        - protocol: TCP
          port: 8000
  egress:
    - to:
        - podSelector:
            matchLabels:
              app: postgres
      ports:
        - protocol: TCP
          port: 5432
    - to:  # Allow DNS
        - namespaceSelector: {}
          podSelector:
            matchLabels:
              k8s-app: kube-dns
      ports:
        - protocol: UDP
          port: 53
```

### Pod Security Admission
```yaml
# Enforce restricted policy on namespace
apiVersion: v1
kind: Namespace
metadata:
  name: production
  labels:
    pod-security.kubernetes.io/enforce: restricted
    pod-security.kubernetes.io/enforce-version: latest
    pod-security.kubernetes.io/audit: restricted
    pod-security.kubernetes.io/warn: restricted
```

## Secret Management

### Kubernetes Secrets (Basic)
```yaml
apiVersion: v1
kind: Secret
metadata:
  name: api-secrets
type: Opaque
stringData:
  database-url: postgres://user:pass@db:5432/app
---
apiVersion: v1
kind: Pod
spec:
  containers:
    - name: app
      env:
        - name: DATABASE_URL
          valueFrom:
            secretKeyRef:
              name: api-secrets
              key: database-url
```

### External Secrets Operator (Better)
```yaml
apiVersion: external-secrets.io/v1beta1
kind: ExternalSecret
metadata:
  name: api-secrets
spec:
  refreshInterval: 1h
  secretStoreRef:
    name: aws-secrets-manager
    kind: SecretStore
  target:
    name: api-secrets
  data:
    - secretKey: database-url
      remoteRef:
        key: production/api/database
        property: url
```

## Runtime Security

### Falco Rules (Runtime Detection)
```yaml
- rule: Shell spawned in container
  desc: Detect shell spawned in container
  condition: >
    spawned_process and
    container and
    shell_procs and
    not user_known_shell_spawn_activities
  output: >
    Shell spawned in container 
    (user=%user.name container=%container.name 
     shell=%proc.name parent=%proc.pname)
  priority: WARNING
  tags: [container, shell]
```

## Container Security Checklist

- [ ] Images scanned for vulnerabilities
- [ ] No secrets in images or environment variables
- [ ] Running as non-root user
- [ ] Read-only root filesystem
- [ ] Capabilities dropped
- [ ] Resource limits set
- [ ] Network policies in place
- [ ] Pod security standards enforced
- [ ] Image pull policy set to `Always` or digest pinning
- [ ] Runtime security monitoring enabled
