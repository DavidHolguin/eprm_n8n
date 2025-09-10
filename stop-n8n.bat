@echo off
echo ====================================
echo    Deteniendo n8n EPRM SUITE
echo ====================================
echo.

echo Deteniendo contenedores...
docker-compose down

echo.
echo n8n ha sido detenido exitosamente.
echo Para reiniciar, ejecuta: start-n8n.bat
echo.
pause