---
name: compliance-standards
description: SOC2, GDPR, HIPAA, and PCI-DSS compliance patterns for enterprise software. Use when handling personal data, designing audit trails, implementing data retention, or ensuring regulatory compliance.
---

## What I do
- Guide SOC2 Trust Service Criteria implementation
- Ensure GDPR data protection compliance
- Implement HIPAA safeguards for healthcare data
- Guide PCI-DSS requirements for payment data
- Design audit logging and data retention
- Implement privacy by design

## When to use me
Use this skill when:
- Handling personal identifiable information (PII)
- Processing health information (PHI)
- Handling payment card data
- Implementing audit logging
- Designing data retention policies
- Building consent management systems
- Preparing for compliance audits

## Data Classification

### Sensitivity Levels
| Level | Examples | Handling Requirements |
|-------|----------|----------------------|
| Public | Marketing content, public docs | No special handling |
| Internal | Internal memos, non-sensitive business data | Access control |
| Confidential | PII, business secrets, contracts | Encryption, access logs |
| Restricted | PHI, payment data, credentials | Encryption, MFA, audit logs |

### PII Categories
- **Direct Identifiers**: Name, SSN, email, phone, address
- **Indirect Identifiers**: Date of birth, zip code, gender
- **Sensitive PII**: Biometrics, health data, financial data

## SOC2 Trust Service Criteria

### Security (Common Criteria)
```python
# CC6.1 - Logical Access Controls
class AccessControl:
    def authenticate(self, credentials: Credentials) -> User:
        """Verify user identity with MFA."""
        user = self.verify_credentials(credentials)
        if user.requires_mfa:
            self.verify_mfa(user, credentials.mfa_token)
        self.log_authentication(user, success=True)
        return user
    
    def authorize(self, user: User, resource: Resource, action: Action) -> bool:
        """Check RBAC permissions."""
        allowed = self.rbac.check_permission(user.roles, resource, action)
        self.log_authorization(user, resource, action, allowed)
        return allowed
```

### Availability
- Implement health checks
- Design for failover
- Monitor uptime SLIs
- Document recovery procedures

### Processing Integrity
- Validate all inputs
- Implement checksums for data integrity
- Log all data transformations
- Implement idempotency

### Confidentiality
- Encrypt data at rest (AES-256)
- Encrypt data in transit (TLS 1.2+)
- Implement key rotation
- Use secure deletion

### Privacy
- Implement consent management
- Support data subject requests
- Minimize data collection
- Implement retention policies

## GDPR Requirements

### Lawful Basis for Processing
```python
from enum import Enum

class LawfulBasis(Enum):
    CONSENT = "consent"
    CONTRACT = "contract"
    LEGAL_OBLIGATION = "legal_obligation"
    VITAL_INTERESTS = "vital_interests"
    PUBLIC_TASK = "public_task"
    LEGITIMATE_INTERESTS = "legitimate_interests"

class DataProcessingRecord:
    def __init__(
        self,
        purpose: str,
        lawful_basis: LawfulBasis,
        data_categories: list[str],
        retention_period: timedelta,
        recipients: list[str],
    ):
        self.purpose = purpose
        self.lawful_basis = lawful_basis
        self.data_categories = data_categories
        self.retention_period = retention_period
        self.recipients = recipients
        self.created_at = datetime.utcnow()
```

### Data Subject Rights Implementation
```python
class DataSubjectRights:
    async def right_to_access(self, subject_id: str) -> PersonalData:
        """Article 15 - Return all personal data."""
        return await self.data_store.get_all_data(subject_id)
    
    async def right_to_erasure(self, subject_id: str) -> bool:
        """Article 17 - Delete all personal data."""
        await self.verify_erasure_allowed(subject_id)
        await self.data_store.delete_all(subject_id)
        await self.audit_log.record_erasure(subject_id)
        return True
    
    async def right_to_portability(self, subject_id: str) -> bytes:
        """Article 20 - Export data in machine-readable format."""
        data = await self.data_store.get_all_data(subject_id)
        return json.dumps(data.to_dict()).encode()
    
    async def right_to_rectification(
        self, subject_id: str, corrections: dict
    ) -> bool:
        """Article 16 - Correct inaccurate data."""
        await self.data_store.update(subject_id, corrections)
        await self.audit_log.record_rectification(subject_id, corrections)
        return True
```

### Consent Management
```python
class ConsentRecord:
    subject_id: str
    purpose: str
    granted_at: datetime
    expires_at: datetime | None
    withdrawn_at: datetime | None
    proof: str  # How consent was obtained
    
    def is_valid(self) -> bool:
        if self.withdrawn_at:
            return False
        if self.expires_at and datetime.utcnow() > self.expires_at:
            return False
        return True
```

## HIPAA Requirements

### PHI Safeguards
```python
class PHIHandler:
    """Handle Protected Health Information per HIPAA."""
    
    def __init__(self, encryption_key: bytes):
        self.cipher = AES256GCM(encryption_key)
        self.audit_logger = HIPAAAuditLogger()
    
    def store_phi(self, patient_id: str, data: dict) -> str:
        """Store PHI with encryption and audit logging."""
        encrypted = self.cipher.encrypt(json.dumps(data))
        record_id = self.database.store(encrypted)
        
        self.audit_logger.log(
            action="CREATE",
            patient_id=patient_id,
            record_id=record_id,
            user=current_user(),
            timestamp=datetime.utcnow(),
        )
        return record_id
    
    def access_phi(self, record_id: str, purpose: str) -> dict:
        """Access PHI with audit logging."""
        # Verify minimum necessary
        if not self.verify_access_need(current_user(), purpose):
            raise AccessDenied("Access not justified")
        
        encrypted = self.database.get(record_id)
        data = json.loads(self.cipher.decrypt(encrypted))
        
        self.audit_logger.log(
            action="READ",
            record_id=record_id,
            user=current_user(),
            purpose=purpose,
            timestamp=datetime.utcnow(),
        )
        return data
```

### HIPAA Audit Requirements
- Who accessed the data
- What data was accessed
- When it was accessed
- Why it was accessed (purpose)
- Retain logs for 6 years

## Audit Logging Pattern

```python
from datetime import datetime
from enum import Enum
import json

class AuditAction(Enum):
    CREATE = "create"
    READ = "read"
    UPDATE = "update"
    DELETE = "delete"
    EXPORT = "export"
    LOGIN = "login"
    LOGOUT = "logout"
    PERMISSION_CHANGE = "permission_change"

class AuditLog:
    def __init__(self):
        self.logger = get_secure_logger("audit")
    
    def log(
        self,
        action: AuditAction,
        resource_type: str,
        resource_id: str,
        actor_id: str,
        actor_ip: str,
        details: dict = None,
    ):
        entry = {
            "timestamp": datetime.utcnow().isoformat(),
            "action": action.value,
            "resource_type": resource_type,
            "resource_id": resource_id,
            "actor_id": actor_id,
            "actor_ip": actor_ip,
            "details": details or {},
        }
        # Write to immutable audit log
        self.logger.info(json.dumps(entry))
```

## Data Retention Policy

```python
class RetentionPolicy:
    POLICIES = {
        "user_activity_logs": timedelta(days=90),
        "audit_logs": timedelta(days=2190),  # 6 years for HIPAA
        "marketing_data": timedelta(days=365),
        "contract_data": timedelta(days=2555),  # 7 years
        "financial_records": timedelta(days=2555),
    }
    
    async def apply_retention(self):
        """Delete data past retention period."""
        for data_type, retention in self.POLICIES.items():
            cutoff = datetime.utcnow() - retention
            deleted = await self.data_store.delete_before(data_type, cutoff)
            await self.audit_log.log(
                action="RETENTION_DELETE",
                data_type=data_type,
                count=deleted,
                cutoff=cutoff,
            )
```

## Compliance Checklist

### SOC2
- [ ] Access control policies documented and implemented
- [ ] Change management process in place
- [ ] Incident response plan documented
- [ ] Vendor management process
- [ ] Employee background checks
- [ ] Security awareness training

### GDPR
- [ ] Data Processing Register maintained
- [ ] Privacy Policy published
- [ ] Consent mechanisms implemented
- [ ] Data Subject Rights endpoints
- [ ] Data Protection Impact Assessments
- [ ] Data Processing Agreements with vendors

### HIPAA
- [ ] PHI encrypted at rest and in transit
- [ ] Access controls with minimum necessary
- [ ] Audit logs for all PHI access
- [ ] Business Associate Agreements
- [ ] Employee HIPAA training
- [ ] Incident response plan for breaches
