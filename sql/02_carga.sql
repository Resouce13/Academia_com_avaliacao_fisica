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
    (id_contrato, id_pessoa_aluno, id_plano, data_inicio, data_termino, situacao)
VALUES
    (1, 3, 1, '2025-03-01', '2025-03-31', 'encerrado'),
    (2, 3, 3, '2025-04-01', '2026-04-01', 'ativo'),
    -- [HISTÓRICO] mesmo aluno com 2 contratos ao longo do tempo
    (3, 4, 2, '2026-07-01', '2026-09-29', 'ativo'),
    (4, 5, 1, '2024-05-01', '2024-05-31', 'cancelado'),
    -- [CONTORNO] situação cancelada
    (5, 6, 2, '2026-06-15', '2026-09-13', 'suspenso'),
    -- [CONTORNO] situação suspensa
    (6, 7, 1, '2026-09-01', '2026-10-01', 'ativo');

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
-- TREINO
-- Um treino pertence a um aluno.
-- O vínculo com o profissional responsável é representado
-- pela tabela associativa PRESCRICAO.
--
-- Regra relacionada: RN12, RN13, RN17 e RN18
-- ------------------------------------------------------------

INSERT INTO treino
    (id_treino, id_pessoa_aluno, data_prescricao, nome_treino, status_treino)
VALUES
    (1, 3, '2025-03-06', 'Treino Full Body - Iniciante', 'substituido'),
    (2, 3, '2025-09-12', 'Treino ABC - Hipertrofia', 'ativo'),
    -- [HISTÓRICO] treino 1 substituído pelo treino 2 para o mesmo aluno
    (3, 4, '2026-07-06', 'Treino Funcional - Emagrecimento', 'ativo'),
    (4, 6, '2026-06-21', 'Treino de Mobilidade', 'ativo'),
    (5, 7, '2026-09-02', 'Treino Iniciante - Adaptação', 'ativo'),

    (6, 3, '2026-04-10', 'Treino A - Força', 'ativo'),
    (7, 4, '2026-07-15', 'Treino B - Hipertrofia', 'ativo'),
    (8, 6, '2026-07-01', 'Treino C - Condicionamento', 'ativo'),
    (9, 7, '2026-09-05', 'Treino A - Adaptação', 'ativo'),
    (10, 3, '2026-05-10', 'Treino B - Hipertrofia', 'ativo'),
    (11, 4, '2026-08-01', 'Treino A - Resistência', 'ativo'),
    (12, 6, '2026-08-15', 'Treino B - Força', 'ativo'),
    (13, 7, '2026-09-10', 'Treino B - Adaptação', 'ativo'),
    (14, 3, '2026-06-15', 'Treino C - Pernas', 'ativo'),
    (15, 4, '2026-08-20', 'Treino C - Completo', 'ativo'),
    (16, 6, '2026-09-01', 'Treino D - Mobilidade', 'ativo'),
    (17, 7, '2026-09-12', 'Treino C - Iniciante', 'ativo'),
    (18, 3, '2026-09-15', 'Treino D - Hipertrofia', 'ativo');

-- ------------------------------------------------------------
-- PRESCRICAO
-- Relacionamento N:N entre PROFISSIONAL e TREINO.
--
-- Regra relacionada: RN13, RN17 e RN18
-- ------------------------------------------------------------

INSERT INTO prescricao
    (id_pessoa_profissional, id_treino)
VALUES
    -- Treino 1: Carlos
    (1, 1),

    -- Treino 2: Beatriz
    (2, 2),

    -- Treino 3: Carlos
    (1, 3),

    -- Treino 4: Carlos
    (1, 4),

    -- Treino 5: Beatriz
    (2, 5),

    -- Treinos adicionais
    (1, 6),
    (2, 7),
    (1, 8),
    (2, 9),
    (2, 10),
    (1, 11),
    (1, 12),
    (2, 13),
    (1, 14),
    (2, 15),
    (1, 16),
    (2, 17),
    (1, 18);

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
    (5, 7, 3, 15, NULL, NULL, 3),
    
    -- TREINO 6
    (6, 1, 4, 10, 50.00, 60, 1),
    (6, 2, 4, 10, 60.00, 90, 2),
    (6, 3, 3, 12, 40.00, 60, 3),
    (6, 4, 3, 12, 16.00, 45, 4),
    (6, 5, 3, 12, 20.00, 45, 5),
    (6, 6, 3, 10, 12.00, 60, 6),
    (6, 7, 3, 15, NULL, NULL, 7),
    
    -- TREINO 7
    (7, 2, 4, 12, 55.00, 90, 1),
    (7, 8, 4, 12, 90.00, 60, 2),
    (7, 3, 3, 10, 42.00, 60, 3),
    (7, 1, 4, 10, 42.00, 60, 4),
    (7, 6, 3, 12, 10.00, 60, 5),
    (7, 4, 3, 12, 15.00, 45, 6),
    (7, 5, 3, 12, 18.00, 45, 7),
    
	-- TREINO 8
    (8, 1, 3, 12, 35.00, 60, 1),
    (8, 3, 3, 12, 30.00, 60, 2),
    (8, 4, 3, 12, 12.00, 45, 3),
    (8, 5, 3, 12, 15.00, 45, 4),
    (8, 7, 3, 20, NULL, NULL, 5),
    (8, 9, 3, 1, NULL, 45, 6),
    
    -- TREINO 9
	(9, 2, 4, 10, 70.00, 90, 1),
    (9, 8, 4, 12, 100.00, 60, 2),
    (9, 6, 3, 10, 14.00, 60, 3),
    (9, 10, 3, 15, 7.00, 45, 4),
    (9, 4, 3, 10, 18.00, 45, 5),
    (9, 5, 3, 10, 22.00, 45, 6),
    (9, 7, 3, 15, NULL, NULL, 7),

	-- TREINO 10
	(10, 1, 4, 8, 55.00, 60, 1),
    (10, 2, 4, 10, 65.00, 90, 2),
    (10, 3, 4, 10, 45.00, 60, 3),
    (10, 6, 3, 10, 15.00, 60, 4),
    (10, 8, 4, 10, 110.00, 60, 5),
    (10, 4, 3, 10, 20.00, 45, 6),
    (10, 5, 3, 10, 24.00, 45, 7),
    
    -- TREINO 11
    (11, 1, 3, 12, 40.00, 60, 1),
    (11, 3, 3, 12, 35.00, 60, 2),
    (11, 6, 3, 12, 10.00, 60, 3),
    (11, 10, 3, 15, 5.00, 45, 4),
    (11, 4, 3, 12, 14.00, 45, 5),
    (11, 5, 3, 12, 18.00, 45, 6),
    
    -- TREINO 12
    (12, 2, 4, 12, 60.00, 90, 1),
    (12, 8, 4, 15, 85.00, 60, 2),
    (12, 3, 3, 12, 38.00, 60, 3),
    (12, 1, 4, 10, 45.00, 60, 4),
    (12, 7, 3, 20, NULL, NULL, 5),
    (12, 9, 3, 1, NULL, 45, 6),
    
    -- TREINO 13
    (13, 1, 4, 10, 48.00, 60, 1),
    (13, 2, 4, 10, 58.00, 90, 2),
    (13, 3, 3, 10, 40.00, 60, 3),
    (13, 4, 3, 12, 16.00, 45, 4),
    (13, 5, 3, 12, 20.00, 45, 5),
    (13, 6, 3, 10, 12.00, 60, 6),
    (13, 10, 3, 15, 6.00, 45, 7),
    
    -- TREINO 14
    (14, 2, 4, 10, 65.00, 90, 1),
    (14, 8, 4, 12, 95.00, 60, 2),
    (14, 6, 3, 10, 12.00, 60, 3),
    (14, 10, 3, 15, 6.00, 45, 4),
    (14, 4, 3, 12, 16.00, 45, 5),
    (14, 5, 3, 12, 20.00, 45, 6),
    
    -- TREINO 15
    (15, 1, 4, 10, 42.00, 60, 1),
    (15, 3, 4, 10, 36.00, 60, 2),
    (15, 2, 4, 12, 50.00, 90, 3),
    (15, 8, 4, 12, 75.00, 60, 4),
    (15, 7, 3, 20, NULL, NULL, 5),
    (15, 9, 3, 1, NULL, 45, 6),
    
    -- TREINO 16
    (16, 1, 3, 12, 38.00, 60, 1),
    (16, 2, 3, 12, 45.00, 90, 2),
    (16, 3, 3, 12, 32.00, 60, 3),
    (16, 4, 3, 12, 12.00, 45, 4),
    (16, 5, 3, 12, 16.00, 45, 5),
    (16, 10, 3, 15, 5.00, 45, 6),
    
    -- TREINO 17
    (17, 2, 4, 10, 62.00, 90, 1),
    (17, 8, 4, 12, 90.00, 60, 2),
    (17, 3, 3, 12, 40.00, 60, 3),
    (17, 6, 3, 10, 12.00, 60, 4),
    (17, 4, 3, 12, 15.00, 45, 5),
    (17, 7, 3, 15, NULL, NULL, 6),
    
    -- TREINO 18
    (18, 1, 4, 10, 50.00, 60, 1),
    (18, 2, 4, 10, 60.00, 90, 2),
    (18, 3, 3, 10, 42.00, 60, 3),
    (18, 4, 3, 12, 16.00, 45, 4),
    (18, 5, 3, 12, 20.00, 45, 5),
    (18, 6, 3, 10, 14.00, 60, 6),
    (18, 10, 3, 15, 6.00, 45, 7);

-- ============================================================
-- FIM DA CARGA DE DADOS
-- ============================================================
