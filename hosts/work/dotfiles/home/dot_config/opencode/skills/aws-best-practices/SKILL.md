---
name: aws-best-practices
description: Amazon Web Services best practices including IAM, EC2, S3, Lambda, VPC, CloudFormation, and security. Use when designing, deploying, or managing AWS infrastructure.
---

## What I do
- Guide AWS architecture decisions
- Enforce security best practices
- Optimize costs and performance
- Review CloudFormation/Terraform
- Troubleshoot AWS deployments

## When to use me
Use this skill when:
- Designing AWS architectures
- Writing CloudFormation templates
- Configuring AWS resources
- Reviewing IAM policies
- Optimizing costs

## Core Principles

### IAM Best Practices
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "s3:GetObject",
        "s3:PutObject"
      ],
      "Resource": "arn:aws:s3:::my-bucket/*",
      "Condition": {
        "StringEquals": {
          "aws:RequestedRegion": "eu-west-1"
        }
      }
    }
  ]
}
```

### Security
- Use IAM roles, not access keys
- Enable CloudTrail
- Use AWS Config
- Implement VPC Flow Logs
- Enable GuardDuty
- Use Secrets Manager

### Networking
- Design VPCs with proper subnets
- Use NAT Gateways
- Implement Security Groups
- Use Network ACLs
- Configure VPC Endpoints
- Implement Transit Gateway

### S3 Best Practices
```yaml
BucketPolicy:
  Type: AWS::S3::BucketPolicy
  Properties:
    Bucket: !Ref MyBucket
    PolicyDocument:
      Statement:
        - Sid: EnforceTLS
          Effect: Deny
          Principal: '*'
          Action: 's3:*'
          Resource: 
            - !Sub 'arn:aws:s3:::${MyBucket}'
            - !Sub 'arn:aws:s3:::${MyBucket}/*'
          Condition:
            Bool:
              'aws:SecureTransport': 'false'
```

### Cost Optimization
- Use Reserved Instances
- Implement Savings Plans
- Use Spot Instances
- Enable S3 Intelligent-Tiering
- Monitor with Cost Explorer
- Use AWS Budgets

## Common Patterns

### Multi-AZ Architecture
```yaml
Resources:
  WebServerGroup:
    Type: AWS::AutoScaling::AutoScalingGroup
    Properties:
      VPCZoneIdentifier:
        - !Ref PublicSubnet1
        - !Ref PublicSubnet2
      MinSize: 2
      MaxSize: 6
      DesiredCapacity: 2
      HealthCheckType: ELB
```

### Lambda Function
```yaml
MyLambda:
  Type: AWS::Lambda::Function
  Properties:
    Runtime: python3.11
    Handler: index.handler
    Role: !GetAtt LambdaExecutionRole.Arn
    Timeout: 30
    MemorySize: 256
    Environment:
      Variables:
        LOG_LEVEL: INFO
```

### RDS Instance
```yaml
MyDB:
  Type: AWS::RDS::DBInstance
  Properties:
    DBInstanceIdentifier: my-database
    DBInstanceClass: db.t3.micro
    Engine: postgres
    MultiAZ: true
    StorageEncrypted: true
    BackupRetentionPeriod: 7
    DeletionProtection: true
```

## Anti-patterns to Avoid
- Don't use root account for daily tasks
- Don't hardcode credentials
- Don't open security groups to 0.0.0.0/0
- Don't ignore encryption
- Don't use default VPC for production
- Don't skip backup strategies

## Tools
- AWS CLI
- CloudFormation
- Terraform
- AWS CDK
- SAM CLI
- AWS Console
