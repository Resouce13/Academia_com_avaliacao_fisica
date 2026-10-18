-- ============================================================
-- PARTE 1 - CONTEXTO E CONFERÊNCIA DO BANCO DE DADOS
-- ============================================================

USE academia_avaliacao;

-- Conferir o banco selecionado
SELECT DATABASE() AS banco_atual;

-- Conferir a versão do MySQL
SELECT VERSION() AS versao_mysql;

-- Conferir se existem alunos, profissionais e exercícios
SELECT COUNT(*) AS total_alunos
FROM aluno;

SELECT COUNT(*) AS total_profissionais
FROM profissional;

SELECT COUNT(*) AS total_exercicios
FROM exercicio;

-- Conferir as tabelas utilizadas na transação
DESCRIBE treino;
DESCRIBE prescricao;
DESCRIBE treino_exercicio;


-- ============================================================
-- PARTE 2 - TRANSAÇÃO BEM-SUCEDIDA (COMMIT)
-- ============================================================

USE academia_avaliacao;

-- Seleciona registros existentes para usar no teste
SET @id_aluno = (SELECT MIN(id_pessoa) FROM aluno);
SET @id_profissional = (
    SELECT MIN(id_pessoa) FROM profissional
);
SET @id_exercicio = (
    SELECT MIN(id_exercicio) FROM exercicio
);

-- Conferir os registros escolhidos
SELECT @id_aluno AS aluno_teste,
       @id_profissional AS profissional_teste,
       @id_exercicio AS exercicio_teste;

START TRANSACTION;

-- 1. Criar o treino
INSERT INTO treino (
    id_pessoa_aluno,
    nome_treino,
    status_treino
)
VALUES (
    @id_aluno,
    'DEMO_APRESENTACAO_COMMIT',
    'ativo'
);

-- Guardar o ID gerado automaticamente
SET @id_treino_demo = LAST_INSERT_ID();

-- 2. Relacionar o profissional ao treino
INSERT INTO prescricao (
    id_pessoa_profissional,
    id_treino,
    data_prescricao,
    observacoes
)
VALUES (
    @id_profissional,
    @id_treino_demo,
    CURDATE(),
    'Teste de transacao para apresentacao'
);

-- 3. Associar um exercício ao treino
INSERT INTO treino_exercicio (
    id_treino,
    id_exercicio,
    quantidade_series,
    repeticoes,
    carga,
    tempo_descanso,
    ordem_execucao
)
VALUES (
    @id_treino_demo,
    @id_exercicio,
    3,
    12,
    10,
    60,
    1
);

-- Conferir o treino criado antes da confirmação
SELECT *
FROM treino
WHERE id_treino = @id_treino_demo;

COMMIT;

-- Conferir os dados confirmados nas tabelas relacionadas
SELECT
    t.id_treino,
    t.nome_treino,
    t.status_treino,
    p.id_pessoa_profissional,
    te.id_exercicio,
    te.quantidade_series,
    te.repeticoes
FROM treino t
INNER JOIN prescricao p
    ON p.id_treino = t.id_treino
INNER JOIN treino_exercicio te
    ON te.id_treino = t.id_treino
WHERE t.nome_treino = 'DEMO_APRESENTACAO_COMMIT';

-- “A operação envolve três tabelas relacionadas. Eu inicio uma transação, insiro o treino, registro sua
-- prescrição e associo um exercício. Só depois de concluir as operações eu executo COMMIT, confirmando as alterações.”


-- ============================================================
-- PARTE 3 - TRANSAÇÃO COM FALHA (ROLLBACK)
-- ============================================================

USE academia_avaliacao;

SET @id_aluno = (SELECT MIN(id_pessoa) FROM aluno);
SET @id_profissional = (
    SELECT MIN(id_pessoa) FROM profissional
);
SET @id_exercicio = (
    SELECT MIN(id_exercicio) FROM exercicio
);

SELECT @id_aluno, @id_profissional, @id_exercicio;

START TRANSACTION;

-- Criar o treino de teste
INSERT INTO treino (
    id_pessoa_aluno,
    nome_treino,
    status_treino
)
VALUES (
    @id_aluno,
    'DEMO_APRESENTACAO_ROLLBACK',
    'ativo'
);

SET @id_treino_falha = LAST_INSERT_ID();

-- Registrar a prescrição
INSERT INTO prescricao (
    id_pessoa_profissional,
    id_treino,
    data_prescricao,
    observacoes
)
VALUES (
    @id_profissional,
    @id_treino_falha,
    CURDATE(),
    'Teste de falha e rollback'
);

-- Primeira associação do exercício
INSERT INTO treino_exercicio (
    id_treino,
    id_exercicio,
    quantidade_series,
    repeticoes,
    carga,
    tempo_descanso,
    ordem_execucao
)
VALUES (
    @id_treino_falha,
    @id_exercicio,
    3,
    12,
    10,
    60,
    1
);

-- Segunda associação do mesmo exercício: provoca a falha
INSERT INTO treino_exercicio (
    id_treino,
    id_exercicio,
    quantidade_series,
    repeticoes,
    carga,
    tempo_descanso,
    ordem_execucao
)
VALUES (
    @id_treino_falha,
    @id_exercicio,
    4,
    10,
    12,
    60,
    2
);

ROLLBACK;

-- Verificar se o treino foi desfeito
SELECT *
FROM treino
WHERE nome_treino = 'DEMO_APRESENTACAO_ROLLBACK';

-- Verificar se a prescrição foi desfeita
SELECT *
FROM prescricao p
INNER JOIN treino t
    ON t.id_treino = p.id_treino
WHERE t.nome_treino = 'DEMO_APRESENTACAO_ROLLBACK';

-- Verificar se as associações de exercícios foram desfeitas
SELECT *
FROM treino_exercicio te
INNER JOIN treino t
    ON t.id_treino = te.id_treino
WHERE t.nome_treino = 'DEMO_APRESENTACAO_ROLLBACK';

-- “A segunda associação viola uma restrição. Como as operações anteriores estavam dentro da mesma
-- transação, eu executo ROLLBACK e verifico que nem o treino nem a prescrição ficaram gravados.”


-- ============================================================
-- PARTE 4 - TESTE DE ATUALIZAÇÃO TRANSACIONAL
-- ============================================================

USE academia_avaliacao;

CREATE TABLE IF NOT EXISTS demo_concorrencia (
    id INT PRIMARY KEY,
    valor INT NOT NULL
) ENGINE = InnoDB;

-- Preparar o valor inicial para o experimento
INSERT INTO demo_concorrencia (id, valor)
VALUES (1, 100)
ON DUPLICATE KEY UPDATE valor = 100;

SELECT * FROM demo_concorrencia;

USE academia_avaliacao;
SELECT CONNECTION_ID();

START TRANSACTION;

UPDATE demo_concorrencia
SET valor = valor + 10
WHERE id = 1;

SELECT * FROM demo_concorrencia WHERE id = 1;

COMMIT;


-- ============================================================
-- PARTE 5 - VERIFICAÇÃO DE ÍNDICES E RESTRIÇÕES
-- ============================================================

SHOW INDEX FROM treino_exercicio;

-- “A tabela treino_exercicio possui uma chave primária composta por id_treino e id_exercicio. Isso
-- impede associar o mesmo exercício duas vezes ao mesmo treino. Também existe uma restrição única para
-- a posição do exercício, evitando duas atividades na mesma ordem dentro de um treino. Além das
-- restrições de integridade, há um índice por exercício para facilitar consultas que procuram onde ele é utilizado.”


-- ============================================================
-- PARTE 6 - DESEMPENHO: EXPLAIN ANTES E DEPOIS DOS ÍNDICES
-- ============================================================

USE academia_avaliacao;

-- Criar uma cópia da tabela de exercícios
CREATE TABLE exercicio_teste LIKE exercicio;

INSERT INTO exercicio_teste
SELECT * FROM exercicio;

-- Remover os índices secundários para simular a consulta antes da indexação
ALTER TABLE exercicio_teste
    DROP INDEX idx_exercicio_grupo,
    DROP INDEX idx_exercicio_grupo_nome;

-- EXPLAIN ANTES dos índices
EXPLAIN
SELECT id_exercicio, nome_exercicio, grupo_muscular
FROM exercicio_teste
WHERE grupo_muscular = 'Peito';
-- type: ALL, key: NULL, rows: 35

-- Criar os índices
CREATE INDEX idx_exercicio_grupo
    ON exercicio_teste (grupo_muscular);

CREATE INDEX idx_exercicio_grupo_nome
    ON exercicio_teste (grupo_muscular, nome_exercicio);

-- EXPLAIN DEPOIS dos índices
EXPLAIN
SELECT id_exercicio, nome_exercicio, grupo_muscular
FROM exercicio_teste
WHERE grupo_muscular = 'Peito';
-- type: ref, key: idx_exercicio_grupo, rows: 62

-- Excluir a tabela temporária de teste
DROP TABLE exercicio_teste;


-- ============================================================
-- PARTE 7 - CONTROLE DE ACESSO POR ROLES
-- ============================================================

-- Ativar o perfil de consulta
SET ROLE role_consulta;

-- Consultar a view autorizada
SELECT * FROM academia_avaliacao.vw_alunos_consulta;

-- Ativar o perfil de funcionário
SET ROLE role_funcionario;

-- Consultar a tabela de exercícios
SELECT * FROM academia_avaliacao.exercicio;

-- “Criamos dois papéis com permissões diferentes e os atribuímos ao mesmo usuário. Com o papel de
-- consulta, ele acessa apenas a view autorizada. Ao ativar o papel de funcionário, passa a poder consultar a
-- tabela de exercícios. Isso demonstra controle de acesso baseado em papéis e o princípio do menor privilégio.”

-- Conferir o usuário conectado
SELECT CURRENT_USER();