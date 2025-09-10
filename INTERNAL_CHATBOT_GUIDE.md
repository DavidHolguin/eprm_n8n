# Chatbot IA Interno para N8N

## 🎯 Descripción

Este workflow permite usar un chatbot IA directamente desde el editor de N8N, sin necesidad de webhooks externos. Perfecto para probar y debuggear las funciones del orquestador de tareas desde la misma interfaz de N8N.

## 📁 Archivo

**Importar:** `[AI-CHATBOT] Internal-Test-Bot.json`

## 🚀 Cómo Usar

### 1. Importar y Configurar
1. **Importa** el workflow en N8N
2. **Configura** las credenciales de OpenAI (nodo "AI Intent Recognition")
3. **Activa** el workflow

### 2. Cambiar el Mensaje de Prueba
1. **Abre** el nodo "Simulate Chat Input"
2. **Modifica** la variable `selectedMessage` en el código:

```javascript
// Cambia este mensaje para probar diferentes comandos
const selectedMessage = "tu mensaje aquí";
```

**Ejemplos de mensajes para probar:**
```javascript
// Pruebas específicas
const selectedMessage = "ejecuta una prueba de análisis de datos";
const selectedMessage = "quiero probar el procesamiento de documentos";
const selectedMessage = "corre la prueba de gestión de roles";
const selectedMessage = "prueba la integración con APIs";

// Comandos de información
const selectedMessage = "help";
const selectedMessage = "status";

// Mensajes no reconocidos (para probar manejo de errores)
const selectedMessage = "algo que no entienda el chatbot";
```

### 3. Ejecutar
1. **Haz clic** en "Execute Workflow" o usa el botón de play
2. **Ve los resultados** en tiempo real en los logs de N8N
3. **Revisa** la respuesta formateada en el último nodo

## 🎨 Características Especiales

### ✨ Respuestas Formateadas
- **Consola mejorada**: Respuestas con formato bonito en los logs
- **Emojis y markdown**: Mensajes visualmente atractivos
- **Información detallada**: IDs de tareas, tiempos de ejecución, validaciones

### 🔧 Debug Mejorado
- **Logs en tiempo real**: Ve cada paso de la ejecución
- **Información de sesión**: Tracking completo de usuario y sesión
- **Headers especiales**: Identifica llamadas desde N8N interno

### 🎯 Casos de Prueba Incluidos

El nodo "Simulate Chat Input" incluye un array con mensajes predefinidos:

```javascript
const testMessages = [
  "ejecuta una prueba de análisis de datos",
  "quiero probar el procesamiento de documentos", 
  "corre la prueba de gestión de roles",
  "prueba la integración con APIs",
  "help",
  "status",
  "histórico"
];

// Cambiar índice para probar diferentes mensajes
const selectedMessage = testMessages[0]; // <- Cambia este número (0-6)
```

## 📊 Ejemplo de Salida

### Ejecución Exitosa
```
================================================================================
🤖 RESPUESTA DEL CHATBOT INTERNO
================================================================================

👤 Usuario: n8n_internal_user
🔗 Sesión: n8n_session_1704067200000
🎯 Intención: test_run
📋 Tipo: test_result
🧪 Caso de prueba: document_processing
🆔 Task ID: abc123-def456-ghi789
⏰ Timestamp: 2024-01-01T12:00:00.000Z

💬 MENSAJE:
----------------------------------------
✅ **Prueba Ejecutada Exitosamente (N8N Interno)**

🧪 **Caso de prueba:** document_processing
⏱️ **Tiempo de ejecución:** 1234ms
🆔 **Task ID generado:** `abc123-def456-ghi789`
🤖 **Agente asignado:** agent-uuid
📊 **Estado:** completed_success
🔧 **Ejecutado desde:** N8N Editor

✅ **Validaciones:**
• Task ID generado: ✅
• Agente asignado: ✅
• Estado completado: ✅
• Tiempo razonable: ✅

🎯 **Resultado general:** TODAS LAS VALIDACIONES PASARON

🔄 **Para ejecutar otra prueba:**
• Edita el nodo "Simulate Chat Input"
• Cambia el mensaje de prueba
• Vuelve a ejecutar el workflow
----------------------------------------
✨ Éxito: true
================================================================================
```

### Comando de Ayuda
```
================================================================================
🤖 RESPUESTA DEL CHATBOT INTERNO
================================================================================

👤 Usuario: n8n_internal_user
🔗 Sesión: n8n_session_1704067200000
🎯 Intención: help
📋 Tipo: help

💬 MENSAJE:
----------------------------------------
🤖 **Asistente de Pruebas de Orquestador (N8N Interno)**

**Comandos disponibles:**

📋 **Tipos de prueba:**
• default - Análisis de datos básico
• document_processing - Procesamiento de documentos
• api_integration - Integración con APIs
• workflow_automation - Automatización de workflows
• role_management - Gestión de roles y permisos
• user_creation - Creación de usuarios
• organization_setup - Configuración de organizaciones
• report_generation - Generación de reportes

💬 **Ejemplos de uso:**
• "Ejecuta una prueba de análisis de datos"
• "Quiero probar el procesamiento de documentos"
• "Corre la prueba de gestión de roles"
• "Prueba la integración con APIs"

🔧 **Otros comandos:**
• help - Mostrar esta ayuda
• status - Verificar estado del sistema

📝 **Para cambiar el mensaje:**
• Edita el nodo "Simulate Chat Input"
• Modifica la variable "selectedMessage"
• Vuelve a ejecutar el workflow

¡Mensaje actual: "help"!
----------------------------------------
✨ Éxito: false
================================================================================
```

## 🔧 Configuración Avanzada

### Probar Múltiples Mensajes Automáticamente
Puedes modificar el nodo para probar varios mensajes en secuencia:

```javascript
// En el nodo "Simulate Chat Input"
const testMessages = [
  "ejecuta una prueba de análisis de datos",
  "quiero probar el procesamiento de documentos", 
  "help"
];

// Usar timestamp para rotar mensajes
const messageIndex = Math.floor(Date.now() / 10000) % testMessages.length;
const selectedMessage = testMessages[messageIndex];
```

### Simular Diferentes Usuarios
```javascript
// Cambiar usuario para pruebas
const userIds = ['admin_user', 'test_user', 'demo_user'];
const selectedUserId = userIds[Math.floor(Math.random() * userIds.length)];
const userId = selectedUserId;
```

### Agregar Parámetros Personalizados
```javascript
// En el nodo, agregar parámetros específicos
return {
  original_message: selectedMessage,
  clean_message: selectedMessage.toLowerCase().trim(),
  user_id: userId,
  session_id: sessionId,
  timestamp: new Date().toISOString(),
  message_length: selectedMessage.length,
  source: 'n8n_internal',
  // Parámetros adicionales
  custom_params: {
    priority: 'high',
    department: 'testing',
    environment: 'development'
  }
};
```

## 🚨 Troubleshooting

### Error: "OpenAI API not configured"
- **Solución**: Configura las credenciales de OpenAI en el nodo "AI Intent Recognition"

### Error: "Test workflow not responding"
- **Solución**: Verifica que el workflow `[TEST] A01-Task-Orchestrator-Test` esté activo

### Los mensajes no se entienden correctamente
- **Solución**: Ajusta la temperatura del modelo OpenAI (actualmente 0.3)
- **Solución**: Modifica el prompt del sistema en el nodo "AI Intent Recognition"

### Quiero ver más detalles en los logs
- **Solución**: Agrega más `console.log()` en cualquier nodo Function

## 💡 Ventajas del Chatbot Interno

### ✅ Pros
- **Sin configuración externa**: No necesita webhook ni servidor
- **Debug fácil**: Ve todos los pasos en tiempo real
- **Modificación rápida**: Cambia mensajes y vuelve a ejecutar
- **Logs detallados**: Información completa en la consola de N8N
- **Integración nativa**: Aprovecha todas las funciones de N8N

### ⚠️ Consideraciones
- **Ejecución manual**: Requiere hacer clic para ejecutar
- **Un mensaje por vez**: No mantiene conversación continua
- **Dependiente de N8N**: Solo funciona dentro del editor

## 🔄 Workflow de Desarrollo

1. **Modifica** el mensaje en "Simulate Chat Input"
2. **Ejecuta** el workflow
3. **Revisa** los logs y la respuesta
4. **Ajusta** según sea necesario
5. **Repite** para probar diferentes casos

¡Perfecto para desarrollo, testing y debugging de tu sistema de orquestación de tareas!

## 📈 Métricas y Monitoreo

El workflow incluye logs detallados que te permiten:
- **Medir** tiempos de respuesta de IA
- **Validar** interpretación de comandos
- **Debuggear** problemas en tiempo real
- **Optimizar** prompts del sistema

¡Disfruta probando tu orquestador de tareas desde la comodidad de N8N! 🚀