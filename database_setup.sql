-- Configuración de Base de Datos para Chatbot IA y Sistema de Pruebas
-- Ejecutar en Supabase SQL Editor

-- Tabla para logs de ejecución de pruebas (si no existe)
CREATE TABLE IF NOT EXISTS test_execution_logs (
  id SERIAL PRIMARY KEY,
  test_name TEXT NOT NULL,
  test_case TEXT NOT NULL,
  status TEXT NOT NULL CHECK (status IN ('SUCCESS', 'ERROR')),
  task_type TEXT NOT NULL,
  organization_id UUID,
  task_id UUID,
  assigned_agent_id TEXT,
  execution_time_ms INTEGER,
  validation_passed BOOLEAN DEFAULT FALSE,
  error_message TEXT,
  error_type TEXT,
  request_payload JSONB,
  response_data JSONB,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Índices para mejorar performance de consultas
  INDEX idx_test_execution_logs_created_at (created_at DESC),
  INDEX idx_test_execution_logs_test_case (test_case),
  INDEX idx_test_execution_logs_status (status),
  INDEX idx_test_execution_logs_task_id (task_id)
);

-- Tabla para interacciones del chatbot
CREATE TABLE IF NOT EXISTS chatbot_interactions (
  id SERIAL PRIMARY KEY,
  user_id TEXT NOT NULL,
  session_id TEXT NOT NULL,
  original_message TEXT NOT NULL,
  intent TEXT NOT NULL CHECK (intent IN ('test_run', 'help', 'status', 'logs', 'unknown')),
  response_type TEXT NOT NULL CHECK (response_type IN ('test_result', 'help', 'status', 'logs', 'unknown')),
  success BOOLEAN DEFAULT FALSE,
  test_case TEXT,
  task_id UUID,
  response_message TEXT,
  confidence DECIMAL(3,2), -- Confianza del AI (0.00 - 1.00)
  needs_clarification BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Índices para analytics y consultas
  INDEX idx_chatbot_interactions_created_at (created_at DESC),
  INDEX idx_chatbot_interactions_user_id (user_id),
  INDEX idx_chatbot_interactions_session_id (session_id),
  INDEX idx_chatbot_interactions_intent (intent),
  INDEX idx_chatbot_interactions_success (success)
);

-- Tabla para métricas y analytics del chatbot
CREATE TABLE IF NOT EXISTS chatbot_analytics (
  id SERIAL PRIMARY KEY,
  date DATE NOT NULL DEFAULT CURRENT_DATE,
  total_interactions INTEGER DEFAULT 0,
  successful_tests INTEGER DEFAULT 0,
  failed_tests INTEGER DEFAULT 0,
  help_requests INTEGER DEFAULT 0,
  status_requests INTEGER DEFAULT 0,
  logs_requests INTEGER DEFAULT 0,
  unknown_requests INTEGER DEFAULT 0,
  avg_confidence DECIMAL(4,3),
  unique_users INTEGER DEFAULT 0,
  unique_sessions INTEGER DEFAULT 0,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Constraint para evitar duplicados por fecha
  UNIQUE(date),
  INDEX idx_chatbot_analytics_date (date DESC)
);

-- Tabla para configuración del chatbot
CREATE TABLE IF NOT EXISTS chatbot_config (
  id SERIAL PRIMARY KEY,
  config_key TEXT NOT NULL UNIQUE,
  config_value JSONB NOT NULL,
  description TEXT,
  is_active BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- Insertar configuración inicial del chatbot
INSERT INTO chatbot_config (config_key, config_value, description) VALUES
  ('ai_model_settings', 
   '{"model": "gpt-3.5-turbo", "temperature": 0.3, "max_tokens": 500}',
   'Configuración del modelo de IA'),
   
  ('available_test_cases',
   '["default", "document_processing", "api_integration", "workflow_automation", "role_management", "user_creation", "organization_setup", "report_generation"]',
   'Casos de prueba disponibles'),
   
  ('response_templates',
   '{"success_prefix": "✅ **Prueba Ejecutada Exitosamente**", "error_prefix": "❌ **Error en la Prueba**", "help_prefix": "🤖 **Asistente de Pruebas de Orquestador**"}',
   'Plantillas de respuesta del chatbot'),
   
  ('validation_rules',
   '{"min_confidence": 0.7, "max_message_length": 1000, "session_timeout_hours": 24}',
   'Reglas de validación y límites')
ON CONFLICT (config_key) DO NOTHING;

-- Función para actualizar analytics diarios
CREATE OR REPLACE FUNCTION update_daily_chatbot_analytics()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO chatbot_analytics (
    date,
    total_interactions,
    successful_tests,
    failed_tests,
    help_requests,
    status_requests,
    logs_requests,
    unknown_requests,
    avg_confidence,
    unique_users,
    unique_sessions
  )
  SELECT 
    CURRENT_DATE,
    COUNT(*) as total_interactions,
    COUNT(*) FILTER (WHERE intent = 'test_run' AND success = true) as successful_tests,
    COUNT(*) FILTER (WHERE intent = 'test_run' AND success = false) as failed_tests,
    COUNT(*) FILTER (WHERE intent = 'help') as help_requests,
    COUNT(*) FILTER (WHERE intent = 'status') as status_requests,
    COUNT(*) FILTER (WHERE intent = 'logs') as logs_requests,
    COUNT(*) FILTER (WHERE intent = 'unknown') as unknown_requests,
    AVG(confidence) as avg_confidence,
    COUNT(DISTINCT user_id) as unique_users,
    COUNT(DISTINCT session_id) as unique_sessions
  FROM chatbot_interactions 
  WHERE DATE(created_at) = CURRENT_DATE
  ON CONFLICT (date) DO UPDATE SET
    total_interactions = EXCLUDED.total_interactions,
    successful_tests = EXCLUDED.successful_tests,
    failed_tests = EXCLUDED.failed_tests,
    help_requests = EXCLUDED.help_requests,
    status_requests = EXCLUDED.status_requests,
    logs_requests = EXCLUDED.logs_requests,
    unknown_requests = EXCLUDED.unknown_requests,
    avg_confidence = EXCLUDED.avg_confidence,
    unique_users = EXCLUDED.unique_users,
    unique_sessions = EXCLUDED.unique_sessions,
    updated_at = NOW();
    
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger para actualizar analytics automáticamente
CREATE OR REPLACE TRIGGER trigger_update_chatbot_analytics
  AFTER INSERT ON chatbot_interactions
  FOR EACH STATEMENT
  EXECUTE FUNCTION update_daily_chatbot_analytics();

-- Vista para estadísticas rápidas del chatbot
CREATE OR REPLACE VIEW chatbot_stats AS
SELECT 
  DATE(created_at) as date,
  COUNT(*) as total_interactions,
  COUNT(*) FILTER (WHERE intent = 'test_run') as test_requests,
  COUNT(*) FILTER (WHERE intent = 'test_run' AND success = true) as successful_tests,
  COUNT(*) FILTER (WHERE intent = 'help') as help_requests,
  COUNT(*) FILTER (WHERE intent = 'status') as status_requests,
  COUNT(*) FILTER (WHERE intent = 'logs') as logs_requests,
  COUNT(*) FILTER (WHERE intent = 'unknown') as unknown_requests,
  ROUND(AVG(confidence), 3) as avg_confidence,
  COUNT(DISTINCT user_id) as unique_users,
  COUNT(DISTINCT session_id) as unique_sessions
FROM chatbot_interactions 
GROUP BY DATE(created_at)
ORDER BY date DESC;

-- Vista para análisis de pruebas exitosas vs fallidas
CREATE OR REPLACE VIEW test_success_analysis AS
SELECT 
  t.test_case,
  COUNT(*) as total_tests,
  COUNT(*) FILTER (WHERE t.status = 'SUCCESS') as successful_tests,
  COUNT(*) FILTER (WHERE t.status = 'ERROR') as failed_tests,
  ROUND(
    (COUNT(*) FILTER (WHERE t.status = 'SUCCESS')::DECIMAL / COUNT(*)) * 100, 
    2
  ) as success_rate,
  AVG(t.execution_time_ms) as avg_execution_time_ms,
  COUNT(DISTINCT c.user_id) as triggered_by_chatbot_users
FROM test_execution_logs t
LEFT JOIN chatbot_interactions c ON t.task_id = c.task_id
GROUP BY t.test_case
ORDER BY success_rate DESC;

-- Comentarios para documentación
COMMENT ON TABLE test_execution_logs IS 'Registro de todas las ejecuciones de pruebas del orquestador';
COMMENT ON TABLE chatbot_interactions IS 'Registro de todas las interacciones con el chatbot IA';
COMMENT ON TABLE chatbot_analytics IS 'Métricas diarias agregadas del chatbot';
COMMENT ON TABLE chatbot_config IS 'Configuración del comportamiento del chatbot';

COMMENT ON COLUMN chatbot_interactions.confidence IS 'Nivel de confianza del AI en la interpretación (0.00-1.00)';
COMMENT ON COLUMN chatbot_interactions.needs_clarification IS 'Indica si la solicitud requiere aclaración del usuario';

-- Políticas de Row Level Security (RLS) si es necesario
-- ALTER TABLE chatbot_interactions ENABLE ROW LEVEL SECURITY;
-- ALTER TABLE test_execution_logs ENABLE ROW LEVEL SECURITY;

-- Ejemplo de política para limitar acceso por usuario
-- CREATE POLICY chatbot_interactions_user_policy ON chatbot_interactions
--   FOR ALL USING (user_id = auth.jwt() ->> 'sub');

-- Función para limpiar datos antiguos (opcional)
CREATE OR REPLACE FUNCTION cleanup_old_chatbot_data(days_to_keep INTEGER DEFAULT 90)
RETURNS INTEGER AS $$
DECLARE
  deleted_count INTEGER;
BEGIN
  DELETE FROM chatbot_interactions 
  WHERE created_at < NOW() - INTERVAL '1 day' * days_to_keep;
  
  GET DIAGNOSTICS deleted_count = ROW_COUNT;
  
  DELETE FROM test_execution_logs 
  WHERE created_at < NOW() - INTERVAL '1 day' * days_to_keep;
  
  RETURN deleted_count;
END;
$$ LANGUAGE plpgsql;

-- Para ejecutar limpieza mensual (ejemplo)
-- SELECT cleanup_old_chatbot_data(90); -- Mantener últimos 90 días

COMMIT;