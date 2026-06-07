---
name: incident-management
description: Incident response, runbooks, postmortems, and on-call best practices. Use when handling production incidents, creating runbooks, or improving reliability processes.
---

## What I do
- Guide incident response processes
- Help create and review runbooks
- Structure blameless postmortems
- Define on-call rotation best practices
- Implement incident communication

## When to use me
Use this skill when:
- Responding to production incidents
- Creating operational runbooks
- Writing postmortems
- Setting up on-call processes
- Improving incident response times

## Incident Severity Levels

| Severity | Impact | Response | Example |
|----------|--------|----------|---------|
| SEV1 | Complete outage | All hands | Service down, data loss |
| SEV2 | Major degradation | On-call + backup | 50% error rate |
| SEV3 | Minor degradation | On-call | Slow responses |
| SEV4 | Low impact | Next business day | Single customer issue |

## Incident Response Process

### 1. Detection
```
┌─────────────┐     ┌──────────────┐     ┌─────────────┐
│  Monitoring │────▶│    Alert     │────▶│  On-Call    │
│   System    │     │   Fires      │     │   Paged     │
└─────────────┘     └──────────────┘     └─────────────┘
```

### 2. Triage (First 5 Minutes)
- [ ] Acknowledge the alert
- [ ] Verify the issue is real (not false positive)
- [ ] Assess severity and impact
- [ ] Start incident channel/war room
- [ ] Page additional help if needed

### 3. Investigation
```python
# Structured investigation checklist
investigation_steps = [
    "Check recent deployments",
    "Review error logs",
    "Check dependent services",
    "Review infrastructure metrics",
    "Check for external factors",
]
```

### 4. Mitigation
- Prioritize mitigation over root cause
- Consider quick wins: rollback, restart, scale up
- Document actions taken

### 5. Resolution & Communication
- Confirm service is restored
- Update status page
- Notify stakeholders
- Schedule postmortem

## Runbook Template

```markdown
# Runbook: High Error Rate on API Service

## Overview
This runbook addresses elevated error rates (>1%) on the API service.

## Prerequisites
- Access to Kubernetes cluster
- Datadog/Grafana dashboard access
- PagerDuty access for escalation

## Symptoms
- Alert: `APIErrorRateHigh`
- Dashboard: [API Health Dashboard](https://grafana.example.com/d/api)
- Error rate exceeds 1% for 5+ minutes

## Investigation Steps

### 1. Check Recent Deployments
```bash
kubectl -n production rollout history deployment/api
```
If recent deployment, consider rollback:
```bash
kubectl -n production rollout undo deployment/api
```

### 2. Check Pod Health
```bash
kubectl -n production get pods -l app=api
kubectl -n production describe pod <pod-name>
kubectl -n production logs -l app=api --tail=100
```

### 3. Check Dependent Services
- Database: [DB Dashboard](https://grafana.example.com/d/db)
- Redis: [Cache Dashboard](https://grafana.example.com/d/redis)
- External APIs: Check partner status pages

### 4. Scale if Needed
```bash
kubectl -n production scale deployment/api --replicas=10
```

## Escalation
- If unresolved after 15 minutes: Page backend team lead
- If data integrity issue: Page database team
- If security incident: Follow security incident process

## Recovery Verification
- [ ] Error rate below 0.1%
- [ ] Latency P99 below 500ms
- [ ] No pending alerts
```

## Postmortem Template

```markdown
# Postmortem: API Service Outage - 2024-01-15

## Summary
On January 15, 2024, the API service experienced a complete outage 
lasting 47 minutes, affecting all customers.

## Impact
- **Duration**: 14:23 - 15:10 UTC (47 minutes)
- **Users affected**: ~10,000 (100%)
- **Revenue impact**: Estimated $15,000 in failed transactions
- **SLO impact**: Consumed 108% of monthly error budget

## Timeline (All times UTC)
| Time | Event |
|------|-------|
| 14:15 | Deploy v2.3.1 completed |
| 14:23 | First alerts fire for high error rate |
| 14:25 | On-call engineer acknowledges alert |
| 14:30 | Incident declared SEV1, war room started |
| 14:35 | Root cause identified as database migration issue |
| 14:45 | Decision made to rollback |
| 14:50 | Rollback initiated |
| 15:05 | Rollback completed |
| 15:10 | Service fully restored |

## Root Cause
The database migration in v2.3.1 added a new NOT NULL column without 
a default value. The migration succeeded in staging (with test data) 
but failed in production due to existing NULL values.

## Contributing Factors
1. Migration was not tested against production-like data
2. Database migration ran synchronously during deployment
3. No automatic rollback on migration failure

## What Went Well
- Alert fired within 2 minutes of issue starting
- Incident response was quick (25 minutes to rollback decision)
- Communication was clear in incident channel

## What Could Be Improved
- Migration testing should use production data copy
- Migrations should run asynchronously with verification
- Deployment should auto-rollback on health check failure

## Action Items
| Action | Owner | Due Date | Status |
|--------|-------|----------|--------|
| Add production data copy to staging | @db-team | 2024-01-22 | TODO |
| Implement async migrations | @backend | 2024-01-29 | TODO |
| Add auto-rollback to deployment | @platform | 2024-02-05 | TODO |
| Add migration dry-run step | @db-team | 2024-01-22 | TODO |

## Lessons Learned
1. Test migrations with realistic data volumes
2. Never run synchronous migrations during deploy
3. Assume migrations will fail and plan for it
```

## On-Call Best Practices

### Rotation Design
```yaml
on_call_schedule:
  primary:
    rotation: weekly
    handoff: Monday 10:00 UTC
    members: [alice, bob, charlie, diana]
  
  secondary:
    rotation: weekly
    offset: 1 week  # Previous week's primary
    
  escalation:
    - level: 1
      target: primary
      timeout: 5m
    - level: 2
      target: secondary
      timeout: 10m
    - level: 3
      target: engineering_manager
      timeout: 15m
```

### On-Call Responsibilities
1. **Response Time**: Acknowledge alerts within 5 minutes
2. **Handoff**: Detailed handoff document for next on-call
3. **Documentation**: Update runbooks for any new issues
4. **Improvement**: File tickets for recurring issues

### On-Call Health
- Maximum consecutive on-call hours: 12
- Compensatory time off after incidents
- Regular review of alert volume and quality
- Shadow rotation for new team members

## Incident Communication

### Status Page Updates
```markdown
# [Investigating] API Service Degradation
Posted: 14:30 UTC

We are investigating reports of elevated error rates on our API.
Some requests may fail or experience delays.

Next update in 15 minutes or when we have more information.
```

### Internal Communication
```
🚨 INCIDENT: SEV1 - API Outage
War Room: #incident-2024-01-15
Incident Commander: @alice
Status: Investigating
Impact: All API requests failing
Last Update: Identified as database migration issue, planning rollback
```

## Incident Metrics

Track these metrics to improve over time:
- **MTTD** (Mean Time to Detect): Time from issue start to alert
- **MTTA** (Mean Time to Acknowledge): Time from alert to acknowledgment
- **MTTR** (Mean Time to Resolve): Time from issue start to resolution
- **Incident frequency** by severity
- **Postmortem action completion rate**
