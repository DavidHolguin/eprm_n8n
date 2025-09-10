# [A01] Master Task Orchestrator - Workflow Documentation

## Overview
This workflow serves as the central entry point for all task requests within the EPRM SUITE. It receives task requests, validates them, routes them to the appropriate agent via Supabase's Core Orchestrator, and executes the corresponding agent subworkflow dynamically.

## Features
- **Webhook-based task ingestion** with POST endpoint `/task-orchestrator`
- **Parameter validation** for all required fields with UUID format checking
- **Dynamic agent assignment** via Supabase `route_task_request` function
- **Error handling and retry logic** with detailed logging
- **Dynamic subworkflow execution** based on agent capabilities
- **Comprehensive logging** to `execution_logs` table
- **Task status management** in `tasks` table

## Input Payload Structure
```json
{
  "organization_id": "uuid-v4-string",
  "creator_user_id": "uuid-v4-string", 
  "task_type": "string-capability-name",
  "parameters": {
    "key": "value",
    "nested": {
      "data": "example"
    }
  },
  "priority": 0,
  "project_id": "uuid-v4-string-optional"
}
```

## Required Parameters
- `organization_id` (UUID): Organization identifier
- `creator_user_id` (UUID): User who created the task
- `task_type` (STRING): Capability type that maps to an agent

## Optional Parameters  
- `parameters` (JSONB): Task-specific parameters, defaults to `{}`
- `priority` (INTEGER): Task priority, defaults to `0`
- `project_id` (UUID): Associated project, can be `null`

## Response Formats

### Success Response
```json
{
  "success": true,
  "task_id": "uuid-of-created-task",
  "assigned_agent_id": "agent-identifier",
  "status": "completed_success",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "execution_time_ms": 1234
}
```

### Error Response (HTTP 500)
```json
{
  "success": false,
  "error": "error-description",
  "errorType": "validation|network|rate_limit|permission|unknown",
  "task_id": "uuid-if-available",
  "timestamp": "2024-01-01T00:00:00.000Z",
  "shouldRetry": true,
  "retryDelay": 30000
}
```

## Workflow Nodes

### 1. Webhook - Task Ingestion
- **Type**: Webhook Trigger
- **Method**: POST
- **Path**: `/task-orchestrator`
- **Purpose**: Receives incoming task requests

### 2. Extract & Validate Parameters
- **Type**: Function Node
- **Purpose**: Validates required parameters and UUID formats
- **Validation Rules**:
  - Required: `organization_id`, `creator_user_id`, `task_type`
  - UUID format validation for ID fields
  - Parameter type checking

### 3. Route Task Request  
- **Type**: Supabase Function Call
- **Function**: `route_task_request`
- **Purpose**: Creates task in DB and assigns to appropriate agent
- **Credentials**: Uses "Supabase account" credential

### 4. Check Task Assignment Success
- **Type**: IF Node
- **Condition**: Checks `success` field from Supabase response
- **Routes**: Success → Agent execution, Failure → Error handling

### 5. Determine Subworkflow
- **Type**: Function Node
- **Purpose**: Maps agent capability to subworkflow name
- **Mapping**: Converts `task_type` to `[MCP-SUB] AXX-VerbNoun` format

### 6. Execute Agent Subworkflow
- **Type**: Execute Workflow Node  
- **Purpose**: Dynamically calls the assigned agent's subworkflow
- **Parameters**: Passes all original task data plus routing information

### 7. Update Task Success
- **Type**: Supabase Update
- **Table**: `tasks`
- **Purpose**: Marks task as `completed_success`
- **Updates**: Status, completion timestamp, result data

### 8. Handle Error and Retry Logic
- **Type**: Function Node
- **Purpose**: Categorizes errors and determines retry strategy
- **Error Types**: network, rate_limit, validation, permission, unknown

### 9. Update Task Error
- **Type**: Supabase Update  
- **Table**: `tasks`
- **Purpose**: Marks task as `failed` with error details

### 10. Log Success/Error to Execution Logs
- **Type**: Supabase Insert
- **Table**: `execution_logs`
- **Purpose**: Comprehensive logging for monitoring and debugging

### 11. Success/Error Response
- **Type**: Respond to Webhook
- **Purpose**: Returns appropriate HTTP response to caller

## Agent Capability Mapping
The workflow includes a mapping system to convert `task_type` to subworkflow names:

```javascript
const agentMapping = {
  'data_analysis': 'A02',
  'document_processing': 'A03', 
  'api_integration': 'A04',
  'workflow_automation': 'A05'
};
```

**Subworkflow Naming Convention**: `[MCP-SUB] AXX-VerbNoun`

## Error Handling Strategy

### Network Errors
- **Retry**: Yes
- **Delay**: 30 seconds
- **Trigger**: timeout, network, connection errors

### Rate Limiting  
- **Retry**: Yes
- **Delay**: 60 seconds
- **Trigger**: rate limit, 429 status

### Validation Errors
- **Retry**: No
- **Action**: Return error immediately

### Permission Errors
- **Retry**: No  
- **Action**: Return error immediately

## Database Integration

### Tables Used
- `tasks`: Task lifecycle management
- `execution_logs`: Detailed execution logging
- `agents`: Referenced via Supabase function
- `agent_capabilities`: Referenced via Supabase function

### Functions Called
- `route_task_request`: Core routing logic in Supabase

## Import Instructions

1. Open n8n interface
2. Navigate to Workflows
3. Click "Import from File"
4. Select `A01-Master-Task-Orchestrator.json`
5. Verify "Supabase account" credential is configured
6. Activate the workflow
7. Note the webhook URL for integration

## Testing

### Test Payload Example
```bash
curl -X POST [your-n8n-webhook-url]/task-orchestrator \
  -H "Content-Type: application/json" \
  -d '{
    "organization_id": "123e4567-e89b-12d3-a456-426614174000",
    "creator_user_id": "987fcdeb-51a2-43d7-8f6e-123456789abc", 
    "task_type": "data_analysis",
    "parameters": {
      "dataset": "sales_data.csv",
      "analysis_type": "trend"
    },
    "priority": 1
  }'
```

## Monitoring

- Check `execution_logs` table for detailed execution history
- Monitor webhook response times and success rates
- Review `tasks` table for task completion statistics
- Set up alerts for failed tasks requiring manual intervention

## Dependencies

### Required Credentials
- **Supabase account**: Configured with appropriate permissions

### Required Subworkflows
- Agent-specific subworkflows following `[MCP-SUB] AXX-VerbNoun` naming convention

### Database Setup
- Ensure `route_task_request` function exists in Supabase
- Verify table schemas match the workflow expectations