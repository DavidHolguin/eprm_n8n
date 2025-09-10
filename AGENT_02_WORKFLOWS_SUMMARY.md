# Agente 02: Account-Management-Assistant - Resumen de Workflows

## Descripción General

El Agente 02 es el **Asistente de Gestión de Cuenta y Relaciones** dentro de la EPRM SUITE. Es responsable de gestionar leads comerciales, suscripciones, uso de la plataforma, tickets de soporte y métricas de clientes.

## Workflows Creados

### 1. Workflow Principal
- **[A02] Account-Management-Orchestrator**: Orquestador principal que escucha notificaciones de tareas y las distribuye a los subworkflows correspondientes.

### 2. Subworkflows de Capacidades (MCP-SUB)

#### Gestión de Leads Comerciales
1. **[MCP-SUB] A02-CreateLead**: Crea nuevos leads comerciales en la base de datos
2. **[MCP-SUB] A02-UpdateLeadStatus**: Actualiza el estado de leads existentes (new → contacted → qualified → won/lost)

#### Gestión de Suscripciones
3. **[MCP-SUB] A02-RegisterSubscription**: Registra nuevas suscripciones, opcionalmente creando organizaciones y usuarios admin

#### Monitoreo de Uso de Plataforma
4. **[MCP-SUB] A02-LogPlatformUsage**: Registra el uso de características de la plataforma por usuarios
5. **[MCP-SUB] A02-GenerateUsageReport**: Genera informes de uso utilizando IA para análisis y recomendaciones
6. **[MCP-SUB] A02-SendUsageReport**: Envía informes de uso a destinatarios específicos

#### Gestión de Soporte
7. **[MCP-SUB] A02-CreateSupportTicket**: Crea tickets de soporte y notifica al equipo técnico
8. **[MCP-SUB] A02-UpdateSupportTicket**: Actualiza el estado y detalles de tickets de soporte
9. **[MCP-SUB] A02-EscalateComplaint**: Escala quejas sin resolver al Agente 19 para mejora continua

#### Métricas y Análisis
10. **[MCP-SUB] A02-ProvideMetricsData**: Agrega y envía datos de métricas al Agente 17 para análisis de KPIs

## Características Principales

### Arquitectura de Pizarra (Blackboard)
- Utiliza la tabla `public.tasks` como sistema de comunicación central
- Función `public.claim_next_task` para reclamar tareas atómicamente
- Sistema de estados de tareas (queued → in_progress → completed_success/completed_failed)

### Seguridad Integrada
- **RLS (Row Level Security)**: Políticas a nivel de fila en todas las tablas
- **Gatekeeper**: Función `public.route_task_request` valida permisos antes de crear tareas
- **Autenticación JWT**: Credenciales específicas para cada agente

### Manejo de Errores
- Workflow centralizado `[CORE] Handle-Error-and-Retry`
- Reintentos con backoff exponencial
- Logging detallado de todos los errores

### Observabilidad
- Función `public.log_event` para logging centralizado
- Tabla `public.execution_logs` para trazabilidad completa
- Tabla `public.task_state_history` para historial de estados

### Optimización para LLMs
- Preprocesamiento de datos antes de enviar a modelos de IA
- Resumen y agregación inteligente de información
- Contexto optimizado para reducir tokens y mejorar respuestas

## Integraciones con Otros Agentes

- **Agente 03**: Creación de organizaciones y usuarios
- **Agente 13**: Envío de comunicaciones y notificaciones
- **Agente 17**: Envío de datos para análisis de métricas
- **Agente 19**: Escalada de quejas para mejora continua
- **Agente 20**: Recepción de leads desde chat conversacional

## Tablas de Base de Datos Utilizadas

1. **public.commercial_leads**: Gestión de leads de ventas
2. **public.subscriptions**: Registro de suscripciones
3. **public.platform_usage_logs**: Logs de uso de la plataforma
4. **public.support_tickets**: Tickets de soporte al cliente
5. **public.tasks**: Sistema de tareas compartido
6. **public.execution_logs**: Logs de ejecución centralizados

## Task Types Soportados

El Agente 02 maneja los siguientes tipos de tareas:
- `create_lead`
- `update_lead_status`
- `register_subscription`
- `log_platform_usage`
- `generate_usage_report`
- `send_usage_report`
- `create_support_ticket`
- `update_support_ticket`
- `escalate_complaint`
- `provide_metrics_data`

## Configuración Requerida

### Variables de Entorno en n8n
- Credenciales de Supabase (`supabaseCredential`)
- Credenciales de OpenAI para generación de informes
- Configuración de triggers para `task_updates` channel

### Dependencias
- Workflows CORE: `[CORE] Handle-Error-and-Retry`
- Subworkflows de otros agentes referenciados

## Estados de Activación
- **Workflow Principal**: `active: true` (siempre escuchando)
- **Subworkflows**: `active: false` (invocados bajo demanda)

## Notas de Implementación

1. Todos los workflows siguen la nomenclatura estándar EPRM
2. Manejo consistente de errores en todos los flujos
3. Logging detallado para auditabilidad
4. Optimización de datos para reducir latencia en LLMs
5. Integración completa con el sistema de seguridad RLS

---

**Versión**: 1.0  
**Fecha de Creación**: 2024-01-15  
**Agente**: A02 - Account-Management-Assistant  
**Total de Workflows**: 11 (1 principal + 10 subworkflows)