# Chatbot IA para Pruebas del Orquestador

## Overview

El workflow `[AI-CHATBOT] Task-Orchestrator-Test-Bot` permite interactuar con el sistema de pruebas usando lenguaje natural. El chatbot utiliza IA (OpenAI GPT-3.5-turbo) para interpretar comandos y ejecutar las pruebas correspondientes en el A01-Master-Task-Orchestrator.

## URL del Webhook

Una vez importado y activado:
```
http://localhost:5678/webhook/chatbot-test
```

## Funcionalidades

### 🤖 Reconocimiento de Intenciones
- **test_run**: Ejecutar pruebas específicas
- **help**: Mostrar ayuda y comandos disponibles  
- **status**: Verificar estado del sistema
- **logs**: Ver historial de pruebas recientes
- **unknown**: Manejar solicitudes no reconocidas

### 📝 Logging Completo
- Registra todas las interacciones en tabla `chatbot_interactions`
- Mantiene historial de comandos y respuestas
- Tracking de sesiones de usuario

### 🎯 Validaciones y Formato
- Respuestas formateadas con markdown
- Validaciones automáticas de resultados
- Sugerencias inteligentes para comandos no reconocidos

## Ejemplos de Uso

### 1. Comandos Básicos de Prueba

```bash
# Análisis de datos
curl -X POST http://localhost:5678/webhook/chatbot-test \
  -H "Content-Type: application/json" \
  -d '{"message": "quiero ejecutar una prueba de análisis de datos"}'

# Procesamiento de documentos
curl -X POST http://localhost:5678/webhook/chatbot-test \
  -H "Content-Type: application/json" \
  -d '{"message": "ejecuta la prueba de procesamiento de documentos"}'

# Gestión de roles
curl -X POST http://localhost:5678/webhook/chatbot-test \
  -H "Content-Type: application/json" \
  -d '{"message": "corre una prueba de gestión de roles"}'
```

### 2. Comandos de Información

```bash
# Ayuda
curl -X POST http://localhost:5678/webhook/chatbot-test \
  -H "Content-Type: application/json" \
  -d '{"message": "help"}'

# Estado del sistema  
curl -X POST http://localhost:5678/webhook/chatbot-test \
  -H "Content-Type: application/json" \
  -d '{"message": "status"}'

# Ver histórico
curl -X POST http://localhost:5678/webhook/chatbot-test \
  -H "Content-Type: application/json" \
  -d '{"message": "histórico"}'
```

### 3. Comandos en Lenguaje Natural

```bash
# Variaciones naturales que entiende el chatbot:
curl -X POST http://localhost:5678/webhook/chatbot-test \
  -H "Content-Type: application/json" \
  -d '{"message": "puedes probar la integración con APIs?"}'

curl -X POST http://localhost:5678/webhook/chatbot-test \
  -H "Content-Type: application/json" \
  -d '{"message": "necesito correr un test de creación de usuarios"}'

curl -X POST http://localhost:5678/webhook/chatbot-test \
  -H "Content-Type: application/json" \
  -d '{"message": "ejecuta automatización de workflows por favor"}'
```

### 4. Con Usuario y Sesión

```bash
curl -X POST http://localhost:5678/webhook/chatbot-test \
  -H "Content-Type: application/json" \
  -d '{
    "message": "quiero probar el setup de organizaciones",
    "user_id": "user123",
    "session_id": "session456"
  }'
```

## Respuestas del Chatbot

### ✅ Prueba Exitosa
```json
{
  "success": true,
  "user_id": "user123",
  "session_id": "session456", 
  "intent": "test_run",
  "response_type": "test_result",
  "message": "✅ **Prueba Ejecutada Exitosamente**\n\n🧪 **Caso de prueba:** document_processing\n⏱️ **Tiempo de ejecución:** 1234ms\n🆔 **Task ID generado:** `abc123-def456`\n🤖 **Agente asignado:** agent-uuid\n📊 **Estado:** completed_success\n\n✅ **Validaciones:**\n• Task ID generado: ✅\n• Agente asignado: ✅\n• Estado completado: ✅\n• Tiempo razonable: ✅\n\n🎯 **Resultado general:** TODAS LAS VALIDACIONES PASARON",
  "test_case": "document_processing",
  "task_id": "abc123-def456",
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

### ❌ Prueba con Error
```json
{
  "success": true,
  "intent": "test_run", 
  "response_type": "test_result",
  "message": "❌ **Error en la Prueba**\n\n🧪 **Caso de prueba:** api_integration\n💥 **Error:** Connection timeout\n🏷️ **Tipo de error:** network\n🔄 **Se puede reintentar:** Sí\n⏰ **Tiempo de espera:** 30000ms\n\n🔧 **Soluciones sugeridas:**\n• Verificar que A01-Master-Task-Orchestrator esté activo\n• Confirmar conexión a Supabase\n• Validar parámetros de la prueba\n• Revisar logs del sistema",
  "success": false,
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

### 📋 Ayuda
```json
{
  "success": true,
  "intent": "help",
  "response_type": "help", 
  "message": "🤖 **Asistente de Pruebas de Orquestador**\n\n**Comandos disponibles:**\n\n📋 **Tipos de prueba:**\n• `default` - Análisis de datos básico\n• `document_processing` - Procesamiento de documentos\n• `api_integration` - Integración con APIs\n• `workflow_automation` - Automatización de workflows\n• `role_management` - Gestión de roles y permisos\n• `user_creation` - Creación de usuarios\n• `organization_setup` - Configuración de organizaciones\n• `report_generation` - Generación de reportes\n\n💬 **Ejemplos de uso:**\n• \"Ejecuta una prueba de análisis de datos\"\n• \"Quiero probar el procesamiento de documentos\"\n• \"Corre la prueba de gestión de roles\"\n• \"Prueba la integración con APIs\"\n\n🔧 **Otros comandos:**\n• `help` o `lista` - Mostrar esta ayuda\n• `status` - Verificar estado del sistema\n• `histórico` - Ver últimas pruebas ejecutadas\n\n¡Escribe tu solicitud en lenguaje natural y yo la ejecutaré!",
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

### 🔍 Estado del Sistema
```json
{
  "success": true,
  "intent": "status",
  "response_type": "status",
  "message": "🔍 **Estado del Sistema de Pruebas**\n\n✅ **Servicios:**\n• Chatbot IA: Activo\n• Test Orchestrator: Disponible\n• A01-Master-Task-Orchestrator: Conectado\n• Base de datos: Operativa\n\n⏰ **Información:**\n• Tiempo actual: 01/01/2024, 12:00:00\n• Uptime aproximado: 24 horas\n• Último reinicio: Hace 12 horas\n\n🎯 **Pruebas disponibles:** 8 tipos\n💾 **Logs:** Almacenados en Supabase\n\nTodo funcionando correctamente. ¡Listo para ejecutar pruebas!",
  "system_status": "operational",
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

### 📊 Historial de Pruebas
```json
{
  "success": true,
  "intent": "logs",
  "response_type": "logs",
  "message": "📋 **Últimas Pruebas Ejecutadas**\n\n✅ **document_processing**\n   📅 01/01/2024, 12:00:00\n   ⏱️ 1234ms | 🆔 abc123...\n\n❌ **api_integration**\n   📅 01/01/2024, 11:45:00\n   ⏱️ 5000ms\n   💥 Connection timeout...\n\n✅ **role_management**\n   📅 01/01/2024, 11:30:00\n   ⏱️ 890ms | 🆔 def456...\n\n📊 **Estadísticas:**\n• Total de pruebas: 10\n• Exitosas: 7\n• Fallidas: 3",
  "logs_count": 10,
  "timestamp": "2024-01-01T12:00:00.000Z"
}
```

## Casos de Prueba Disponibles

El chatbot puede ejecutar los mismos 8 tipos de prueba que el workflow de test directo:

1. **default** - Análisis de datos básico
2. **document_processing** - Procesamiento de documentos  
3. **api_integration** - Integración con APIs
4. **workflow_automation** - Automatización de workflows
5. **role_management** - Gestión de roles
6. **user_creation** - Creación de usuarios
7. **organization_setup** - Configuración de organizaciones
8. **report_generation** - Generación de reportes

## Frases que Reconoce

### Para ejecutar pruebas:
- "quiero ejecutar una prueba de..."
- "corre la prueba de..."
- "ejecuta..."
- "prueba..."
- "necesito correr un test de..."
- "puedes probar...?"

### Para ayuda:
- "help"
- "ayuda"  
- "lista"
- "qué puedes hacer?"
- "comandos disponibles"

### Para estado:
- "status"
- "estado"
- "cómo está el sistema?"
- "está funcionando?"

### Para historial:
- "histórico"
- "logs"
- "últimas pruebas"
- "qué pruebas se han ejecutado?"

## Base de Datos

### Tabla: `chatbot_interactions`
```sql
CREATE TABLE chatbot_interactions (
  id SERIAL PRIMARY KEY,
  user_id TEXT,
  session_id TEXT,
  original_message TEXT NOT NULL,
  intent TEXT NOT NULL,
  response_type TEXT NOT NULL,
  success BOOLEAN DEFAULT FALSE,
  test_case TEXT,
  task_id TEXT,
  response_message TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);
```

### Tabla: `test_execution_logs` (reutilizada)
Ya existe del workflow de test directo.

## Configuración Necesaria

### 1. Credenciales OpenAI
- Configurar credencial `openai-account` en n8n
- API Key de OpenAI con acceso a GPT-3.5-turbo

### 2. Supabase
- Configurar credencial `supabase-account` 
- Crear tabla `chatbot_interactions`
- Tabla `test_execution_logs` debe existir

### 3. Workflows Dependientes
- `[TEST] A01-Task-Orchestrator-Test` debe estar activo
- `A01-Master-Task-Orchestrator` debe estar funcionando

## Ejemplo de Integración con WhatsApp/Telegram

```javascript
// Ejemplo para webhook de WhatsApp
const webhookData = {
  message: userMessage,
  user_id: whatsappUserId,
  session_id: `whatsapp_${whatsappUserId}`
};

fetch('http://localhost:5678/webhook/chatbot-test', {
  method: 'POST',
  headers: { 'Content-Type': 'application/json' },
  body: JSON.stringify(webhookData)
})
.then(response => response.json())
.then(data => {
  // Enviar data.message de vuelta al usuario en WhatsApp
  sendWhatsAppMessage(whatsappUserId, data.message);
});
```

## Troubleshooting

### Error: "OpenAI API not responding"
- Verificar credenciales OpenAI
- Confirmar que tienes crédito disponible
- Revisar que el modelo GPT-3.5-turbo esté disponible

### Error: "Test workflow not found" 
- Verificar que `[TEST] A01-Task-Orchestrator-Test` esté importado y activo
- Confirmar URL del webhook de test

### El chatbot no entiende comandos
- Revisar el prompt del sistema en el nodo "AI Intent Recognition"
- Ajustar la temperatura del modelo (actualmente 0.3)
- Verificar que el mensaje llegue correctamente al nodo

¡El chatbot está listo para interpretar comandos en lenguaje natural y ejecutar las pruebas del orquestador!