# Guía de Importación de Workflows - Agente 02

## Pasos para Inicializar n8n

### 1. Iniciar Docker Desktop
**IMPORTANTE**: Antes de ejecutar n8n, debes iniciar Docker Desktop manualmente:
- Busca "Docker Desktop" en el menú inicio
- Inicia la aplicación y espera a que se cargue completamente
- Verás el icono de Docker en la barra de tareas cuando esté listo

### 2. Ejecutar n8n
Una vez que Docker Desktop esté ejecutándose:
```bash
# Opción A: Usar el script automatizado (RECOMENDADO)
start-n8n.bat

# Opción B: Comando manual
docker-compose up -d
```

### 3. Acceder a n8n
- URL: http://localhost:5678
- Usuario: `admin`
- Contraseña: `admin123`

## Importación de Workflows del Agente 02

### Workflows a Importar (11 archivos)

#### Workflow Principal (Importar PRIMERO)
1. **[A02] Account-Management-Orchestrator.json**
   - Es el orquestador principal que maneja todas las tareas

#### Subworkflows MCP-SUB (Importar en cualquier orden)
2. **[MCP-SUB] A02-CreateLead.json**
3. **[MCP-SUB] A02-UpdateLeadStatus.json**
4. **[MCP-SUB] A02-RegisterSubscription.json**
5. **[MCP-SUB] A02-LogPlatformUsage.json**
6. **[MCP-SUB] A02-GenerateUsageReport.json**
7. **[MCP-SUB] A02-SendUsageReport.json**
8. **[MCP-SUB] A02-CreateSupportTicket.json**
9. **[MCP-SUB] A02-UpdateSupportTicket.json**
10. **[MCP-SUB] A02-EscalateComplaint.json**
11. **[MCP-SUB] A02-ProvideMetricsData.json**

### Proceso de Importación en n8n

1. **Accede a n8n** en http://localhost:5678
2. **Inicia sesión** con admin/admin123
3. **Ve a Settings** (ícono de engranaje)
4. **Selecciona "Import/Export"**
5. **Haz clic en "Import from file"**
6. **Navega a la carpeta** `workflows/`
7. **Selecciona cada archivo** .json uno por uno
8. **Importa cada workflow** individualmente

### Configuración Post-Importación

#### Credenciales Requeridas
Después de importar, necesitarás configurar:

1. **Credenciales de Supabase**:
   - Ve a Credentials > Add credential
   - Selecciona "Supabase"
   - Nombra la credencial: `supabaseCredential`
   - Configura URL y API Keys

2. **Credenciales de OpenAI** (para GenerateUsageReport):
   - Ve a Credentials > Add credential
   - Selecciona "OpenAI"
   - Configura API Key

#### Activación de Workflows
- **Activa SOLO** el workflow principal: `[A02] Account-Management-Orchestrator`
- Los subworkflows deben permanecer **INACTIVOS** (se ejecutan bajo demanda)

### Verificación de Importación Exitosa

✅ **Checklist de Verificación**:
- [ ] 11 workflows importados sin errores
- [ ] Workflow principal activado
- [ ] 10 subworkflows desactivados
- [ ] Credenciales de Supabase configuradas
- [ ] Credenciales de OpenAI configuradas (opcional)
- [ ] Sin errores de validación en ningún workflow

### Troubleshooting

#### Error: "Docker daemon not running"
**Solución**: Inicia Docker Desktop y espera a que esté completamente cargado

#### Error: "Port 5678 already in use"
**Solución**: 
```bash
# Detener procesos en puerto 5678
netstat -ano | findstr :5678
# Terminar proceso por PID si es necesario
```

#### Error: "Workflow execution failed"
**Solución**: Verifica que las credenciales estén configuradas correctamente

### Comandos Útiles

```bash
# Iniciar n8n
start-n8n.bat

# Detener n8n
stop-n8n.bat

# Ver logs en tiempo real
docker-compose logs -f n8n

# Verificar estado de contenedores
docker-compose ps

# Reiniciar completamente
docker-compose down && docker-compose up -d
```

---

**Nota**: Todos los workflows están diseñados para integrarse con la arquitectura de pizarra EPRM SUITE y requieren las tablas de Supabase correctamente configuradas.