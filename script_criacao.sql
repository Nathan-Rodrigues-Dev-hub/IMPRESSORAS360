-- Impressoras 360
-- Modelo lógico do Laboratório de Prototipagem e Impressão 3D
-- Compatibilidade: MySQL 8.0.16+ (CHECK constraints são aplicadas)
--
-- Execute este arquivo uma vez em um cliente MySQL, por exemplo MySQL Workbench.
-- A interface do protótipo usa dados de demonstração no navegador; ela não se
-- conecta a este banco.

CREATE DATABASE IF NOT EXISTS impressoras360
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;

USE impressoras360;

CREATE TABLE IF NOT EXISTS usuarios (
  id_usuario INT NOT NULL AUTO_INCREMENT,
  nome_completo VARCHAR(150) NOT NULL,
  email VARCHAR(254) NOT NULL,
  telefone VARCHAR(25) NOT NULL,
  categoria ENUM('Aluno', 'Professor', 'Cliente Externo') NOT NULL,
  PRIMARY KEY (id_usuario),
  UNIQUE KEY uq_usuarios_email (email)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS maquinas (
  numero_patrimonio VARCHAR(50) NOT NULL,
  marca VARCHAR(80) NOT NULL,
  modelo VARCHAR(100) NOT NULL,
  tecnologia VARCHAR(40) NOT NULL,
  status_operacional ENUM(
    'Disponível',
    'Em Manutenção',
    'Operando',
    'Inativa'
  ) NOT NULL,
  PRIMARY KEY (numero_patrimonio)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS materiais (
  id_material INT NOT NULL AUTO_INCREMENT,
  tipo_polimero VARCHAR(60) NOT NULL,
  cor VARCHAR(50) NOT NULL,
  quantidade_estoque DECIMAL(12, 3) NOT NULL,
  unidade_medida ENUM('g', 'mL') NOT NULL,
  PRIMARY KEY (id_material),
  CONSTRAINT chk_materiais_quantidade_nao_negativa
    CHECK (quantidade_estoque >= 0)
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS pedidos (
  id_pedido INT NOT NULL AUTO_INCREMENT,
  id_usuario INT NOT NULL,
  data_solicitacao DATETIME NOT NULL,
  nome_arquivo_3d VARCHAR(255) NOT NULL,
  tempo_estimado_minutos INT NOT NULL,
  peso_estimado_gramas DECIMAL(12, 3) NOT NULL,
  status_pedido ENUM(
    'Na Fila',
    'Imprimindo',
    'Concluído',
    'Falhou',
    'Cancelado'
  ) NOT NULL,
  numero_patrimonio VARCHAR(50) NULL,
  id_material INT NULL,

  -- Valor derivado para que apenas um pedido em execução use cada máquina.
  -- Para outros estados, NULL permite manter o histórico de vários pedidos.
  numero_patrimonio_em_execucao VARCHAR(50)
    GENERATED ALWAYS AS (
      CASE
        WHEN status_pedido = 'Imprimindo' THEN numero_patrimonio
        ELSE NULL
      END
    ) STORED,

  PRIMARY KEY (id_pedido),
  UNIQUE KEY uq_pedidos_maquina_em_execucao (numero_patrimonio_em_execucao),
  KEY idx_pedidos_usuario_data (id_usuario, data_solicitacao),
  KEY idx_pedidos_status_data (status_pedido, data_solicitacao),
  KEY idx_pedidos_material (id_material),
  CONSTRAINT chk_pedidos_tempo_positivo
    CHECK (tempo_estimado_minutos > 0),
  CONSTRAINT chk_pedidos_peso_estimado_positivo
    CHECK (peso_estimado_gramas > 0),
  CONSTRAINT chk_pedidos_alocacao_ao_imprimir
    CHECK (
      status_pedido <> 'Imprimindo'
      OR (numero_patrimonio IS NOT NULL AND id_material IS NOT NULL)
    ),
  CONSTRAINT fk_pedidos_usuario
    FOREIGN KEY (id_usuario)
    REFERENCES usuarios (id_usuario)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_pedidos_maquina
    FOREIGN KEY (numero_patrimonio)
    REFERENCES maquinas (numero_patrimonio)
    ON UPDATE CASCADE
    ON DELETE RESTRICT,
  CONSTRAINT fk_pedidos_material
    FOREIGN KEY (id_material)
    REFERENCES materiais (id_material)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB;

CREATE TABLE IF NOT EXISTS manutencoes (
  id_manutencao INT NOT NULL AUTO_INCREMENT,
  numero_patrimonio VARCHAR(50) NOT NULL,
  data_manutencao DATETIME NOT NULL,
  tipo_manutencao ENUM('Preventiva', 'Corretiva') NOT NULL,
  descricao_servico TEXT NOT NULL,
  custo DECIMAL(12, 2) NOT NULL,
  PRIMARY KEY (id_manutencao),
  KEY idx_manutencoes_maquina_data (numero_patrimonio, data_manutencao),
  CONSTRAINT chk_manutencoes_custo_nao_negativo
    CHECK (custo >= 0),
  CONSTRAINT fk_manutencoes_maquina
    FOREIGN KEY (numero_patrimonio)
    REFERENCES maquinas (numero_patrimonio)
    ON UPDATE CASCADE
    ON DELETE RESTRICT
) ENGINE = InnoDB;

-- Impede iniciar uma impressão em máquina em manutenção ou inativa.
DELIMITER $$

CREATE TRIGGER trg_pedidos_validar_maquina_insert
BEFORE INSERT ON pedidos
FOR EACH ROW
BEGIN
  DECLARE v_status_operacional VARCHAR(40);

  IF NEW.status_pedido = 'Imprimindo' THEN
    SELECT status_operacional
      INTO v_status_operacional
      FROM maquinas
     WHERE numero_patrimonio = NEW.numero_patrimonio;

    IF v_status_operacional IN ('Em Manutenção', 'Inativa') THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Não é possível iniciar impressão nesta máquina.';
    END IF;
  END IF;
END$$

CREATE TRIGGER trg_pedidos_validar_maquina_update
BEFORE UPDATE ON pedidos
FOR EACH ROW
BEGIN
  DECLARE v_status_operacional VARCHAR(40);

  IF NEW.status_pedido = 'Imprimindo' THEN
    SELECT status_operacional
      INTO v_status_operacional
      FROM maquinas
     WHERE numero_patrimonio = NEW.numero_patrimonio;

    IF v_status_operacional IN ('Em Manutenção', 'Inativa') THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Não é possível iniciar impressão nesta máquina.';
    END IF;
  END IF;
END$$

-- Evita tornar indisponível uma máquina que ainda possui pedido em execução.
CREATE TRIGGER trg_maquinas_validar_status_update
BEFORE UPDATE ON maquinas
FOR EACH ROW
BEGIN
  DECLARE v_pedidos_em_execucao INT DEFAULT 0;

  IF NEW.status_operacional IN ('Em Manutenção', 'Inativa') THEN
    SELECT COUNT(*)
      INTO v_pedidos_em_execucao
      FROM pedidos
     WHERE numero_patrimonio = OLD.numero_patrimonio
       AND status_pedido = 'Imprimindo';

    IF v_pedidos_em_execucao > 0 THEN
      SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
          'Finalize ou interrompa o pedido antes de bloquear esta máquina.';
    END IF;
  END IF;
END$$

DELIMITER ;

-- Observação: peso_estimado_gramas é uma estimativa, não o consumo real.
-- O estoque não é abatido automaticamente; o registro de consumo e conversão
-- entre gramas e mililitros não fazem parte do modelo atual.
