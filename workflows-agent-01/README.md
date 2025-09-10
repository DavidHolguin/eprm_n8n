# Workflows Agent 01 - Integration-Orchestration

Este directorio contiene todos los workflows y subworkflows del **Agente 01: Integration-Orchestration**, el orquestador central de la EPRM Suite.

## Estructura de Archivos

### 🎯 Workflows Principales
- **`[A01] Master-Task-Orchestrator.json`** - Punto de entrada central para todas las solicitudes de tareas

### 🔧 Subworkflows Core Transversales  
- **`[CORE] Handle-Error-and-Retry.json`** - Manejo centralizado de errores con reintentos automáticos
- **`[CORE] Log-Event.json`** - Sistema de logging estandarizado para trazabilidad

### 🔌 Subworkflows de Adaptadores de Protocolo
- **`[MCP-SUB] A01-HandleMCPRequest.json`** - Servidor MCP para Model Context Protocol
- **`[MCP-SUB] A01-HandleA2ARequest.json`** - Servidor A2A para comunicación Agent-to-Agent

## Descripción Funcional

### [A01] Master-Task-Orchestrator
**Propósito**: Orquestador central que recibe solicitudes de tareas, las valida, consulta a Supabase para asignación de agente, y ejecuta dinámicamente el subworkflow correspondiente.

**Endpoints**:
- `POST /task-orchestrator` - Punto de entrada principal

**Flujo**:
1. Validación de parámetros de entrada
2. Llamada a `public.route_task_request` en Supabase
3. Determinación dinámica del subworkflow del agente
4. Ejecución del subworkflow asignado
5. Actualización de estado y logging

### [CORE] Handle-Error-and-Retry
**Propósito**: Sistema resiliente de manejo de errores con backoff exponencial y reintentos automáticos.

**Características**:
- Reintentos automáticos (máximo 3)
- Backoff exponencial (5s, 10s, 20s)
- Logging detallado de intentos
- Notificación de fallos críticos
- Actualización de estado en `public.tasks`

### [CORE] Log-Event
**Propósito**: Interfaz estandarizada para logging en `public.execution_logs` con trazabilidad completa.

**Niveles de Log**: DEBUG, INFO, WARN, ERROR, CRITICAL

**Campos**:
- `log_level`, `log_message`, `task_id`, `agent_id`
- `details` (JSONB), `trace_id`, `timestamp`

### [MCP-SUB] A01-HandleMCPRequest
**Propósito**: Servidor MCP compliant que expone las capacidades del Agente 01 via Model Context Protocol.

**Endpoints**:
- `POST /mcp-server` - Servidor JSON-RPC 2.0

**Métodos Soportados**:
- `initialize` - Inicialización del protocolo MCP
- `tools/list` - Lista de herramientas disponibles
- `tools/call` - Ejecución de herramientas (orchestrate_task)
- `resources/*`, `prompts/*` - Métodos adicionales (próximas versiones)

**Autenticación**: JWT Bearer tokens con validación de expiración

### [MCP-SUB] A01-HandleA2ARequest
**Propósito**: Servidor A2A para comunicación inter-agentes usando JSON-RPC 2.0.

**Endpoints**:
- `POST /a2a-server` - Servidor Agent-to-Agent

**Métodos Soportados**:
- `ping` - Health check del agente
- `getAgentCard` - Información detallada del agente (capacidades, endpoints)
- `executeTask` - Ejecución directa de tareas
- `delegateTask` - Delegación de tareas entre agentes
- `getTaskStatus` - Consulta de estado de tareas

**Autenticación**: API Keys + Headers (`x-agent-id`, `x-api-key`)

## Configuración Requerida

### Variables de Entorno
```env
SUPABASE_URL=tu-url-de-supabase
SUPABASE_ANON_KEY=tu-clave-anonima
SUPABASE_SERVICE_ROLE_KEY=tu-clave-de-servicio
```

### Credenciales en n8n
- **Supabase EPRM** (ID: `9XlWn9W6ZDhQTb8Z`) configurada con service role key

### Base de Datos Supabase
Funciones requeridas:
- `public.route_task_request(jsonb)` - Enrutamiento y asignación de tareas
- `public.log_event(...)` - Registro de eventos
- Tablas: `public.tasks`, `public.execution_logs`, `public.task_state_history`

### Row Level Security (RLS)
- Políticas RLS configuradas para cada agente
- JWTs específicos por agente con permisos mínimos
- Validación de `organization_id` y `creator_user_id`

## Patrones de Diseño

### Nomenclatura Estandarizada
- **[A01]** - Workflows principales del Agente 01
- **[MCP-SUB]** - Subworkflows de capacidades específicas (MCP-aligned)
- **[CORE]** - Subworkflows transversales reutilizables

### Manejo de Errores
Todos los workflows implementan:
- Conexiones de error hacia `[CORE] Handle-Error-and-Retry`
- Logging consistente via `[CORE] Log-Event`
- Respuestas estructuradas con códigos HTTP apropiados

### Trazabilidad
- `trace_id` únicos para seguimiento completo
- Logging en cada paso crítico
- Metadata contextual en todos los logs

### Seguridad
- Validación de entrada estricta
- Sanitización de parámetros
- Headers de seguridad en respuestas
- Rate limiting considerations

## Testing

### Endpoints de Prueba

**Task Orchestrator**:
```bash
curl -X POST https://tu-dominio.railway.app/task-orchestrator \\
  -H \"Content-Type: application/json\" \\
  -d '{
    \"organization_id\": \"uuid-aqui\",
    \"creator_user_id\": \"uuid-aqui\", 
    \"task_type\": \"test_task\",
    \"parameters\": {\"test\": true}
  }'
```

**MCP Server**:
```bash
curl -X POST https://tu-dominio.railway.app/mcp-server \\
  -H \"Content-Type: application/json\" \\
  -H \"Authorization: Bearer tu-jwt-token\" \\
  -d '{
    \"jsonrpc\": \"2.0\",
    \"method\": \"tools/list\",
    \"id\": 1
  }'
```

**A2A Server**:
```bash
curl -X POST https://tu-dominio.railway.app/a2a-server \\
  -H \"Content-Type: application/json\" \\
  -H \"x-agent-id: A02\" \\
  -H \"x-api-key: tu-api-key\" \\
  -d '{
    \"jsonrpc\": \"2.0\",
    \"method\": \"getAgentCard\",
    \"id\": 1
  }'
```

## Monitoreo

### Logs Clave
- Búsqueda por `agent_id: \"A01\"` en `public.execution_logs`
- Filtrado por `log_level: \"ERROR\"` para fallos críticos
- Tracking por `trace_id` para flujos completos

### Métricas
- Tiempo de respuesta de orquestación
- Tasa de éxito/fallo por tipo de tarea
- Distribución de carga entre agentes
- Patrones de reintento y recuperación

---

**Versión**: 1.0.0  
**Agente**: A01 - Integration-Orchestration  
**Última Actualización**: {{ new Date().toISOString().split('T')[0] }}