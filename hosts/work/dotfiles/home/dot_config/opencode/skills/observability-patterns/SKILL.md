---
name: observability-patterns
description: Observability best practices including structured logging, metrics, distributed tracing, and alerting. Use when implementing monitoring, debugging production issues, or designing SLOs/SLIs.
---

## What I do
- Guide structured logging implementation
- Design metrics and dashboards
- Implement distributed tracing
- Define SLOs, SLIs, and error budgets
- Review alerting strategies

## When to use me
Use this skill when:
- Implementing application logging
- Adding metrics and instrumentation
- Setting up distributed tracing
- Defining SLOs and alerting rules
- Debugging production issues
- Designing monitoring dashboards

## Three Pillars of Observability

### 1. Logs (What happened)
### 2. Metrics (How much/how many)
### 3. Traces (Request flow)

## Structured Logging

### Python with structlog
```python
import structlog

# Configure once at startup
structlog.configure(
    processors=[
        structlog.contextvars.merge_contextvars,
        structlog.processors.add_log_level,
        structlog.processors.TimeStamper(fmt="iso"),
        structlog.processors.StackInfoRenderer(),
        structlog.processors.format_exc_info,
        structlog.processors.JSONRenderer()
    ],
    wrapper_class=structlog.make_filtering_bound_logger(logging.INFO),
    context_class=dict,
    logger_factory=structlog.PrintLoggerFactory(),
    cache_logger_on_first_use=True,
)

logger = structlog.get_logger()

# Usage
logger.info(
    "order_created",
    order_id=order.id,
    customer_id=customer.id,
    total_amount=order.total,
    items_count=len(order.items),
)
```

### Log Levels
| Level | Use Case |
|-------|----------|
| DEBUG | Development details, not in production |
| INFO | Business events, state changes |
| WARNING | Recoverable issues, degraded performance |
| ERROR | Operation failed, requires attention |
| CRITICAL | System failure, immediate action needed |

### What to Log
```python
# DO log:
logger.info("user_login", user_id=user.id, ip=request.remote_addr)
logger.info("payment_processed", order_id=order.id, amount=payment.amount)
logger.error("database_connection_failed", host=db_host, retry_count=3)

# DON'T log:
logger.info(f"Password: {password}")  # NEVER log secrets
logger.debug(f"Request body: {request.body}")  # May contain PII
```

### Request Context
```python
from contextvars import ContextVar
import uuid

request_id: ContextVar[str] = ContextVar('request_id')

@app.before_request
def set_request_context():
    req_id = request.headers.get('X-Request-ID', str(uuid.uuid4()))
    request_id.set(req_id)
    structlog.contextvars.bind_contextvars(
        request_id=req_id,
        user_id=getattr(g, 'user_id', None),
    )
```

## Metrics with Prometheus

### Four Golden Signals
1. **Latency** - Response time
2. **Traffic** - Requests per second
3. **Errors** - Error rate
4. **Saturation** - Resource utilization

### Python Implementation
```python
from prometheus_client import Counter, Histogram, Gauge

# Request metrics
REQUEST_COUNT = Counter(
    'http_requests_total',
    'Total HTTP requests',
    ['method', 'endpoint', 'status']
)

REQUEST_LATENCY = Histogram(
    'http_request_duration_seconds',
    'HTTP request latency',
    ['method', 'endpoint'],
    buckets=[.005, .01, .025, .05, .1, .25, .5, 1, 2.5, 5, 10]
)

# Business metrics
ORDERS_TOTAL = Counter(
    'orders_total',
    'Total orders created',
    ['payment_method', 'status']
)

QUEUE_SIZE = Gauge(
    'job_queue_size',
    'Current job queue size',
    ['queue_name']
)

# Usage
@app.route('/api/orders', methods=['POST'])
def create_order():
    with REQUEST_LATENCY.labels(method='POST', endpoint='/api/orders').time():
        try:
            order = process_order(request.json)
            ORDERS_TOTAL.labels(payment_method=order.payment_method, status='success').inc()
            REQUEST_COUNT.labels(method='POST', endpoint='/api/orders', status='200').inc()
            return jsonify(order), 201
        except Exception as e:
            REQUEST_COUNT.labels(method='POST', endpoint='/api/orders', status='500').inc()
            raise
```

## Distributed Tracing with OpenTelemetry

```python
from opentelemetry import trace
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.otlp.proto.grpc.trace_exporter import OTLPSpanExporter
from opentelemetry.instrumentation.flask import FlaskInstrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor
from opentelemetry.instrumentation.sqlalchemy import SQLAlchemyInstrumentor

# Setup
provider = TracerProvider()
processor = BatchSpanProcessor(OTLPSpanExporter(endpoint="http://otel-collector:4317"))
provider.add_span_processor(processor)
trace.set_tracer_provider(provider)

# Auto-instrument
FlaskInstrumentor().instrument_app(app)
RequestsInstrumentor().instrument()
SQLAlchemyInstrumentor().instrument(engine=db.engine)

# Manual spans
tracer = trace.get_tracer(__name__)

def process_payment(order):
    with tracer.start_as_current_span("process_payment") as span:
        span.set_attribute("order.id", order.id)
        span.set_attribute("order.amount", order.total)
        
        with tracer.start_as_current_span("validate_card"):
            validate_card(order.payment_method)
        
        with tracer.start_as_current_span("charge_card"):
            result = charge_card(order)
            span.set_attribute("payment.transaction_id", result.transaction_id)
        
        return result
```

## SLOs, SLIs, and Error Budgets

### Definitions
- **SLI** (Service Level Indicator): Metric that measures service quality
- **SLO** (Service Level Objective): Target value for an SLI
- **Error Budget**: Acceptable amount of failure (100% - SLO)

### Example SLOs
```yaml
slos:
  - name: api-availability
    description: "API should be available"
    sli:
      type: availability
      good_events: http_requests_total{status!~"5.."}
      total_events: http_requests_total
    target: 99.9%  # 43.8 minutes/month error budget
    
  - name: api-latency
    description: "API should respond quickly"
    sli:
      type: latency
      good_events: http_request_duration_seconds_bucket{le="0.5"}
      total_events: http_request_duration_seconds_count
    target: 99%  # 99% of requests under 500ms
```

### Error Budget Calculation
```python
def calculate_error_budget(slo_target: float, window_seconds: int) -> dict:
    """Calculate error budget for given SLO and time window."""
    error_budget_percent = 100 - (slo_target * 100)
    error_budget_seconds = window_seconds * (error_budget_percent / 100)
    
    return {
        "slo_target": f"{slo_target * 100}%",
        "error_budget_percent": f"{error_budget_percent}%",
        "error_budget_seconds": error_budget_seconds,
        "error_budget_minutes": error_budget_seconds / 60,
    }

# 30-day window
budget = calculate_error_budget(0.999, 30 * 24 * 60 * 60)
# {'slo_target': '99.9%', 'error_budget_minutes': 43.2}
```

## Alerting Best Practices

### Alert on Symptoms, Not Causes
```yaml
# BAD - alerting on cause
- alert: HighCPUUsage
  expr: cpu_usage > 90%
  
# GOOD - alerting on symptom
- alert: HighLatency
  expr: histogram_quantile(0.99, http_request_duration_seconds) > 1
  for: 5m
  labels:
    severity: warning
  annotations:
    summary: "High latency detected"
    description: "P99 latency is {{ $value }}s, threshold is 1s"
```

### Alert Severity Levels
| Severity | Action | Response Time | Example |
|----------|--------|---------------|---------|
| Critical | Page on-call | < 5 min | Service down |
| Warning | Slack alert | < 1 hour | Elevated error rate |
| Info | Dashboard | Next business day | Disk usage 70% |

### Prometheus Alerting Rules
```yaml
groups:
  - name: slo-alerts
    rules:
      - alert: ErrorBudgetBurn
        expr: |
          (
            sum(rate(http_requests_total{status=~"5.."}[1h]))
            /
            sum(rate(http_requests_total[1h]))
          ) > (1 - 0.999) * 14.4
        for: 5m
        labels:
          severity: critical
        annotations:
          summary: "Error budget burning too fast"
          description: "At current rate, error budget will be exhausted in {{ $value | humanizeDuration }}"
```

## Observability Checklist

- [ ] Structured JSON logging implemented
- [ ] Request IDs propagated across services
- [ ] Four golden signals metrics exposed
- [ ] Distributed tracing enabled
- [ ] SLOs defined for critical user journeys
- [ ] Alerts based on symptoms, not causes
- [ ] Runbooks linked to alerts
- [ ] Dashboards for key services
- [ ] Log aggregation configured
- [ ] No sensitive data in logs/traces
