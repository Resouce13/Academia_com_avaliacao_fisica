
-- ============================================================
-- PROJETO: Academia com avaliação física
-- CONTROLE DE ACESSO E SEGURANÇA
-- SGBD: MySQL 8.0+
-- Banco: academia_avaliacao
-- ============================================================

USE academia_avaliacao;

SELECT DATABASE();
SELECT VERSION();

-- ============================================================
-- 1. CRIAR USUÁRIOS DO MYSQL
-- ============================================================

CREATE USER IF NOT EXISTS 'academia_admin'@'localhost'
IDENTIFIED BY 'Admin_Troque_2026@';

CREATE USER IF NOT EXISTS 'academia_funcionario'@'localhost'
IDENTIFIED BY 'Func_Troque_2026@';

CREATE USER IF NOT EXISTS 'academia_consulta'@'localhost'
IDENTIFIED BY 'Consulta_Troque_2026@';

-- ============================================================
-- 2. CONCEDER PERMISSÕES
-- ============================================================

-- Administrador: acesso completo ao banco do projeto.
GRANT ALL PRIVILEGES
ON academia_avaliacao.*
TO 'academia_admin'@'localhost';

-- Funcionário: consultar, cadastrar e alterar registros.
GRANT SELECT, INSERT, UPDATE
ON academia_avaliacao.*
TO 'academia_funcionario'@'localhost';

-- ============================================================
-- 3. DEMONSTRAR O REVOKE
-- ============================================================

-- Retira a permissão de alteração do funcionário.
-- Ao final, ele poderá consultar e cadastrar registros,
-- mas não poderá alterar registros existentes.
REVOKE UPDATE
ON academia_avaliacao.*
FROM 'academia_funcionario'@'localhost';

-- ============================================================
-- 4. CRIAR VIEW COM DADOS LIMITADOS
-- ============================================================

CREATE OR REPLACE VIEW vw_alunos_consulta AS
SELECT
    p.id_pessoa,
    p.nome,
    a.matricula,
    a.status_matricula
FROM pessoa p
INNER JOIN aluno a
    ON a.id_pessoa = p.id_pessoa;

-- Permitir que o usuário de consulta veja somente essa VIEW.
GRANT SELECT
ON academia_avaliacao.vw_alunos_consulta
TO 'academia_consulta'@'localhost';

-- ============================================================
-- 5. TABELA DE USUÁRIOS DA APLICAÇÃO
-- ============================================================

CREATE TABLE IF NOT EXISTS usuario_aplicacao (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    nome_usuario VARCHAR(50) NOT NULL UNIQUE,
    senha_hash VARCHAR(255) NOT NULL,
    senha_salt VARCHAR(100) NOT NULL,
    iteracoes INT NOT NULL DEFAULT 600000,
    perfil ENUM(
        'ADMIN',
        'FUNCIONARIO',
        'CONSULTA'
    ) NOT NULL,
    ativo BOOLEAN NOT NULL DEFAULT TRUE,
    criado_em TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB;

-- ============================================================
-- 6. CONSULTAR USUÁRIO DE TESTE SEM EXIBIR SEGREDOS
-- ============================================================

SELECT
    id_usuario,
    nome_usuario,
    perfil,
    ativo,
    iteracoes,
    criado_em
FROM usuario_aplicacao
WHERE nome_usuario = 'usuario_teste_b5';

-- ============================================================
-- 7. VERIFICAR AS PERMISSÕES
-- ============================================================

SHOW GRANTS FOR 'academia_admin'@'localhost';

SHOW GRANTS FOR 'academia_funcionario'@'localhost';

SHOW GRANTS FOR 'academia_consulta'@'localhost';

-- Opcional: executar se essa conta existir no servidor.
SHOW GRANTS FOR 'root'@'localhost';
