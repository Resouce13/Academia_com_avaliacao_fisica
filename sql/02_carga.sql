-- ============================================================
-- PROJETO: Academia com avaliação física
-- DISCIPLINA: Laboratório de Banco de Dados
-- ETAPA 1 - A7: DML (carga de dados)
-- SGBD: MySQL 8.0+
--
-- Observações:
-- * Dados fictícios. Nenhum dado pessoal real de terceiros foi utilizado.
-- * Ordem de inserção respeita as dependências de FK:
--   pessoa -> aluno/profissional -> plano -> contrato ->
--   avaliacao_fisica -> medida -> treino -> exercicio ->
--   treino_exercicio.
-- * Casos de contorno propositais estão sinalizados nos
--   comentários (-- [CONTORNO]).
-- ============================================================

USE academia_avaliacao;

-- ------------------------------------------------------------
-- PESSOA
-- ------------------------------------------------------------
INSERT INTO pessoa
    (id_pessoa, nome, cpf, data_nascimento, telefone, email, rua, numero, bairro, cidade, uf, cep)
VALUES
    (1, 'Carlos Eduardo Ramos Silva', '10020030041', '1985-04-12', '61988001122', 'carlos.ramos@academiafit.com',
        'Quadra 12 Conjunto 4', '120', 'Águas Claras', 'Brasília', 'DF', '71950120'),
    (2, 'Beatriz Fontoura Lima', '20030040051', '1997-11-03', '61988002233', 'beatriz.lima@academiafit.com',
        'Rua das Palmeiras', '45', 'Taguatinga', 'Brasília', 'DF', '72010050'),
    (3, 'João Pedro Andrade Souza', '30040050061', '1999-02-20', '61988003344', 'joaopedro.souza@gmail.com',
        'Avenida das Nações', '300', 'Asa Sul', 'Brasília', 'DF', '70200030'),
    (4, 'Fernanda Costa Martins', '40050060071', '1993-07-08', NULL, 'fernanda.martins@gmail.com',
        -- [CONTORNO] telefone em branco (atributo opcional)
        'Rua 24 de Maio', '78', 'Ceilândia', 'Brasília', 'DF', '72220080'),
    (5, 'Ricardo Nunes Barbosa', '50060070081', '1988-12-30', '61988005566', 'ricardo.barbosa@hotmail.com',
        'Rua do Comércio', '15', 'Gama', 'Brasília', 'DF', '72400090'),
    (6, 'Marina Alves Teixeira', '60070080091', '1990-05-17', '61988006677', 'marina.teixeira@academiafit.com',
        'Quadra 8 Bloco B', '210', 'Sobradinho', 'Brasília', 'DF', '73020060'),
    (7, 'Helena Prado Duarte', '70080090011', '2001-09-25', NULL, NULL,
        -- [CONTORNO] telefone E email em branco (dois opcionais na mesma linha)
        'Rua das Acácias', '9', 'Guará', 'Brasília', 'DF', '71020030');

-- ------------------------------------------------------------
-- PROFISSIONAL (Carlos é o supervisor sênior; Beatriz e Marina
-- são supervisionadas por ele -> RN19/RN20)
-- ------------------------------------------------------------
INSERT INTO profissional (id_pessoa, registro_profissional, especialidade, id_supervisor)
VALUES
    (1, 'CREF012345GDF', 'Musculação e Hipertrofia', NULL),
    -- [CONTORNO] id_supervisor NULL: profissional sênior, sem supervisor
    (2, 'CREF067890GDF', 'Treinamento Funcional', 1),
    (6, 'CREF054321GDF', 'Avaliação Física', 1);
    -- Marina (id_pessoa 6) também é aluna (ver ALUNO abaixo) --
    -- caso de sobreposição da especialização (Pessoa parcial e sobreposta)

-- ------------------------------------------------------------
-- ALUNO
-- ------------------------------------------------------------
INSERT INTO aluno (id_pessoa, matricula, status_matricula)
VALUES
    (3, '2025ALU0001', 'ativa'),
    (4, '2025ALU0002', 'ativa'),
    (5, '2024ALU0003', 'cancelada'),
    -- [CONTORNO] matrícula cancelada (situação "fechada")
    (6, '2026ALU0004', 'ativa'),
    (7, '2026ALU0005', 'suspensa');
    -- [CONTORNO] matrícula suspensa (situação em aberto)

-- ------------------------------------------------------------
-- PLANO
-- ------------------------------------------------------------
INSERT INTO plano (id_plano, nome_plano, valor_mensal, duracao_meses)
VALUES
    (1, 'Plano Mensal', 150.00, 1),
    (2, 'Plano Trimestral', 400.00, 3),
    (3, 'Plano Anual', 1200.00, 12);

-- ------------------------------------------------------------
-- CONTRATO (João Pedro possui histórico: um contrato encerrado
-- seguido de um contrato ativo -> RN04)
-- ------------------------------------------------------------
INSERT INTO contrato
    (id_contrato, id_pessoa_aluno, id_plano, data_inicio, data_termino, situacao, duracao_dias)
VALUES
    (1, 3, 1, '2025-03-01', '2025-03-31', 'encerrado', 30),
    (2, 3, 3, '2025-04-01', '2026-04-01', 'ativo', 365),
    -- [HISTÓRICO] mesmo aluno (id_pessoa_aluno = 3) com 2 contratos ao longo do tempo
    (3, 4, 2, '2026-07-01', '2026-09-29', 'ativo', 90),
    (4, 5, 1, '2024-05-01', '2024-05-31', 'cancelado', 30),
    -- [CONTORNO] situação "cancelado" (fechada)
    (5, 6, 2, '2026-06-15', '2026-09-13', 'suspenso', 90),
    -- [CONTORNO] situação "suspenso" (em aberto)
    (6, 7, 1, '2026-09-01', '2026-10-01', 'ativo', 30);

-- ------------------------------------------------------------
-- AVALIACAO_FISICA (João Pedro possui 3 avaliações ao longo do
-- tempo, permitindo observar evolução -> RN09)
-- ------------------------------------------------------------
INSERT INTO avaliacao_fisica (id_avaliacao, id_pessoa_aluno, data_avaliacao, observacoes)
VALUES
    (1, 3, '2025-03-05', 'Avaliação inicial de ingresso na academia.'),
    (2, 3, '2025-09-10', NULL),
    -- [CONTORNO] observações em branco (atributo opcional)
    (3, 3, '2026-03-15', 'Evolução positiva, redução de percentual de gordura.'),
    (4, 4, '2026-07-05', 'Primeira avaliação após início do plano trimestral.'),
    (5, 6, '2026-06-20', NULL);

-- ------------------------------------------------------------
-- MEDIDA (chave composta id_avaliacao + tipo_medida; nem toda
-- avaliação repete todos os tipos de medida -> RN10/RN11)
-- ------------------------------------------------------------
INSERT INTO medida (id_avaliacao, tipo_medida, valor_medida, unidade)
VALUES
    (1, 'peso', 82.50, 'kg'),
    (1, 'altura', 1.78,  'm'),
    (1, 'cintura', 92.00, 'cm'),
    (1, 'braco', 33.00, 'cm'),

    (2, 'peso', 79.80, 'kg'),
    (2, 'cintura', 88.50, 'cm'),
    (2, 'braco', 34.00, 'cm'),
    -- [CONTORNO] avaliação 2 não repete 'altura' (não muda com frequência)

    (3, 'peso', 77.20, 'kg'),
    (3, 'altura', 1.78,  'm'),
    (3, 'cintura', 85.00, 'cm'),
    (3, 'braco', 35.50, 'cm'),

    (4, 'peso', 65.00, 'kg'),
    (4, 'altura', 1.65,  'm'),
    (4, 'cintura', 74.00, 'cm'),
    (4, 'braco', 28.00, 'cm'),

    (5, 'peso', 58.50, 'kg'),
    (5, 'altura', 1.60,  'm'),
    (5, 'cintura', 68.00, 'cm');
    -- [CONTORNO] avaliação 5 não possui medida de 'braco'

-- ------------------------------------------------------------
-- TREINO (João Pedro tem um treino substituído e um novo,
-- inclusive com troca do profissional responsável -> RN17/RN18)
-- ------------------------------------------------------------
INSERT INTO treino
    (id_treino, id_pessoa_aluno, id_pessoa_profissional, data_prescricao, nome_treino, status_treino)
VALUES
    (1, 3, 1, '2025-03-06', 'Treino Full Body - Iniciante', 'substituido'),
    (2, 3, 2, '2025-09-12', 'Treino ABC - Hipertrofia', 'ativo'),
    -- [HISTÓRICO] treino 1 (Carlos) substituído pelo treino 2 (Beatriz) para o mesmo aluno
    (3, 4, 1, '2026-07-06', 'Treino Funcional - Emagrecimento', 'ativo'),
    (4, 6, 1, '2026-06-21', 'Treino de Mobilidade', 'ativo'),
    (5, 7, 2, '2026-09-02', 'Treino Iniciante - Adaptação', 'ativo');

-- ------------------------------------------------------------
-- EXERCICIO
-- ------------------------------------------------------------
INSERT INTO exercicio (id_exercicio, nome_exercicio, grupo_muscular)
VALUES
    (1,  'Supino Reto', 'Peito'),
    (2,  'Agachamento Livre', 'Pernas'),
    (3,  'Puxada Frontal', 'Costas'),
    (4,  'Rosca Direta', 'Bíceps'),
    (5,  'Tríceps Corda', 'Tríceps'),
    (6,  'Desenvolvimento Militar', 'Ombro'),
    (7,  'Abdominal Supra', 'Abdômen'),
    (8,  'Leg Press 45', 'Pernas'),
    (9,  'Prancha Isométrica', 'Abdômen'),
    (10, 'Elevação Lateral', 'Ombro');

-- ------------------------------------------------------------
-- TREINO_EXERCICIO (mesmo exercício reaproveitado em vários
-- treinos -- RN14; algumas cargas/descansos em branco em
-- exercícios isométricos/livres -> RN15)
-- ------------------------------------------------------------
INSERT INTO treino_exercicio
    (id_treino, id_exercicio, quantidade_series, repeticoes, carga, tempo_descanso, ordem_execucao)
VALUES
    -- Treino 1 (substituído)
    (1, 1, 4, 10, 40.00, 60, 1),
    (1, 2, 4, 12, 50.00, 90, 2),
    (1, 3, 3, 12, 35.00, 60, 3),

    -- Treino 2 (ativo)
    (2, 1, 4, 10, 45.00, 60, 1),
    (2, 4, 3, 12, 14.00, 45, 2),
    (2, 5, 3, 12, 18.00, 45, 3),
    (2, 7, 3, 15, NULL,  NULL, 4),
    -- [CONTORNO] exercício de peso corporal sem carga/descanso definidos

    -- Treino 3
    (3, 8, 4, 15, 80.00, 60, 1),
    (3, 2, 3, 12, 30.00, 90, 2),
    (3, 9, 3, 1,  NULL,  45,  3),
    -- [CONTORNO] prancha isométrica sem carga (exercício de peso corporal)

    -- Treino 4 (apenas um exercício -> caso mínimo permitido pela RN14)
    (4, 10, 3, 15, 6.00, 30, 1),

    -- Treino 5
    (5, 2, 3, 10, 20.00, 90, 1),
    (5, 6, 3, 10, 10.00, 60, 2),
    (5, 7, 3, 15, NULL, NULL, 3);

-- ============================================================
-- FIM DA CARGA DE DADOS
-- ============================================================
