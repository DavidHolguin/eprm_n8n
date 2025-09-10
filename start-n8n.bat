@echo off
echo ====================================
echo    Iniciando n8n para EPRM SUITE
echo ====================================
echo.

echo [1/3] Verificando Docker Desktop...
docker --version >nul 2>&1
if errorlevel 1 (
    echo ERROR: Docker no está instalado o no está en el PATH
    pause
    exit /b 1
)

echo [2/3] Iniciando servicios con docker-compose...
docker-compose up -d

if errorlevel 1 (
    echo.
    echo ERROR: No se pudo iniciar n8n. Posibles causas:
    echo - Docker Desktop no está ejecutándose
    echo - Puerto 5678 ya está en uso
    echo - Problema con la configuración
    echo.
    echo SOLUCION: 
    echo 1. Inicia Docker Desktop manualmente
    echo 2. Espera a que esté completamente cargado
    echo 3. Ejecuta este script nuevamente
    echo.
    pause
    exit /b 1
)

echo [3/3] Esperando que n8n esté listo...
timeout /t 10 /nobreak >nul

echo.
echo ====================================
echo       n8n INICIADO EXITOSAMENTE
echo ====================================
echo.
echo Accede a n8n en: http://localhost:5678
echo Usuario: admin
echo Contraseña: admin123
echo.
echo Para importar los workflows del Agente 02:
echo 1. Ve a Settings ^> Import/Export
echo 2. Selecciona "Import from file"
echo 3. Navega a la carpeta: workflows/
echo 4. Importa cada archivo .json individualmente
echo.
echo Total de workflows a importar: 11
echo - 1 Workflow principal: [A02] Account-Management-Orchestrator
echo - 10 Subworkflows MCP-SUB
echo.
echo Para detener n8n: ejecuta stop-n8n.bat
echo.
pause