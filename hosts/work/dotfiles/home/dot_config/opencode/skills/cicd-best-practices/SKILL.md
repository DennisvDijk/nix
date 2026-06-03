---
name: cicd-best-practices
description: CI/CD pipeline best practices for GitHub Actions, GitLab CI, Jenkins, and infrastructure automation. Use when building deployment pipelines, automating tests, or implementing GitOps workflows.
---

## What I do
- Guide CI/CD pipeline design and implementation
- Review GitHub Actions, GitLab CI, and Jenkins pipelines
- Implement secure deployment strategies
- Design GitOps workflows
- Optimize pipeline performance and costs

## When to use me
Use this skill when:
- Creating or reviewing CI/CD pipelines
- Implementing automated testing
- Setting up deployment automation
- Designing release strategies
- Implementing GitOps workflows
- Troubleshooting pipeline failures

## Pipeline Design Principles

### Core Principles
1. **Fast Feedback**: Fail fast, run quick checks first
2. **Reproducibility**: Same inputs = same outputs
3. **Isolation**: Each job runs in a clean environment
4. **Security**: Least privilege, secret management
5. **Observability**: Logs, metrics, notifications

### Pipeline Stages
```
┌─────────┐   ┌──────────┐   ┌─────────┐   ┌────────┐   ┌────────┐
│  Lint   │──▶│  Build   │──▶│  Test   │──▶│ Deploy │──▶│ Verify │
│ (30s)   │   │  (2min)  │   │ (5min)  │   │ (2min) │   │ (1min) │
└─────────┘   └──────────┘   └─────────┘   └────────┘   └────────┘
```

## GitHub Actions Best Practices

### Workflow Structure
```yaml
name: CI/CD Pipeline

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

concurrency:
  group: ${{ github.workflow }}-${{ github.ref }}
  cancel-in-progress: true

permissions:
  contents: read
  packages: write
  id-token: write  # For OIDC

jobs:
  lint:
    runs-on: ubuntu-latest
    timeout-minutes: 10
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: "3.12"
          cache: pip
      - run: pip install ruff mypy
      - run: ruff check .
      - run: mypy src/

  test:
    needs: lint
    runs-on: ubuntu-latest
    timeout-minutes: 30
    strategy:
      fail-fast: false
      matrix:
        python-version: ["3.11", "3.12"]
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-python@v5
        with:
          python-version: ${{ matrix.python-version }}
          cache: pip
      - run: pip install -e ".[test]"
      - run: pytest --cov --cov-report=xml
      - uses: codecov/codecov-action@v4
        with:
          token: ${{ secrets.CODECOV_TOKEN }}

  build:
    needs: test
    runs-on: ubuntu-latest
    outputs:
      image-digest: ${{ steps.build.outputs.digest }}
    steps:
      - uses: actions/checkout@v4
      - uses: docker/setup-buildx-action@v3
      - uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}
      - id: build
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: ghcr.io/${{ github.repository }}:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max

  deploy-staging:
    if: github.ref == 'refs/heads/main'
    needs: build
    runs-on: ubuntu-latest
    environment: staging
    steps:
      - uses: actions/checkout@v4
      - uses: aws-actions/configure-aws-credentials@v4
        with:
          role-to-assume: ${{ secrets.AWS_ROLE_ARN }}
          aws-region: eu-west-1
      - run: |
          aws ecs update-service \
            --cluster staging \
            --service app \
            --force-new-deployment
```

### Secret Management
```yaml
# Use GitHub OIDC for cloud providers instead of long-lived credentials
- uses: aws-actions/configure-aws-credentials@v4
  with:
    role-to-assume: arn:aws:iam::123456789:role/GitHubActionsRole
    aws-region: eu-west-1
    # No access keys needed!
```

### Caching Strategies
```yaml
# Cache dependencies
- uses: actions/cache@v4
  with:
    path: |
      ~/.cache/pip
      ~/.npm
      node_modules
    key: ${{ runner.os }}-deps-${{ hashFiles('**/requirements.txt', '**/package-lock.json') }}
    restore-keys: |
      ${{ runner.os }}-deps-

# Docker layer caching
- uses: docker/build-push-action@v5
  with:
    cache-from: type=gha
    cache-to: type=gha,mode=max
```

## GitLab CI Best Practices

```yaml
stages:
  - lint
  - test
  - build
  - deploy

variables:
  DOCKER_TLS_CERTDIR: "/certs"

default:
  image: python:3.12-slim
  cache:
    paths:
      - .cache/pip
  before_script:
    - pip install --cache-dir .cache/pip -r requirements.txt

lint:
  stage: lint
  script:
    - ruff check .
    - mypy src/
  rules:
    - if: $CI_PIPELINE_SOURCE == "merge_request_event"
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

test:
  stage: test
  script:
    - pytest --cov --junitxml=report.xml
  coverage: '/TOTAL.*\s+(\d+%)/'
  artifacts:
    reports:
      junit: report.xml
      coverage_report:
        coverage_format: cobertura
        path: coverage.xml

build:
  stage: build
  image: docker:24
  services:
    - docker:24-dind
  script:
    - docker build -t $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA .
    - docker push $CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH

deploy:staging:
  stage: deploy
  environment:
    name: staging
    url: https://staging.example.com
  script:
    - kubectl set image deployment/app app=$CI_REGISTRY_IMAGE:$CI_COMMIT_SHA
  rules:
    - if: $CI_COMMIT_BRANCH == $CI_DEFAULT_BRANCH
```

## Deployment Strategies

### Blue-Green Deployment
```yaml
deploy:
  script:
    - kubectl apply -f k8s/deployment-green.yaml
    - kubectl wait --for=condition=available deployment/app-green
    - kubectl patch service app -p '{"spec":{"selector":{"version":"green"}}}'
    - kubectl delete deployment app-blue || true
```

### Canary Deployment
```yaml
deploy-canary:
  script:
    - kubectl apply -f k8s/canary-deployment.yaml
    - kubectl scale deployment/app-canary --replicas=1
    - sleep 300  # Monitor metrics
    - |
      if check_error_rate; then
        kubectl scale deployment/app-canary --replicas=0
        exit 1
      fi
    - kubectl scale deployment/app-canary --replicas=5
```

### Rolling Update
```yaml
# Kubernetes deployment with rolling update
spec:
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 25%
      maxUnavailable: 0
```

## GitOps with ArgoCD

```yaml
# Application manifest
apiVersion: argoproj.io/v1alpha1
kind: Application
metadata:
  name: my-app
  namespace: argocd
spec:
  project: default
  source:
    repoURL: https://github.com/org/infra.git
    targetRevision: HEAD
    path: apps/my-app
  destination:
    server: https://kubernetes.default.svc
    namespace: production
  syncPolicy:
    automated:
      prune: true
      selfHeal: true
    syncOptions:
      - CreateNamespace=true
```

## Pipeline Security

### Security Scanning
```yaml
security-scan:
  stage: test
  parallel:
    matrix:
      - SCANNER: [trivy, snyk, semgrep]
  script:
    - case $SCANNER in
        trivy) trivy fs --severity HIGH,CRITICAL . ;;
        snyk) snyk test ;;
        semgrep) semgrep --config auto . ;;
      esac
```

### Signed Commits and Images
```yaml
- name: Sign container image
  uses: sigstore/cosign-installer@v3
- run: cosign sign ghcr.io/${{ github.repository }}@${{ steps.build.outputs.digest }}
```

## Pipeline Checklist

- [ ] Fast feedback (lint/format runs first)
- [ ] Proper caching configured
- [ ] Timeouts set on all jobs
- [ ] Concurrency controls to prevent duplicate runs
- [ ] Secrets use OIDC or short-lived credentials
- [ ] Security scanning integrated
- [ ] Proper environment protections
- [ ] Deployment rollback capability
- [ ] Notifications for failures
- [ ] Artifact retention policies set
