-- =============================================================================
-- PROJETO IMPRESSORAS 360 - FASE 3: DML (Carga de Dados de Teste)
-- =============================================================================

USE impressoras360;

-- -----------------------------------------------------------------------------
-- 1. CARGA: usuarios (6 registros)
-- -----------------------------------------------------------------------------
INSERT INTO usuarios (nome, email, tipo, departamento) VALUES
('Lucas Silveira', 'lucas.silveira@universidade.edu.br', 'aluno', 'Engenharia Mecânica'),
('Mariana Costa', 'mariana.costa@universidade.edu.br', 'aluno', 'Arquitetura e Urbanismo'),
('Prof. Carlos Mendes', 'carlos.mendes@universidade.edu.br', 'professor', 'Engenharia da Computação'),
('Profa. Beatriz Ramos', 'beatriz.ramos@universidade.edu.br', 'professor', 'Design Industrial'),
('Rodrigo Nogueira', 'rodrigo.tec@universidade.edu.br', 'tecnico', 'Laboratório Maker'),
('Camila Duarte', 'camila.duarte@universidade.edu.br', 'aluno', 'Engenharia Mecatrônica');

-- -----------------------------------------------------------------------------
-- 2. CARGA: maquinas (4 registros)
-- -----------------------------------------------------------------------------
INSERT INTO maquinas (nome, modelo, tipo, status, volume_impressao) VALUES
('Ender-01', 'Creality Ender 3 V2', 'FDM', 'ocupada', '220x220x250 mm'),
('Prusa-01', 'Original Prusa i3 MK3S+', 'FDM', 'disponivel', '250x210x210 mm'),
('Resina-01', 'Elegoo Mars 3 Pro', 'SLA', 'disponivel', '143x89x175 mm'),
('Ender-02', 'Creality Ender 3 S1', 'FDM', 'manutencao', '220x220x270 mm');

-- -----------------------------------------------------------------------------
-- 3. CARGA: materiais (6 registros)
-- -----------------------------------------------------------------------------
INSERT INTO materiais (nome, tipo, cor, quantidade_estoque_g) VALUES
('Filamento PLA Branco', 'PLA', 'Branco', 1850.00),
('Filamento PLA Preto', 'PLA', 'Preto', 450.00),
('Filamento PETG Azul', 'PETG', 'Azul', 1200.00),
('Filamento ABS Cinza', 'ABS', 'Cinza', 800.00),
('Resina Standard Cinza', 'Resina', 'Cinza', 1500.00),
('Filamento PLA Vermelho', 'PLA', 'Vermelho', 2300.00);

-- -----------------------------------------------------------------------------
-- 4. CARGA: pedidos (11 registros cobrindo todos os status)
-- -----------------------------------------------------------------------------
INSERT INTO pedidos (id_usuario, id_maquina, id_material, arquivo_gcode, tempo_estimado_min, peso_estimado_g, status, data_solicitacao, data_inicio, data_fim) VALUES
-- Pedidos Concluídos
(1, 1, 1, 'engrenagem_v1.gcode', 180, 45.50, 'concluido', '2026-10-20 09:30:00', '2026-10-20 10:00:00', '2026-10-20 13:00:00'),
(2, 2, 3, 'maquete_casa_base.gcode', 360, 120.00, 'concluido', '2026-10-21 14:00:00', '2026-10-21 14:30:00', '2026-10-21 20:30:00'),
(3, 3, 5, 'suporte_sensor_iot.gcode', 90, 25.00, 'concluido', '2026-10-22 08:00:00', '2026-10-22 08:30:00', '2026-10-22 10:00:00'),
(6, 1, 6, 'braco_robotico_garra.gcode', 240, 68.00, 'concluido', '2026-10-22 13:15:00', '2026-10-22 13:45:00', '2026-10-22 17:45:00'),

-- Pedido em Andamento (Imprimindo)
(1, 1, 2, 'prototipo_chassi.gcode', 420, 110.00, 'imprimindo', '2026-10-23 08:00:00', '2026-10-23 09:00:00', NULL),

-- Pedidos em Fila (Pendente / Em Espera)
(2, NULL, 1, 'escada_espiral_arq.gcode', 150, 35.00, 'em_espera', '2026-10-23 10:15:00', NULL, NULL),
(4, NULL, 4, 'gabinete_ergonomico.gcode', 300, 95.00, 'em_espera', '2026-10-23 11:00:00', NULL, NULL),
(6, NULL, 6, 'articulacao_coxa.gcode', 210, 52.00, 'pendente', '2026-10-23 13:20:00', NULL, NULL),
(1, NULL, 1, 'painel_display_oled.gcode', 120, 28.00, 'pendente', '2026-10-23 14:00:00', NULL, NULL),

-- Pedidos Cancelados
(2, NULL, 3, 'cobertura_estudo_v1.gcode', 180, 40.00, 'cancelado', '2026-10-19 11:00:00', NULL, NULL),
(6, NULL, 2, 'teste_calibracao_torre.gcode', 60, 15.00, 'cancelado', '2026-10-18 16:30:00', NULL, NULL);
