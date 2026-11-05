-- =============================================================================
-- PROJETO IMPRESSORAS 360 - FASE 4: DQL (Consultas e Extração de Informações)
-- script_consultas.sql
-- =============================================================================

USE impressoras360;

-- -----------------------------------------------------------------------------
-- 1. Quais são todos os pedidos que estão atualmente com o status "Na Fila"?
-- No modelo, a fila compreende os estados aguardando início ('pendente' e 'em_espera').
-- -----------------------------------------------------------------------------
SELECT 
    p.id_pedido,
    p.arquivo_gcode,
    p.tempo_estimado_min,
    p.peso_estimado_g,
    p.status,
    p.data_solicitacao
FROM pedidos p
WHERE p.status IN ('pendente', 'em_espera')
ORDER BY p.data_solicitacao ASC;

-- -----------------------------------------------------------------------------
-- 2. Qual é a quantidade total em estoque do material do tipo "PLA"? (Utilizar SUM)
-- -----------------------------------------------------------------------------
SELECT 
    m.tipo AS tipo_material,
    SUM(m.quantidade_estoque_g) AS total_estoque_gramas
FROM materiais m
WHERE m.tipo = 'PLA'
GROUP BY m.tipo;

-- -----------------------------------------------------------------------------
-- 3. Quais pedidos foram realizados por usuários da categoria "Aluno"? 
-- (Requer JOIN entre Usuário e Pedido)
-- -----------------------------------------------------------------------------
SELECT 
    p.id_pedido,
    u.nome AS nome_aluno,
    u.departamento,
    p.arquivo_gcode,
    p.status,
    p.data_solicitacao
FROM pedidos p
INNER JOIN usuarios u ON p.id_usuario = u.id_usuario
WHERE u.tipo = 'aluno'
ORDER BY p.id_pedido ASC;

-- -----------------------------------------------------------------------------
-- 4. Crie um relatório que mostre o nome do usuário, o nome do arquivo impresso, 
-- a marca/modelo da impressora utilizada e a cor do material gasto.
-- (Requer múltiplos JOINs)
-- -----------------------------------------------------------------------------
SELECT 
    u.nome AS nome_usuario,
    p.arquivo_gcode AS arquivo_impresso,
    m.modelo AS impressora_utilizada,
    mat.cor AS cor_material_gasto,
    p.status AS status_pedido
FROM pedidos p
INNER JOIN usuarios u ON p.id_usuario = u.id_usuario
INNER JOIN maquinas m ON p.id_maquina = m.id_maquina
INNER JOIN materiais mat ON p.id_material = mat.id_material
ORDER BY p.id_pedido ASC;

-- -----------------------------------------------------------------------------
-- 5. Qual é o tempo total estimado de impressão alocado para cada máquina no momento?
-- (Utilizar GROUP BY por máquina)
-- Considera pedidos atrelados às máquinas ('imprimindo' ou alocados).
-- Usa LEFT JOIN para listar todas as máquinas cadastradas, mesmo as sem pedidos ativos.
-- -----------------------------------------------------------------------------
SELECT 
    m.id_maquina,
    m.nome AS nome_maquina,
    m.modelo,
    m.status AS status_maquina,
    COALESCE(SUM(p.tempo_estimado_min), 0) AS tempo_total_alocado_min
FROM maquinas m
LEFT JOIN pedidos p ON m.id_maquina = p.id_maquina AND p.status = 'imprimindo'
GROUP BY 
    m.id_maquina, 
    m.nome, 
    m.modelo, 
    m.status
ORDER BY tempo_total_alocado_min DESC;