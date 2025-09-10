# Agent 01: Integration-Orchestration - Complete Workflow Suite

## Overview
Agent 01 serves as the central orchestrator for the entire EPRM Suite, acting as the primary entry point for all task requests and managing the coordination between all 20 specialized agents. This agent implements a sophisticated microservices-like architecture using n8n workflows, ensuring scalability, maintainability, and robust error handling.

## Architecture Principles

### Nomenclatura Estandarizada (Standardized Naming)
- **Main Workflows**: `[A01] Description` - Primary agent workflows
- **Capability Subworkflows**: `[MCP-SUB] A01-VerbNoun` - Modular Capability Processes aligned with MCP
- **Core Transversal Subworkflows**: `[CORE] Description` - Fundamental, reusable components across the suite

### Security Strategy
- **Centralized Security**: All security validation occurs in Supabase via `route_task_request` function before n8n execution
- **RLS Enforcement**: Row-Level Security policies enforce agent-specific permissions
- **JWT Authentication**: Agent-specific JWTs for protocol authentication
- **Zero Trust**: No task executes without pre-authorization from the "Central Brain"

### Error Handling Philosophy
- **Centralized Error Handling**: `[CORE] Handle-Error-and-Retry` provides consistent retry logic
- **Exponential Backoff**: Smart retry strategies based on error types
- **Comprehensive Logging**: Every operation logged to `execution_logs` for observability
- **Graceful Degradation**: Fallback mechanisms for critical operations

## Complete Workflow Suite

### 1. [A01] Master-Task-Orchestrator ✅
**File**: `A01-Master-Task-Orchestrator.json`

**Purpose**: Central entry point for all task requests in the EPRM Suite

**Key Features**:
- Webhook-based task ingestion (`/task-orchestrator`)
- Parameter validation with UUID format checking
- Dynamic agent assignment via Supabase `route_task_request`
- Dynamic subworkflow execution based on agent capabilities
- Comprehensive error handling and status tracking

**Input Payload**:
```json
{
  "organization_id": "uuid-v4-string",
  "creator_user_id": "uuid-v4-string", 
  "task_type": "string-capability-name",
  "parameters": {},
  "priority": 0,
  "project_id": "uuid-v4-string-optional"
}
```

**Integration Points**:
- Calls: `[CORE] Handle-Error-and-Retry`, `[CORE] Log-Event`
- Updates: `tasks` table, `execution_logs` table
- Invokes: Agent-specific subworkflows dynamically

### 2. [CORE] Handle-Error-and-Retry ✅
**File**: `CORE-Handle-Error-and-Retry.json`

**Purpose**: Centralized error handling with intelligent retry logic

**Key Features**:
- Exponential backoff retry strategy (max 3 attempts)
- Error categorization (network, rate_limit, validation, permission)
- Task state management during retries
- Critical failure notifications via Agent 13
- Comprehensive retry logging

**Input Parameters**:
```json
{
  "task_id": "uuid",
  "error_message": "string",
  "workflow_to_retry_id": "string",
  "workflow_params": {},
  "agent_id": "string"
}
```

**Retry Policy**:
- Base delay: 5 seconds
- Multiplier: 2x exponential backoff
- Network errors: 30s retry delay
- Rate limits: 60s retry delay
- Validation/Permission errors: No retry

### 3. [CORE] Log-Event ✅
**File**: `CORE-Log-Event.json`

**Purpose**: Standardized logging interface for all workflows

**Key Features**:
- Structured logging to `execution_logs` via `log_event` function
- Multiple log levels (DEBUG, INFO, WARN, ERROR)
- Unique trace_id generation
- Fallback direct insert mechanism
- Execution context tracking

**Input Parameters**:
```json
{
  "log_level": "INFO|WARN|ERROR|DEBUG",
  "log_message": "string",
  "task_id": "uuid-optional",
  "agent_id": "string-optional",
  "details": "object-optional"
}
```

**Usage Example**:
```javascript
// From any workflow
workflowId: "[CORE] Log-Event",
parameters: {
  log_level: "INFO",
  log_message: "Task processing started",
  task_id: "{{ $json.task_id }}",
  agent_id: "A01",
  details: "{{ JSON.stringify($json.details) }}"
}
```

### 4. [MCP-SUB] A01-HandleMCPRequest ✅
**File**: `MCP-SUB-A01-HandleMCPRequest.json`

**Purpose**: Model Context Protocol (MCP) adapter server

**Key Features**:
- JSON-RPC 2.0 compliant MCP server
- JWT Bearer token authentication
- Multiple MCP methods support
- Agent capability exposition
- Request/response logging

**Supported MCP Methods**:
- `tasks/execute`: Execute tasks via Master Orchestrator
- `agent/info`: Return agent information
- `capabilities/list`: List agent capabilities

**Webhook Endpoint**: `/mcp-server`

**Authentication**: Bearer JWT token in Authorization header

**Sample MCP Request**:
```json
{
  "jsonrpc": "2.0",
  "method": "tasks/execute",
  "params": {
    "task_type": "data_analysis",
    "parameters": {"dataset": "sales_data.csv"},
    "organization_id": "uuid",
    "creator_user_id": "uuid"
  },
  "id": "request-123"
}
```

### 5. [MCP-SUB] A01-HandleA2ARequest ✅
**File**: `MCP-SUB-A01-HandleA2ARequest.json`

**Purpose**: Agent-to-Agent (A2A) protocol adapter server

**Key Features**:
- JSON-RPC 2.0 compliant A2A server
- Custom agent authentication headers
- Agent card information service
- Inter-agent task delegation
- Comprehensive A2A logging

**Supported A2A Methods**:
- `getAgentCard`: Return detailed agent card with capabilities
- `executeTask`: Delegate task execution to Master Orchestrator

**Webhook Endpoint**: `/a2a-server`

**Authentication**: 
- `X-Agent-Auth`: Agent authentication token
- `X-Agent-Id`: Requesting agent identifier

**Agent Card Response**:
```json
{
  "id": "A01",
  "name": "Integration-Orchestration Agent",
  "version": "1.0.0",
  "capabilities": [
    {
      "name": "task_orchestration",
      "description": "Orchestrate tasks across multiple agents",
      "input_schema": {...}
    }
  ],
  "protocols": {
    "mcp": {"endpoint": "/webhook/mcp-server"},
    "a2a": {"endpoint": "/webhook/a2a-server"}
  },
  "status": "active"
}
```

## Database Integration

### Tables Utilized
- **`tasks`**: Primary task lifecycle management
  - Status tracking (pending → in_progress → completed_success/failed)
  - Retry count and scheduling
  - Result and error storage

- **`execution_logs`**: Comprehensive operation logging
  - Structured JSONB details
  - Trace ID for operation correlation
  - Performance metrics

- **`task_state_history`**: Automatic state transition logging
  - Immutable audit trail
  - Who/when/what changed tracking

### Functions Called
- **`route_task_request`**: Core routing and security validation
- **`log_event`**: Standardized logging interface

## Error Handling Matrix

| Error Type | Retry | Delay | Max Attempts | Final Action |
|------------|-------|-------|--------------|--------------|
| Network | Yes | 30s | 3 | Log + Notify |
| Rate Limit | Yes | 60s | 3 | Log + Notify |
| Validation | No | - | 0 | Immediate fail |
| Permission | No | - | 0 | Immediate fail |
| Unknown | Yes | 5s | 3 | Log + Notify |

## Security Implementation

### Authentication Flow
1. **Request Reception**: Webhook receives request
2. **Token Validation**: JWT/Agent auth validation
3. **Supabase Gatekeeper**: `route_task_request` validates permissions
4. **RLS Enforcement**: Row-Level Security restricts data access
5. **Agent Execution**: Pre-authorized task execution

### Security Headers
- **MCP**: `Authorization: Bearer <jwt-token>`
- **A2A**: `X-Agent-Auth: <agent-token>`, `X-Agent-Id: <agent-id>`

## Performance Considerations

### Optimization Strategies
- **Async Execution**: Non-blocking workflow execution
- **Connection Pooling**: Supabase connection optimization
- **Batch Operations**: Multiple database operations in single transactions
- **Caching**: Static agent card information caching

### Monitoring Metrics
- **Execution Time**: Tracked in all responses
- **Success Rate**: Logged in execution_logs
- **Retry Patterns**: Analyzed for system health
- **Error Rates**: Monitored for alerting

## Import Instructions

### Prerequisites
1. **Supabase Configuration**: 
   - "Supabase account" credential configured
   - Required functions deployed (`route_task_request`, `log_event`)
   - RLS policies active

2. **Database Schema**: 
   - Tables exist: `tasks`, `execution_logs`, `task_state_history`
   - Triggers configured for automatic state history

### Import Process
1. Import workflows in dependency order:
   ```
   1. [CORE] Log-Event
   2. [CORE] Handle-Error-and-Retry  
   3. [A01] Master-Task-Orchestrator
   4. [MCP-SUB] A01-HandleMCPRequest
   5. [MCP-SUB] A01-HandleA2ARequest
   ```

2. **Credential Verification**: Ensure all workflows use "Supabase account"

3. **Webhook URLs**: Note URLs for integration:
   - Master Orchestrator: `/webhook/task-orchestrator`
   - MCP Server: `/webhook/mcp-server`  
   - A2A Server: `/webhook/a2a-server`

4. **Activation**: Activate all workflows after import

## Testing Strategy

### Unit Testing
```bash
# Master Orchestrator
curl -X POST [webhook-url]/task-orchestrator \
  -H "Content-Type: application/json" \
  -d '{
    "organization_id": "123e4567-e89b-12d3-a456-426614174000",
    "creator_user_id": "987fcdeb-51a2-43d7-8f6e-123456789abc",
    "task_type": "data_analysis",
    "parameters": {"dataset": "test.csv"}
  }'

# MCP Protocol
curl -X POST [webhook-url]/mcp-server \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer test-jwt" \
  -d '{
    "jsonrpc": "2.0",
    "method": "agent/info",
    "id": "test-001"
  }'

# A2A Protocol  
curl -X POST [webhook-url]/a2a-server \
  -H "Content-Type: application/json" \
  -H "X-Agent-Auth: test-auth-token" \
  -H "X-Agent-Id: A02" \
  -d '{
    "jsonrpc": "2.0",
    "method": "getAgentCard",
    "id": "a2a-test-001"
  }'
```

### Integration Testing
- **End-to-End**: Full task lifecycle from request to completion
- **Error Scenarios**: Timeout, validation, permission failures
- **Protocol Compliance**: MCP and A2A specification adherence
- **Performance**: Load testing with concurrent requests

## Monitoring and Observability

### Key Metrics
- **Task Throughput**: Tasks processed per minute
- **Success Rate**: Percentage of successful completions
- **Average Execution Time**: Performance baseline
- **Error Distribution**: Error type frequency analysis

### Alerting Thresholds
- **Critical**: Task failure rate > 10%
- **Warning**: Average execution time > 30s
- **Info**: Retry attempts > 50% of tasks

### Dashboard Queries
```sql
-- Task success rate (last 24h)
SELECT 
  COUNT(CASE WHEN status = 'completed_success' THEN 1 END) * 100.0 / COUNT(*) as success_rate
FROM tasks 
WHERE created_at > NOW() - INTERVAL '24 hours';

-- Average execution time by agent
SELECT 
  agent_id,
  AVG(execution_time_ms) as avg_execution_ms
FROM execution_logs 
WHERE created_at > NOW() - INTERVAL '1 hour'
GROUP BY agent_id;

-- Error distribution
SELECT 
  JSON_EXTRACT_PATH_TEXT(details::json, 'errorType') as error_type,
  COUNT(*) as count
FROM execution_logs 
WHERE log_level = 'ERROR' 
  AND created_at > NOW() - INTERVAL '24 hours'
GROUP BY error_type
ORDER BY count DESC;
```

## Dependencies and Requirements

### Required Agent Workflows
- **Agent 13**: `[A13] NotificationManager` for critical failure notifications
- **Agent-specific subworkflows**: Following `[MCP-SUB] AXX-VerbNoun` convention

### External Dependencies
- **Supabase**: Database and RLS enforcement
- **n8n**: Workflow execution environment  
- **JWT**: Authentication tokens for MCP
- **HTTP**: RESTful API communication

## Future Enhancements

### Planned Features
- **Circuit Breaker**: Prevent cascade failures
- **Rate Limiting**: Request throttling per organization
- **Caching Layer**: Redis integration for performance
- **Message Queue**: Asynchronous task processing
- **Health Checks**: Automated system monitoring

### Scalability Improvements
- **Horizontal Scaling**: Multi-instance n8n deployment
- **Load Balancing**: Request distribution
- **Database Sharding**: Large-scale data partitioning
- **CDN Integration**: Global request routing

---

This complete suite establishes Agent 01 as the robust foundation for the entire EPRM Suite, providing secure, scalable, and maintainable orchestration capabilities with comprehensive error handling, logging, and protocol adaptation.