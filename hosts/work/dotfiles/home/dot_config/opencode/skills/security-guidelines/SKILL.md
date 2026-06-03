---
name: security-guidelines
description: OWASP security standards, secure coding practices, secrets management, and vulnerability prevention. Use when reviewing code for security issues, implementing authentication/authorization, or handling sensitive data.
---

## What I do
- Enforce OWASP Top 10 security guidelines
- Guide secure coding practices across languages
- Review authentication and authorization implementations
- Identify injection vulnerabilities (SQL, XSS, CSRF, etc.)
- Ensure proper secrets management
- Check for security misconfigurations

## When to use me
Use this skill when:
- Reviewing code for security vulnerabilities
- Implementing authentication/authorization
- Handling sensitive data or PII
- Working with user inputs
- Designing API security
- Managing secrets and credentials

## OWASP Top 10 (2021) Guidelines

### A01: Broken Access Control
- Implement least privilege principle
- Deny access by default
- Validate user ownership of resources
- Disable directory listing
- Log access control failures
- Rate limit API access

### A02: Cryptographic Failures
- Never store passwords in plaintext
- Use strong hashing (bcrypt, Argon2, scrypt)
- Use TLS 1.2+ for data in transit
- Use AES-256-GCM for data at rest
- Never roll your own crypto
- Rotate encryption keys regularly

### A03: Injection
- Use parameterized queries (prepared statements)
- Validate and sanitize all inputs
- Use ORM frameworks safely
- Escape special characters in outputs
- Implement Content Security Policy (CSP)

```python
# BAD - SQL Injection vulnerable
cursor.execute(f"SELECT * FROM users WHERE id = {user_id}")

# GOOD - Parameterized query
cursor.execute("SELECT * FROM users WHERE id = %s", (user_id,))
```

### A04: Insecure Design
- Implement threat modeling
- Use secure design patterns
- Establish secure development lifecycle
- Separate duties and responsibilities

### A05: Security Misconfiguration
- Remove default credentials
- Disable unnecessary features
- Implement proper error handling (no stack traces)
- Keep dependencies updated
- Use security headers

### A06: Vulnerable Components
- Track all dependencies
- Monitor for CVEs
- Keep components updated
- Remove unused dependencies

### A07: Authentication Failures
- Implement MFA where possible
- Use secure session management
- Implement account lockout
- Use secure password policies
- Protect against credential stuffing

### A08: Software and Data Integrity
- Verify digital signatures
- Use integrity checks for downloads
- Implement CI/CD pipeline security
- Use signed commits

### A09: Security Logging and Monitoring
- Log authentication events
- Log access control failures
- Log input validation failures
- Implement alerting for suspicious activity
- Never log sensitive data

### A10: Server-Side Request Forgery (SSRF)
- Validate and sanitize URLs
- Use allowlists for external requests
- Disable HTTP redirects
- Don't use raw user input in URLs

## Secrets Management

### Never Do This
```python
# NEVER hardcode secrets
API_KEY = "sk-1234567890abcdef"
DB_PASSWORD = "admin123"
```

### Always Do This
```python
import os
from functools import lru_cache

@lru_cache()
def get_secret(name: str) -> str:
    """Get secret from environment or secret manager."""
    value = os.environ.get(name)
    if not value:
        raise ValueError(f"Missing required secret: {name}")
    return value

API_KEY = get_secret("API_KEY")
```

### Secret Storage Options
- Environment variables (development)
- AWS Secrets Manager / Azure Key Vault / GCP Secret Manager
- HashiCorp Vault
- Kubernetes Secrets (encrypted at rest)

## Input Validation Patterns

```python
from pydantic import BaseModel, validator, constr
import re

class UserInput(BaseModel):
    username: constr(min_length=3, max_length=50, regex=r'^[a-zA-Z0-9_]+$')
    email: str
    
    @validator('email')
    def validate_email(cls, v):
        email_regex = r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$'
        if not re.match(email_regex, v):
            raise ValueError('Invalid email format')
        return v.lower()
```

## Security Headers

```python
# Flask example
@app.after_request
def add_security_headers(response):
    response.headers['X-Content-Type-Options'] = 'nosniff'
    response.headers['X-Frame-Options'] = 'DENY'
    response.headers['X-XSS-Protection'] = '1; mode=block'
    response.headers['Strict-Transport-Security'] = 'max-age=31536000; includeSubDomains'
    response.headers['Content-Security-Policy'] = "default-src 'self'"
    return response
```

## Code Review Checklist

- [ ] No hardcoded secrets or credentials
- [ ] All user inputs validated and sanitized
- [ ] Parameterized queries used for database access
- [ ] Proper authentication and authorization checks
- [ ] Sensitive data encrypted at rest and in transit
- [ ] Security headers configured
- [ ] Error messages don't leak sensitive information
- [ ] Logging doesn't include sensitive data
- [ ] Dependencies checked for known vulnerabilities
- [ ] Rate limiting implemented on sensitive endpoints
