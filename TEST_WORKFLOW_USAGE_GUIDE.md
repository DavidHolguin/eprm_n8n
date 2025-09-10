# A01-Task-Orchestrator Test Workflow Guide

## Overview

Este workflow de prueba (`[TEST] A01-Task-Orchestrator-Test`) permite probar el `A01-Master-Task-Orchestrator` enviando peticiones POST con diferentes parámetros y casos de prueba predefinidos.

## Webhook URL

Una vez importado y activado el workflow, estará disponible en:
```
http://localhost:5678/webhook/test-orchestrator
```

## Casos de Prueba Disponibles

### 1. Default (Data Analysis)
```json
{
  "testCase": "default"
}
```

### 2. Document Processing
```json
{
  "testCase": "document_processing"
}
```

### 3. API Integration
```json
{
  "testCase": "api_integration"
}
```

### 4. Workflow Automation
```json
{
  "testCase": "workflow_automation"
}
```

### 5. Role Management
```json
{
  "testCase": "role_management"
}
```

### 6. User Creation
```json
{
  "testCase": "user_creation"
}
```

### 7. Organization Setup
```json
{
  "testCase": "organization_setup"
}
```

### 8. Report Generation
```json
{
  "testCase": "report_generation"
}
```

## Uso Básico

### Probar con caso predefinido:
```bash
curl -X POST http://localhost:5678/webhook/test-orchestrator \
  -H "Content-Type: application/json" \
  -d '{"testCase": "document_processing"}'
```

### Probar con parámetros personalizados:
```bash
curl -X POST http://localhost:5678/webhook/test-orchestrator \
  -H "Content-Type: application/json" \
  -d '{
    "testCase": "custom",
    "taskType": "custom_analysis",
    "parameters": {
      "custom_param": "valor_personalizado",
      "priority": "high"
    }
  }'
```

## Respuesta del Test

### Respuesta exitosa:
```json
{
  "test_status": "SUCCESS",
  "test_case": "document_processing",
  "test_timestamp": "2024-01-01T12:00:00.000Z",
  "request_payload": {
    "organization_id": "generated-uuid",
    "creator_user_id": "generated-uuid",
    "task_type": "document_processing",
    "parameters": {...},
    "priority": 1,
    "project_id": "generated-uuid"
  },
  "orchestrator_response": {
    "success": true,
    "task_id": "task-uuid",
    "assigned_agent_id": "agent-uuid",
    "status": "completed_success",
    "execution_time_ms": 1234,
    "timestamp": "2024-01-01T12:00:01.000Z"
  },
  "test_duration_ms": 1500,
  "validation": {
    "has_task_id": true,
    "has_assigned_agent": true,
    "status_is_completed": true,
    "execution_time_reasonable": true,
    "overall_passed": true
  }
}
```

### Respuesta de error:
```json
{
  "test_status": "ERROR",
  "test_case": "document_processing",
  "error_details": {
    "error": "Error message",
    "errorType": "validation",
    "shouldRetry": false,
    "retryDelay": 0
  },
  "troubleshooting": {
    "check_orchestrator_running": "Verify A01-Master-Task-Orchestrator is active",
    "check_webhook_url": "Confirm webhook URL is correct",
    "check_parameters": "Validate all required parameters are present",
    "check_uuid_format": "Ensure UUIDs are properly formatted",
    "check_supabase_connection": "Verify Supabase credentials and connection"
  }
}
```

## Logging

Los resultados de las pruebas se almacenan en la tabla `test_execution_logs` de Supabase con los siguientes campos:
- `test_name`: Nombre del workflow de test
- `test_case`: Caso de prueba ejecutado
- `status`: SUCCESS o ERROR
- `task_type`: Tipo de tarea probada
- `organization_id`: ID de organización usado
- `task_id`: ID de tarea generado (si exitoso)
- `assigned_agent_id`: ID del agente asignado (si exitoso)
- `execution_time_ms`: Tiempo de ejecución en millisegundos
- `validation_passed`: Si las validaciones pasaron
- `error_message`: Mensaje de error (si falló)
- `error_type`: Tipo de error (si falló)
- `request_payload`: Payload completo de la petición
- `response_data`: Datos de respuesta del orchestrator
- `created_at`: Timestamp de creación

## Validaciones Automáticas

El workflow de test incluye las siguientes validaciones:

1. **has_task_id**: Verifica que se haya generado un task_id
2. **has_assigned_agent**: Verifica que se haya asignado un agente
3. **status_is_completed**: Verifica que el status sea 'completed_success'
4. **execution_time_reasonable**: Verifica que el tiempo de ejecución sea menor a 1 minuto
5. **overall_passed**: Resumen general de todas las validaciones

## Casos de Uso

### 1. Prueba de flujo completo
```bash
# Prueba el flujo completo de análisis de datos
curl -X POST http://localhost:5678/webhook/test-orchestrator \
  -H "Content-Type: application/json" \
  -d '{"testCase": "default"}'
```

### 2. Prueba de manejo de errores
```bash
# Prueba con parámetros inválidos para verificar manejo de errores
curl -X POST http://localhost:5678/webhook/test-orchestrator \
  -H "Content-Type: application/json" \
  -d '{
    "testCase": "custom",
    "taskType": "",
    "parameters": {}
  }'
```

### 3. Prueba de diferentes tipos de agente
```bash
# Prueba varios tipos de tarea para verificar asignación de agentes
for testCase in "document_processing" "api_integration" "role_management"; do
  echo "Testing $testCase..."
  curl -X POST http://localhost:5678/webhook/test-orchestrator \
    -H "Content-Type: application/json" \
    -d "{\"testCase\": \"$testCase\"}"
  echo -e "\n"
done
```

## Prerequisitos

1. **n8n corriendo**: Asegúrate de que n8n esté ejecutándose en localhost:5678
2. **A01-Master-Task-Orchestrator activo**: El workflow principal debe estar importado y activo
3. **Supabase configurado**: Las credenciales de Supabase deben estar configuradas
4. **Tabla test_execution_logs**: La tabla debe existir en Supabase para logging

## Troubleshooting

### Error: "Connection refused"
- Verifica que n8n esté corriendo
- Confirma que el puerto 5678 esté disponible

### Error: "Webhook not found"
- Verifica que el workflow de test esté importado y activo
- Confirma la URL del webhook

### Error: "Supabase connection failed"
- Verifica las credenciales de Supabase
- Confirma que la tabla `test_execution_logs` existe

### Error: "A01-Master-Task-Orchestrator not responding"
- Verifica que el workflow A01-Master-Task-Orchestrator esté activo
- Confirma que su webhook esté en la URL esperada