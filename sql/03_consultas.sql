-- ============================================================
-- PROJETO: Academia com avaliação física
-- DISCIPLINA: Laboratório de Banco de Dados
-- ETAPA 1 - A8: Consultas de verificação
-- SGBD: MySQL 8.0+
--
-- 15 consultas, cada uma precedida da pergunta de negócio que
-- responde, organizadas em três blocos:
--   1) Básicas (5)
--   2) Junções e agregação (5)
--   3) Avançadas (5)
-- ============================================================

USE academia_avaliacao;

-- ============================================================
-- BLOCO 1 - BÁSICAS
-- ============================================================

-- Q1: Quais alunos estão com a matrícula ativa, ordenados por nome?
-- (projeção + seleção com WHERE + ordenação)
SELECT
    p.nome,
    a.matricula
FROM aluno a
JOIN pessoa p ON p.id_pessoa = a.id_pessoa
WHERE a.status_matricula = 'ativa'
ORDER BY p.nome ASC;

-- Q2: Quais pessoas têm e-mail cadastrado no domínio "gmail.com"?
-- (uso de LIKE)
SELECT
    nome,
    email
FROM pessoa
WHERE email LIKE '%@gmail.com';

-- Q3: Quais contratos tiveram início entre 01/01/2026 e 31/12/2026?
-- (uso de BETWEEN)
SELECT
    id_contrato,
    id_pessoa_aluno,
    data_inicio,
    data_termino,
    situacao
FROM contrato
WHERE data_inicio BETWEEN '2026-01-01' AND '2026-12-31';

-- Q4: Quais contratos estão em situação "suspenso" ou "cancelado"?
-- (uso de IN)
SELECT
    id_contrato,
    id_pessoa_aluno,
    data_inicio,
    data_termino,
    situacao
FROM contrato
WHERE situacao IN ('suspenso', 'cancelado');

-- Q5: Quais pessoas estão sem telefone ou sem e-mail cadastrado?
-- (tratamento de NULL)
SELECT
    nome,
    COALESCE(telefone, 'não informado') AS telefone,
    COALESCE(email, 'não informado') AS email
FROM pessoa
WHERE telefone IS NULL
   OR email IS NULL;

-- ============================================================
-- BLOCO 2 - JUNÇÕES E AGREGAÇÃO
-- ============================================================

-- Q6: Quais treinos ativos existem, com o nome do aluno e do
-- profissional responsável pela prescrição?
-- (junção com três ou mais tabelas)
SELECT
    t.nome_treino,
    pa.nome AS aluno,
    pp.nome AS profissional
FROM treino t
JOIN aluno a
    ON a.id_pessoa = t.id_pessoa_aluno
JOIN pessoa pa
    ON pa.id_pessoa = a.id_pessoa
JOIN prescricao pc
    ON pc.id_treino = t.id_treino
JOIN profissional pr
    ON pr.id_pessoa = pc.id_pessoa_profissional
JOIN pessoa pp
    ON pp.id_pessoa = pr.id_pessoa
WHERE t.status_treino = 'ativo';

-- Q7: Quem é o supervisor de cada profissional, incluindo os
-- profissionais que não possuem supervisor cadastrado?
-- (LEFT JOIN)
SELECT
    pf.nome AS profissional,
    sup.nome AS supervisor
FROM profissional pr
JOIN pessoa pf         ON pf.id_pessoa = pr.id_pessoa
LEFT JOIN profissional s ON s.id_pessoa = pr.id_supervisor
LEFT JOIN pessoa sup     ON sup.id_pessoa = s.id_pessoa;

-- Q8: Quais alunos possuem mais de uma avaliação física registrada?
-- (GROUP BY + HAVING)
SELECT
    p.nome,
    COUNT(*) AS qtd_avaliacoes
FROM avaliacao_fisica af
JOIN aluno a  ON a.id_pessoa = af.id_pessoa_aluno
JOIN pessoa p ON p.id_pessoa = a.id_pessoa
GROUP BY af.id_pessoa_aluno, p.nome
HAVING COUNT(*) > 1;

-- Q9: Qual o valor mensal médio dos planos vinculados a
-- contratos atualmente ativos?
-- (junção + agregação)
SELECT
    AVG(pl.valor_mensal) AS valor_medio_ativos
FROM contrato c
JOIN plano pl ON pl.id_plano = c.id_plano
WHERE c.situacao = 'ativo';

-- Q10: Quantos exercícios cada treino possui, do maior para o menor?
-- (junção + agregação + ordenação)
SELECT
    t.nome_treino,
    COUNT(*) AS qtd_exercicios
FROM treino_exercicio te
JOIN treino t ON t.id_treino = te.id_treino
GROUP BY te.id_treino, t.nome_treino
ORDER BY qtd_exercicios DESC;

-- ============================================================
-- BLOCO 3 - AVANÇADAS
-- ============================================================

-- Q11: Em qual avaliação cada aluno registrou o seu menor peso
-- histórico?
-- (subconsulta correlacionada)
SELECT
    af.id_pessoa_aluno,
    af.id_avaliacao,
    m.valor_medida AS peso
FROM medida m
JOIN avaliacao_fisica af ON af.id_avaliacao = m.id_avaliacao
WHERE m.tipo_medida = 'peso'
  AND m.valor_medida = (
        SELECT MIN(m2.valor_medida)
        FROM medida m2
        JOIN avaliacao_fisica af2 ON af2.id_avaliacao = m2.id_avaliacao
        WHERE af2.id_pessoa_aluno = af.id_pessoa_aluno
          AND m2.tipo_medida = 'peso'
  );

-- Q12: Quais profissionais já supervisionam pelo menos um outro
-- profissional atualmente?
-- (EXISTS)
SELECT
    p.nome
FROM profissional pr
JOIN pessoa p ON p.id_pessoa = pr.id_pessoa
WHERE EXISTS (
    SELECT 1
    FROM profissional s
    WHERE s.id_supervisor = pr.id_pessoa
);

-- Q13: Quais alunos nunca realizaram nenhuma avaliação física?
-- (NOT EXISTS)
SELECT
    p.nome,
    a.matricula
FROM aluno a
JOIN pessoa p ON p.id_pessoa = a.id_pessoa
WHERE NOT EXISTS (
    SELECT 1
    FROM avaliacao_fisica af
    WHERE af.id_pessoa_aluno = a.id_pessoa
);

-- Q14: Qual aluno teve a maior redução percentual de peso entre a
-- primeira e a última avaliação física registrada?
SELECT
    p.nome,
    pu.peso_inicial,
    pu.peso_final,
    ROUND((pu.peso_inicial - pu.peso_final) / pu.peso_inicial * 100, 2) AS reducao_percentual
FROM (
    SELECT
        id_pessoa_aluno,
        MAX(CASE WHEN ordem_inicial = 1 THEN peso END) AS peso_inicial,
        MAX(CASE WHEN ordem_final   = 1 THEN peso END) AS peso_final
    FROM (
        SELECT
            af.id_pessoa_aluno,
            m.valor_medida AS peso,
            ROW_NUMBER() OVER (PARTITION BY af.id_pessoa_aluno ORDER BY af.data_avaliacao ASC)  AS ordem_inicial,
            ROW_NUMBER() OVER (PARTITION BY af.id_pessoa_aluno ORDER BY af.data_avaliacao DESC) AS ordem_final
        FROM medida m
        JOIN avaliacao_fisica af ON af.id_avaliacao = m.id_avaliacao
        WHERE m.tipo_medida = 'peso'
    ) AS pesos
    GROUP BY id_pessoa_aluno
) AS pu
JOIN aluno a ON a.id_pessoa = pu.id_pessoa_aluno
JOIN pessoa p ON p.id_pessoa = a.id_pessoa
WHERE pu.peso_inicial > pu.peso_final
  AND pu.peso_inicial > 0
ORDER BY reducao_percentual DESC
LIMIT 1;

-- Q15: Para cada aluno, com quantos profissionais diferentes ele
-- já treinou (indício de troca de responsável -- RN18)?
-- (subconsulta correlacionada na cláusula SELECT)
SELECT
    p.nome,
    a.matricula,
    (
        SELECT COUNT(DISTINCT pc.id_pessoa_profissional)
        FROM treino t
        JOIN prescricao pc
            ON pc.id_treino = t.id_treino
        WHERE t.id_pessoa_aluno = a.id_pessoa
    ) AS qtd_profissionais_diferentes
FROM aluno a
JOIN pessoa p
    ON p.id_pessoa = a.id_pessoa;

-- ============================================================
-- FIM DAS CONSULTAS DE VERIFICAÇÃO
-- ============================================================
