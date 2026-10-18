
-- ============================================================
-- B4 - Otimizacao de consultas
-- SGBD: MySQL 8.0.18+
-- Banco: academia_avaliacao
-- ============================================================

USE academia_avaliacao;

-- ============================================================
-- PASSO 0 - Carga de volume
-- Execute esta carga apenas uma vez em uma base preparada
-- para testes. Os IDs utilizados devem estar livres.
--
-- Volumes planejados:
-- 50.000 pessoas/alunos
-- 490 exercicios extras
-- 200.000 treinos e prescricoes
-- 1.000.000 linhas em treino_exercicio
-- 100.000 contratos
-- ============================================================

SET SESSION cte_max_recursion_depth = 1000000;

-- ------------------------------------------------------------
-- 0.1 - PESSOA: 50.000 registros
-- ------------------------------------------------------------

INSERT INTO pessoa
    (id_pessoa, nome, cpf, data_nascimento,
     rua, numero, bairro, cidade, uf, cep)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 50000
)
SELECT
    10000 + n,
    CONCAT('Aluno Teste ', n),
    CAST(10000000000 + n AS CHAR),
    DATE_ADD('1970-01-01', INTERVAL (n MOD 12000) DAY),
    'Rua Teste', '1', 'Centro', 'Brasilia', 'DF', '70000000'
FROM seq;

-- ------------------------------------------------------------
-- 0.2 - ALUNO: somente os 50.000 registros gerados acima
-- ------------------------------------------------------------

INSERT INTO aluno
    (id_pessoa, matricula, status_matricula)
SELECT
    id_pessoa,
    CONCAT('T', LPAD(id_pessoa - 10000, 7, '0')),
    ELT(
        1 + (id_pessoa MOD 4),
        'ativa', 'inativa', 'suspensa', 'cancelada'
    )
FROM pessoa
WHERE id_pessoa BETWEEN 10001 AND 60000;

-- ------------------------------------------------------------
-- 0.3 - EXERCICIO: 490 registros adicionais
-- ------------------------------------------------------------

INSERT INTO exercicio
    (id_exercicio, nome_exercicio, grupo_muscular)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 490
)
SELECT
    1000 + n,
    CONCAT('Exercicio Teste ', n),
    ELT(
        1 + (n MOD 8),
        'Peito', 'Costas', 'Pernas', 'Ombro',
        'Biceps', 'Triceps', 'Abdomen', 'Gluteos'
    )
FROM seq;

-- ------------------------------------------------------------
-- 0.4 - TREINO: 200.000 registros
-- Modelo atualizado: sem id_profissional e data_prescricao.
-- ------------------------------------------------------------

INSERT INTO treino
    (id_treino, id_pessoa_aluno, nome_treino, status_treino)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 200000
)
SELECT
    10000 + n,
    10001 + (n MOD 50000),
    CONCAT('Treino Teste ', n),
    ELT(
        1 + (n MOD 3),
        'ativo', 'encerrado', 'substituido'
    )
FROM seq;

-- ------------------------------------------------------------
-- 0.5 - PRESCRICAO: 200.000 registros
-- Usa um profissional existente para todas as prescricoes.
-- A data fica na tabela PRESCRICAO, conforme o modelo atual.
-- ------------------------------------------------------------

INSERT INTO prescricao
    (id_pessoa_profissional, id_treino,
     data_prescricao, observacoes)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 200000
)
SELECT
    prof.id_pessoa,
    10000 + seq.n,
    DATE_ADD('2024-01-01', INTERVAL (seq.n MOD 700) DAY),
    'Prescricao gerada para teste de desempenho'
FROM seq
CROSS JOIN (
    SELECT MIN(id_pessoa) AS id_pessoa
    FROM profissional
) AS prof;

-- ------------------------------------------------------------
-- 0.6 - TREINO_EXERCICIO: 1.000.000 registros
-- Cinco exercicios por treino.
-- ------------------------------------------------------------

INSERT INTO treino_exercicio
    (id_treino, id_exercicio, quantidade_series,
     repeticoes, carga, tempo_descanso, ordem_execucao)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 1000000
)
SELECT
    10001 + ((n - 1) DIV 5),
    1001 + (
        (((n - 1) DIV 5) * 7 + ((n - 1) MOD 5) * 13)
        MOD 490
    ),
    3,
    10,
    10 + (n MOD 40),
    60,
    1 + ((n - 1) MOD 5)
FROM seq;

-- ------------------------------------------------------------
-- 0.7 - CONTRATO: 100.000 registros
-- Pressupoe que existam planos com IDs 1, 2 e 3.
-- ------------------------------------------------------------

INSERT INTO contrato
    (id_contrato, id_pessoa_aluno, id_plano,
     data_inicio, data_termino, situacao)
WITH RECURSIVE seq AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1 FROM seq WHERE n < 100000
)
SELECT
    10000 + n,
    10001 + (n MOD 50000),
    1 + (n MOD 3),
    DATE_ADD('2024-01-01', INTERVAL (n MOD 1000) DAY),
    DATE_ADD('2024-01-31', INTERVAL (n MOD 1000) DAY),
    ELT(
        1 + (n MOD 4),
        'ativo', 'encerrado', 'suspenso', 'cancelado'
    )
FROM seq;

-- ------------------------------------------------------------
-- 0.8 - Atualizar estatisticas e conferir volumes
-- ------------------------------------------------------------

ANALYZE TABLE
    pessoa, aluno, profissional, exercicio,
    treino, prescricao, treino_exercicio, contrato;

SELECT 'pessoa' AS tabela, COUNT(*) AS linhas FROM pessoa
UNION ALL
SELECT 'aluno', COUNT(*) FROM aluno
UNION ALL
SELECT 'profissional', COUNT(*) FROM profissional
UNION ALL
SELECT 'exercicio', COUNT(*) FROM exercicio
UNION ALL
SELECT 'treino', COUNT(*) FROM treino
UNION ALL
SELECT 'prescricao', COUNT(*) FROM prescricao
UNION ALL
SELECT 'treino_exercicio', COUNT(*) FROM treino_exercicio
UNION ALL
SELECT 'contrato', COUNT(*) FROM contrato;

-- ============================================================
-- CONSULTA 1 - Alunos por matricula
-- JOIN + LEFT JOIN + COUNT + GROUP BY
-- ============================================================

-- Plano antes da intervencao.
EXPLAIN
SELECT
    p.id_pessoa,
    p.nome AS aluno,
    a.matricula,
    COUNT(t.id_treino) AS quantidade_treinos
FROM aluno a
JOIN pessoa p ON p.id_pessoa = a.id_pessoa
LEFT JOIN treino t ON t.id_pessoa_aluno = a.id_pessoa
WHERE a.matricula = 'T0025000'
GROUP BY p.id_pessoa, p.nome, a.matricula
ORDER BY p.nome;

EXPLAIN ANALYZE
SELECT
    p.id_pessoa,
    p.nome AS aluno,
    a.matricula,
    COUNT(t.id_treino) AS quantidade_treinos
FROM aluno a
JOIN pessoa p ON p.id_pessoa = a.id_pessoa
LEFT JOIN treino t ON t.id_pessoa_aluno = a.id_pessoa
WHERE a.matricula = 'T0025000'
GROUP BY p.id_pessoa, p.nome, a.matricula
ORDER BY p.nome;

-- Intervencao: indice para a ligacao treino-aluno.
CREATE INDEX idx_treino_aluno_id
    ON treino (id_pessoa_aluno, id_treino);

-- Plano depois da intervencao.
EXPLAIN ANALYZE
SELECT
    p.id_pessoa,
    p.nome AS aluno,
    a.matricula,
    COUNT(t.id_treino) AS quantidade_treinos
FROM aluno a
JOIN pessoa p ON p.id_pessoa = a.id_pessoa
LEFT JOIN treino t ON t.id_pessoa_aluno = a.id_pessoa
WHERE a.matricula = 'T0025000'
GROUP BY p.id_pessoa, p.nome, a.matricula
ORDER BY p.nome;

-- Remova o indice se os testes indicarem que nao compensa.
DROP INDEX idx_treino_aluno_id ON treino;

-- ============================================================
-- CONSULTA 2 - Exercicios por grupo muscular
-- ============================================================

EXPLAIN
SELECT
    e.nome_exercicio,
    e.grupo_muscular,
    COUNT(te.id_treino) AS quantidade_treinos
FROM exercicio e
JOIN treino_exercicio te ON te.id_exercicio = e.id_exercicio
WHERE e.grupo_muscular = 'Pernas'
GROUP BY e.id_exercicio, e.nome_exercicio, e.grupo_muscular
ORDER BY e.nome_exercicio;

EXPLAIN ANALYZE
SELECT
    e.nome_exercicio,
    e.grupo_muscular,
    COUNT(te.id_treino) AS quantidade_treinos
FROM exercicio e
JOIN treino_exercicio te ON te.id_exercicio = e.id_exercicio
WHERE e.grupo_muscular = 'Pernas'
GROUP BY e.id_exercicio, e.nome_exercicio, e.grupo_muscular
ORDER BY e.nome_exercicio;

-- Intervencao: filtro pelo grupo e ordenacao pelo nome.
CREATE INDEX idx_exercicio_grupo_nome
    ON exercicio (grupo_muscular, nome_exercicio);

EXPLAIN ANALYZE
SELECT
    e.nome_exercicio,
    e.grupo_muscular,
    COUNT(te.id_treino) AS quantidade_treinos
FROM exercicio e
JOIN treino_exercicio te ON te.id_exercicio = e.id_exercicio
WHERE e.grupo_muscular = 'Pernas'
GROUP BY e.id_exercicio, e.nome_exercicio, e.grupo_muscular
ORDER BY e.nome_exercicio;

-- Mantenha o indice se houver beneficio medido.
-- Caso contrario, execute:
-- DROP INDEX idx_exercicio_grupo_nome ON exercicio;

-- ============================================================
-- CONSULTA 3 - Contratos por periodo e situacao
-- ============================================================

EXPLAIN
SELECT
    situacao,
    COUNT(*) AS qtd,
    AVG(DATEDIFF(data_termino, data_inicio)) AS media_dias
FROM contrato
WHERE data_inicio BETWEEN '2025-03-01' AND '2025-03-31'
GROUP BY situacao;

EXPLAIN ANALYZE
SELECT
    situacao,
    COUNT(*) AS qtd,
    AVG(DATEDIFF(data_termino, data_inicio)) AS media_dias
FROM contrato
WHERE data_inicio BETWEEN '2025-03-01' AND '2025-03-31'
GROUP BY situacao;

-- Intervencao: indice que inclui os campos utilizados
-- no filtro e no calculo da duracao.
CREATE INDEX idx_contrato_inicio_situacao_termino
    ON contrato (data_inicio, situacao, data_termino);

EXPLAIN ANALYZE
SELECT
    situacao,
    COUNT(*) AS qtd,
    AVG(DATEDIFF(data_termino, data_inicio)) AS media_dias
FROM contrato
WHERE data_inicio BETWEEN '2025-03-01' AND '2025-03-31'
GROUP BY situacao;

-- Contraste: periodo amplo, que pode reduzir a vantagem
-- de utilizar o indice.
EXPLAIN
SELECT
    situacao,
    COUNT(*) AS qtd,
    AVG(DATEDIFF(data_termino, data_inicio)) AS media_dias
FROM contrato
WHERE data_inicio BETWEEN '2024-01-01' AND '2026-12-31'
GROUP BY situacao;

-- ============================================================
-- CONFERENCIA DOS INDICES
-- ============================================================

SHOW INDEX FROM treino;
SHOW INDEX FROM exercicio;
SHOW INDEX FROM contrato;

-- ============================================================
-- FIM DO B4
-- ============================================================
