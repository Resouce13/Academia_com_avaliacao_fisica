
-- ============================================================
-- B3 - Transações e controle de concorrência
-- Projeto: Academia com avaliação física
-- SGBD: MySQL 8.0+
-- Banco: academia_avaliacao
-- ============================================================

USE academia_avaliacao;

SELECT @@transaction_isolation AS nivel_isolamento,
       @@autocommit AS autocommit,
       @@innodb_lock_wait_timeout AS timeout_espera_s;

-- ============================================================
-- PARTE 1 - Transação com sucesso (COMMIT)
-- Cria um treino, registra a prescrição e associa exercícios.
-- ============================================================

-- Seleciona registros existentes para utilizar no teste.
SELECT MIN(id_pessoa) INTO @id_aluno
FROM aluno;

SELECT MIN(id_pessoa) INTO @id_profissional
FROM profissional;

SELECT id_exercicio INTO @ex1
FROM exercicio ORDER BY id_exercicio LIMIT 0, 1;

SELECT id_exercicio INTO @ex2
FROM exercicio ORDER BY id_exercicio LIMIT 1, 1;

SELECT id_exercicio INTO @ex3
FROM exercicio ORDER BY id_exercicio LIMIT 2, 1;

-- Confira se os IDs foram encontrados antes de continuar.
SELECT @id_aluno AS aluno,
       @id_profissional AS profissional,
       @ex1 AS exercicio1,
       @ex2 AS exercicio2,
       @ex3 AS exercicio3;

START TRANSACTION;

-- 1. Cria o treino.
INSERT INTO treino
    (id_pessoa_aluno, nome_treino, status_treino)
VALUES
    (@id_aluno, 'B3 - Treino OK', 'ativo');

SET @id_treino_ok = LAST_INSERT_ID();

-- 2. Registra o profissional responsável em PRESCRICAO.
INSERT INTO prescricao
    (id_pessoa_profissional, id_treino, data_prescricao, observacoes)
VALUES
    (@id_profissional, @id_treino_ok, CURDATE(),
     'Prescrição criada para o teste B3');

-- 3. Associa os exercícios ao treino.
INSERT INTO treino_exercicio
    (id_treino, id_exercicio, quantidade_series,
     repeticoes, carga, tempo_descanso, ordem_execucao)
VALUES
    (@id_treino_ok, @ex1, 4, 10, 40.00, 60, 1),
    (@id_treino_ok, @ex2, 4, 12, 50.00, 90, 2),
    (@id_treino_ok, @ex3, 3, 12, 35.00, 60, 3);

-- Conferência antes do COMMIT.
SELECT t.id_treino,
       t.nome_treino,
       p.id_pessoa_profissional,
       p.data_prescricao,
       COUNT(te.id_exercicio) AS qtd_exercicios
FROM treino t
JOIN prescricao p ON p.id_treino = t.id_treino
JOIN treino_exercicio te ON te.id_treino = t.id_treino
WHERE t.id_treino = @id_treino_ok
GROUP BY t.id_treino, t.nome_treino,
         p.id_pessoa_profissional, p.data_prescricao;

COMMIT;

-- Confirma que o treino foi gravado.
SELECT * FROM treino
WHERE id_treino = @id_treino_ok;


-- ============================================================
-- PARTE 2 - Falha provocada e ROLLBACK
-- Repete a ordem de execução 2 para provocar uma violação
-- da restrição UNIQUE de ordem dos exercícios.
-- Execute esta parte separadamente.
-- ============================================================

START TRANSACTION;

INSERT INTO treino
    (id_pessoa_aluno, nome_treino, status_treino)
VALUES
    (@id_aluno, 'B3 - Treino FALHA', 'ativo');

SET @id_treino_falha = LAST_INSERT_ID();

INSERT INTO prescricao
    (id_pessoa_profissional, id_treino, data_prescricao, observacoes)
VALUES
    (@id_profissional, @id_treino_falha, CURDATE(),
     'Teste de rollback');

INSERT INTO treino_exercicio
    (id_treino, id_exercicio, quantidade_series,
     repeticoes, carga, tempo_descanso, ordem_execucao)
VALUES
    (@id_treino_falha, @ex1, 4, 10, 40.00, 60, 1);

INSERT INTO treino_exercicio
    (id_treino, id_exercicio, quantidade_series,
     repeticoes, carga, tempo_descanso, ordem_execucao)
VALUES
    (@id_treino_falha, @ex2, 4, 12, 50.00, 90, 2);

-- ERRO INTENCIONAL:
-- Repete a ordem 2 no mesmo treino.
-- Este INSERT deve falhar se a restrição UNIQUE estiver criada.
INSERT INTO treino_exercicio
    (id_treino, id_exercicio, quantidade_series,
     repeticoes, carga, tempo_descanso, ordem_execucao)
VALUES
    (@id_treino_falha, @ex3, 3, 12, 35.00, 60, 2);

-- APÓS o erro acima, execute este comando manualmente:
ROLLBACK;

-- Evidências: os dados da transação falha não devem existir.
SELECT COUNT(*) AS treinos_falha_gravados
FROM treino
WHERE nome_treino = 'B3 - Treino FALHA';

SELECT COUNT(*) AS prescricoes_falha_gravadas
FROM prescricao
WHERE id_treino = @id_treino_falha;

SELECT COUNT(*) AS exercicios_falha_gravados
FROM treino_exercicio
WHERE id_treino = @id_treino_falha;

-- Resultado esperado nas três consultas: 0.


-- ============================================================
-- PARTE 3 - Concorrência: bloqueio entre duas sessões
-- Use duas conexões independentes com o mesmo banco.
-- Execute cada passo na sessão indicada.
-- ============================================================

-- PASSO 1 - SESSÃO 1
-- Seleciona um contrato existente e guarda a situação original.
SELECT MIN(id_contrato) INTO @id_contrato_teste
FROM contrato;

SELECT situacao INTO @situacao_original
FROM contrato
WHERE id_contrato = @id_contrato_teste;

SELECT @id_contrato_teste AS contrato,
       @situacao_original AS situacao_original;

-- Só continue se existir um contrato.
START TRANSACTION;

UPDATE contrato
SET situacao = 'suspenso'
WHERE id_contrato = @id_contrato_teste;

-- NÃO execute COMMIT ainda.


-- PASSO 2 - SESSÃO 2
-- Copie o ID mostrado pela Sessão 1 e utilize-o abaixo.
-- A atualização deve ficar aguardando a liberação do bloqueio.

SET @id_contrato_teste = 1;
-- Troque 1 pelo ID real mostrado pela Sessão 1.

START TRANSACTION;

UPDATE contrato
SET situacao = 'encerrado'
WHERE id_contrato = @id_contrato_teste;

-- O UPDATE deve aguardar enquanto a Sessão 1 não liberar a linha.


-- PASSO 3 - SESSÃO 1
COMMIT;

-- A atualização da Sessão 2 deverá prosseguir após a liberação.


-- PASSO 4 - SESSÃO 2
COMMIT;

SELECT id_contrato, situacao
FROM contrato
WHERE id_contrato = @id_contrato_teste;


-- PASSO 5 - SESSÃO 1
-- Restaura a situação original depois que a Sessão 2 terminar.
UPDATE contrato
SET situacao = @situacao_original
WHERE id_contrato = @id_contrato_teste;

SELECT id_contrato, situacao
FROM contrato
WHERE id_contrato = @id_contrato_teste;


-- ============================================================
-- FIM DO B3
-- ============================================================
