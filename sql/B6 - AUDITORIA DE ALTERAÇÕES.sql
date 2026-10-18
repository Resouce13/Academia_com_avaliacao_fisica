
-- ============================================================
-- PROJETO: Academia com avaliação física
-- AUDITORIA DE ALTERAÇÕES
-- SGBD: MySQL 8.0+
-- ============================================================

USE academia_avaliacao;

-- ============================================================
-- 1. TABELA DE AUDITORIA
-- ============================================================

CREATE TABLE IF NOT EXISTS auditoria (
    id_auditoria INT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    tabela_afetada VARCHAR(50) NOT NULL,
    registro_id INT UNSIGNED NOT NULL,
    campo_alterado VARCHAR(50) NOT NULL,
    valor_anterior TEXT,
    valor_posterior TEXT,
    autor VARCHAR(288) NOT NULL,
    data_hora DATETIME NOT NULL DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================
-- 2. REMOVER GATILHOS ANTERIORES, SE EXISTIREM
-- ============================================================

DROP TRIGGER IF EXISTS trg_auditoria_plano;
DROP TRIGGER IF EXISTS trg_auditoria_treino;

-- ============================================================
-- 3. AUDITAR ALTERAÇÕES NOS PLANOS
-- ============================================================

DELIMITER $$

CREATE TRIGGER trg_auditoria_plano
AFTER UPDATE ON plano
FOR EACH ROW
BEGIN
    -- Auditar alteração do valor mensal.
    IF NOT (OLD.valor_mensal <=> NEW.valor_mensal) THEN
        INSERT INTO auditoria (
            tabela_afetada,
            registro_id,
            campo_alterado,
            valor_anterior,
            valor_posterior,
            autor
        )
        VALUES (
            'plano',
            OLD.id_plano,
            'valor_mensal',
            CAST(OLD.valor_mensal AS CHAR),
            CAST(NEW.valor_mensal AS CHAR),
            USER()
        );
    END IF;

    -- Auditar alteração da duração em meses.
    IF NOT (OLD.duracao_meses <=> NEW.duracao_meses) THEN
        INSERT INTO auditoria (
            tabela_afetada,
            registro_id,
            campo_alterado,
            valor_anterior,
            valor_posterior,
            autor
        )
        VALUES (
            'plano',
            OLD.id_plano,
            'duracao_meses',
            CAST(OLD.duracao_meses AS CHAR),
            CAST(NEW.duracao_meses AS CHAR),
            USER()
        );
    END IF;
END$$

-- ============================================================
-- 4. AUDITAR ALTERAÇÕES NO STATUS DOS TREINOS
-- ============================================================

CREATE TRIGGER trg_auditoria_treino
AFTER UPDATE ON treino
FOR EACH ROW
BEGIN
    IF NOT (OLD.status_treino <=> NEW.status_treino) THEN
        INSERT INTO auditoria (
            tabela_afetada,
            registro_id,
            campo_alterado,
            valor_anterior,
            valor_posterior,
            autor
        )
        VALUES (
            'treino',
            OLD.id_treino,
            'status_treino',
            OLD.status_treino,
            NEW.status_treino,
            USER()
        );
    END IF;
END$$

DELIMITER ;

-- ============================================================
-- 5. CONSULTAR O HISTÓRICO DE AUDITORIA
-- ============================================================

SELECT *
FROM auditoria
ORDER BY data_hora DESC, id_auditoria DESC;
