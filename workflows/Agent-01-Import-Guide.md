# Agent 01 - Import and Setup Guide

## Quick Import Checklist

### ✅ Pre-Import Requirements
- [ ] Supabase instance running and accessible
- [ ] "Supabase account" credential configured in n8n
- [ ] Database schema deployed with required tables
- [ ] Required Supabase functions deployed
- [ ] RLS policies activated

### ✅ Import Order (Critical!)
Import workflows in this exact order to resolve dependencies:

1. **[CORE] Log-Event** (`CORE-Log-Event.json`)
2. **[CORE] Handle-Error-and-Retry** (`CORE-Handle-Error-and-Retry.json`)
3. **[A01] Master-Task-Orchestrator** (`A01-Master-Task-Orchestrator.json`)
4. **[MCP-SUB] A01-HandleMCPRequest** (`MCP-SUB-A01-HandleMCPRequest.json`)
5. **[MCP-SUB] A01-HandleA2ARequest** (`MCP-SUB-A01-HandleA2ARequest.json`)

### ✅ Post-Import Verification
- [ ] All workflows imported successfully
- [ ] All workflows use "Supabase account" credential
- [ ] Webhook URLs noted for integration
- [ ] All workflows activated
- [ ] Basic functionality test passed

## Detailed Setup Instructions

### Step 1: Database Prerequisites

#### Required Tables
Ensure these tables exist in your Supabase instance:

```sql
-- Tasks table
CREATE TABLE IF NOT EXISTS public.tasks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  organization_id UUID NOT NULL,
  creator_user_id UUID NOT NULL,
  task_type TEXT NOT NULL,
  parameters JSONB DEFAULT '{}',
  priority INTEGER DEFAULT 0,
  project_id UUID,
  status TEXT DEFAULT 'pending',
  assigned_agent_id TEXT,
  retry_count INTEGER DEFAULT 0,
  last_retry_attempt_at TIMESTAMPTZ,
  next_retry_schedule_at TIMESTAMPTZ,
  result JSONB,
  error_message TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  completed_at TIMESTAMPTZ,
  failed_at TIMESTAMPTZ
);

-- Execution logs table
CREATE TABLE IF NOT EXISTS public.execution_logs (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  log_level TEXT NOT NULL,
  log_message TEXT NOT NULL,
  task_id UUID REFERENCES public.tasks(id),
  agent_id TEXT,
  workflow_name TEXT,
  trace_id TEXT,
  details JSONB,
  execution_context JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- Task state history (auto-populated by triggers)
CREATE TABLE IF NOT EXISTS public.task_state_history (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  task_id UUID NOT NULL REFERENCES public.tasks(id),
  old_status TEXT,
  new_status TEXT NOT NULL,
  changed_by TEXT,
  changed_at TIMESTAMPTZ DEFAULT NOW(),
  additional_data JSONB
);
```

#### Required Functions
Deploy these functions to Supabase:

```sql
-- Core routing function
CREATE OR REPLACE FUNCTION public.route_task_request(
  p_organization_id UUID,
  p_creator_user_id UUID,
  p_task_type TEXT,
  p_parameters JSONB DEFAULT '{}',
  p_priority INTEGER DEFAULT 0,
  p_project_id UUID DEFAULT NULL
) RETURNS JSONB AS $$
DECLARE
  v_task_id UUID;
  v_assigned_agent_id TEXT;
  v_result JSONB;
BEGIN
  -- Create task record
  INSERT INTO public.tasks (
    organization_id, creator_user_id, task_type, 
    parameters, priority, project_id, status
  ) VALUES (
    p_organization_id, p_creator_user_id, p_task_type,
    p_parameters, p_priority, p_project_id, 'in_progress'
  ) RETURNING id INTO v_task_id;
  
  -- Assign agent based on task_type (customize this logic)
  v_assigned_agent_id := CASE 
    WHEN p_task_type LIKE '%data%' THEN 'A02'
    WHEN p_task_type LIKE '%document%' THEN 'A03'
    WHEN p_task_type LIKE '%api%' THEN 'A04'
    ELSE 'A02' -- Default agent
  END;
  
  -- Update task with assignment
  UPDATE public.tasks 
  SET assigned_agent_id = v_assigned_agent_id
  WHERE id = v_task_id;
  
  -- Return success result
  RETURN jsonb_build_object(
    'success', true,
    'task_id', v_task_id,
    'assigned_agent_id', v_assigned_agent_id,
    'agent_capability', p_task_type
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', SQLERRM
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- Logging function
CREATE OR REPLACE FUNCTION public.log_event(
  p_log_level TEXT,
  p_log_message TEXT,
  p_task_id UUID DEFAULT NULL,
  p_agent_id TEXT DEFAULT NULL,
  p_details TEXT DEFAULT NULL,
  p_trace_id TEXT DEFAULT NULL,
  p_workflow_name TEXT DEFAULT NULL,
  p_execution_context TEXT DEFAULT NULL
) RETURNS JSONB AS $$
DECLARE
  v_log_id UUID;
BEGIN
  INSERT INTO public.execution_logs (
    log_level, log_message, task_id, agent_id,
    details, trace_id, workflow_name, execution_context
  ) VALUES (
    p_log_level, p_log_message, p_task_id, p_agent_id,
    CASE WHEN p_details IS NOT NULL THEN p_details::jsonb ELSE NULL END,
    p_trace_id, p_workflow_name,
    CASE WHEN p_execution_context IS NOT NULL THEN p_execution_context::jsonb ELSE NULL END
  ) RETURNING id INTO v_log_id;
  
  RETURN jsonb_build_object(
    'success', true,
    'log_entry_id', v_log_id
  );
EXCEPTION
  WHEN OTHERS THEN
    RETURN jsonb_build_object(
      'success', false,
      'error', SQLERRM
    );
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
```

### Step 2: n8n Credential Configuration

1. **Navigate to n8n Settings**
2. **Go to Credentials**
3. **Create/Verify "Supabase account" credential**:
   - Name: `Supabase account`
   - Host: Your Supabase URL
   - API Key: Service role key (for server-side operations)
   - Test connection to verify

### Step 3: Import Workflows

For each workflow file in the specified order:

1. **Open n8n**
2. **Navigate to Workflows**
3. **Click "Import from file"**
4. **Select the workflow JSON file**
5. **Verify credential assignment**
6. **Save the workflow**

### Step 4: Webhook URL Documentation

After import, note these webhook URLs for integration:

```
Master Orchestrator: https://your-n8n-instance.com/webhook/task-orchestrator
MCP Server: https://your-n8n-instance.com/webhook/mcp-server  
A2A Server: https://your-n8n-instance.com/webhook/a2a-server
```

### Step 5: Activate All Workflows

Ensure all 5 workflows are **ACTIVE** status:
- [CORE] Log-Event
- [CORE] Handle-Error-and-Retry
- [A01] Master-Task-Orchestrator
- [MCP-SUB] A01-HandleMCPRequest
- [MCP-SUB] A01-HandleA2ARequest

## Verification Tests

### Test 1: Basic Task Orchestration
```bash
curl -X POST https://your-n8n-instance.com/webhook/task-orchestrator \
  -H "Content-Type: application/json" \
  -d '{
    "organization_id": "123e4567-e89b-12d3-a456-426614174000",
    "creator_user_id": "987fcdeb-51a2-43d7-8f6e-123456789abc", 
    "task_type": "test_task",
    "parameters": {"test": true}
  }'
```

Expected Response:
```json
{
  "success": true,
  "task_id": "uuid-here",
  "assigned_agent_id": "A02",
  "status": "completed_success"
}
```

### Test 2: MCP Protocol
```bash
curl -X POST https://your-n8n-instance.com/webhook/mcp-server \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer test-jwt" \
  -d '{
    "jsonrpc": "2.0",
    "method": "agent/info",
    "id": "test-001"
  }'
```

Expected Response:
```json
{
  "jsonrpc": "2.0",
  "result": {
    "id": "A01",
    "name": "Integration-Orchestration Agent",
    "status": "active"
  },
  "id": "test-001"
}
```

### Test 3: A2A Protocol
```bash
curl -X POST https://your-n8n-instance.com/webhook/a2a-server \
  -H "Content-Type: application/json" \
  -H "X-Agent-Auth: test-auth-token" \
  -H "X-Agent-Id: A02" \
  -d '{
    "jsonrpc": "2.0",
    "method": "getAgentCard",
    "id": "a2a-test-001"
  }'
```

Expected Response:
```json
{
  "jsonrpc": "2.0",
  "result": {
    "id": "A01",
    "name": "Integration-Orchestration Agent",
    "capabilities": [...]
  },
  "id": "a2a-test-001"
}
```

## Troubleshooting

### Common Issues

#### 1. "Workflow not found" errors
- **Cause**: Import order not followed
- **Solution**: Import dependencies first ([CORE] workflows before others)

#### 2. "Supabase connection failed"
- **Cause**: Incorrect credentials or network issues
- **Solution**: Verify Supabase account credential configuration

#### 3. "Function not found" errors  
- **Cause**: Required Supabase functions not deployed
- **Solution**: Deploy `route_task_request` and `log_event` functions

#### 4. "Permission denied" errors
- **Cause**: RLS policies or missing permissions
- **Solution**: Ensure service role key has appropriate permissions

#### 5. Webhook URLs not working
- **Cause**: Workflows not activated
- **Solution**: Activate all imported workflows

### Debug Steps

1. **Check n8n logs** for execution errors
2. **Verify Supabase logs** for function call issues  
3. **Test credentials** with simple Supabase operations
4. **Check workflow execution history** in n8n
5. **Validate database records** in Supabase dashboard

### Support Resources

- **n8n Documentation**: https://docs.n8n.io/
- **Supabase Documentation**: https://supabase.com/docs
- **Workflow Logs**: Check individual execution logs in n8n
- **Database Logs**: Monitor Supabase real-time logs

## Production Considerations

### Security Checklist
- [ ] RLS policies properly configured
- [ ] Service role keys securely stored  
- [ ] Webhook URLs use HTTPS
- [ ] Authentication tokens rotated regularly
- [ ] Database backups enabled

### Performance Optimization  
- [ ] Supabase connection pooling configured
- [ ] n8n execution limits set appropriately
- [ ] Database indexes created for common queries
- [ ] Monitoring and alerting configured
- [ ] Resource scaling planned

### Maintenance Schedule
- [ ] Weekly credential rotation
- [ ] Monthly performance review
- [ ] Quarterly security audit  
- [ ] Database maintenance windows
- [ ] Workflow version control

---

Following this guide ensures a successful Agent 01 deployment with all workflows properly integrated and functional.