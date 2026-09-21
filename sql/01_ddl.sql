-- ============================================================
-- PROJETO: Academia com avaliação física
-- DISCIPLINA: Laboratório de Banco de Dados
-- ETAPA 1 - A6: DDL
-- SGBD: MySQL 8.0+
-- ============================================================

-- ------------------------------------------------------------
-- CRIAÇÃO DO BANCO
-- ------------------------------------------------------------

DROP DATABASE IF EXISTS academia_avaliacao;

CREATE DATABASE academia_avaliacao
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_0900_ai_ci;

USE academia_avaliacao;


-- ============================================================
-- TABELA: PESSOA
-- Regra relacionada: RN01, RN02 e RN03
-- ============================================================

CREATE TABLE pessoa (
    id_pessoa INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome VARCHAR(150) NOT NULL,
    cpf CHAR(11) NOT NULL,
    data_nascimento DATE NOT NULL,
    telefone VARCHAR(20) NULL,
    email VARCHAR(150) NULL,

    -- Endereço composto no modelo conceitual
    rua VARCHAR(150) NOT NULL,
    numero VARCHAR(20) NOT NULL,
    bairro VARCHAR(100) NOT NULL,
    cidade VARCHAR(100) NOT NULL,
    uf CHAR(2) NOT NULL,
    cep CHAR(8) NOT NULL,

    CONSTRAINT pk_pessoa
        PRIMARY KEY (id_pessoa),

    CONSTRAINT uq_pessoa_cpf
        UNIQUE (cpf),

    CONSTRAINT ck_pessoa_cpf
        CHECK (
            CHAR_LENGTH(cpf) = 11
            AND cpf REGEXP '^[0-9]{11}$'
        ),

    CONSTRAINT ck_pessoa_uf
        CHECK (CHAR_LENGTH(uf) = 2),

    CONSTRAINT ck_pessoa_cep
        CHECK (
            CHAR_LENGTH(cep) = 8
            AND cep REGEXP '^[0-9]{8}$'
        )
) ENGINE = InnoDB;


-- ============================================================
-- TABELA: ALUNO
-- Especialização de PESSOA
-- Estratégia: tabela própria para a especialização
-- Regra relacionada: RN01, RN02 e RN04
-- ============================================================

CREATE TABLE aluno (
    id_pessoa INT UNSIGNED NOT NULL,
    matricula VARCHAR(30) NOT NULL,
    status_matricula ENUM(
        'ativa',
        'inativa',
        'suspensa',
        'cancelada'
    ) NOT NULL DEFAULT 'ativa',

    CONSTRAINT pk_aluno
        PRIMARY KEY (id_pessoa),

    CONSTRAINT uq_aluno_matricula
        UNIQUE (matricula),

    CONSTRAINT fk_aluno_pessoa
        FOREIGN KEY (id_pessoa)
        REFERENCES pessoa(id_pessoa)
        ON DELETE CASCADE
        ON UPDATE CASCADE
) ENGINE = InnoDB;


-- ============================================================
-- TABELA: PROFISSIONAL
-- Especialização de PESSOA
-- Também representa o relacionamento SUPERVISIONA.
-- Regra relacionada: RN03, RN19 e RN20
-- ============================================================

CREATE TABLE profissional (
    id_pessoa INT UNSIGNED NOT NULL,
    registro_profissional VARCHAR(30) NOT NULL,
    especialidade VARCHAR(100) NOT NULL,

    -- Auto-relacionamento SUPERVISIONA
    id_supervisor INT UNSIGNED NULL,

    CONSTRAINT pk_profissional
        PRIMARY KEY (id_pessoa),

    CONSTRAINT uq_profissional_registro
        UNIQUE (registro_profissional),

    CONSTRAINT fk_profissional_pessoa
        FOREIGN KEY (id_pessoa)
        REFERENCES pessoa(id_pessoa)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_profissional_supervisor
        FOREIGN KEY (id_supervisor)
        REFERENCES profissional(id_pessoa)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE = InnoDB;


-- ============================================================
-- TABELA: PLANO
-- Regra relacionada: RN05
-- ============================================================

CREATE TABLE plano (
    id_plano INT UNSIGNED NOT NULL AUTO_INCREMENT,
    nome_plano VARCHAR(100) NOT NULL,
    valor_mensal DECIMAL(10,2) NOT NULL,
    duracao_meses INT UNSIGNED NOT NULL,

    CONSTRAINT pk_plano
        PRIMARY KEY (id_plano),

    CONSTRAINT ck_plano_valor
        CHECK (valor_mensal > 0),

    CONSTRAINT ck_plano_duracao
        CHECK (duracao_meses > 0)
) ENGINE = InnoDB;


-- ============================================================
-- TABELA: CONTRATO
-- Relaciona ALUNO e PLANO.
-- Possui atributos próprios.
-- Regra relacionada: RN04, RN05, RN06 e RN07
-- ============================================================

CREATE TABLE contrato (
    id_contrato INT UNSIGNED NOT NULL AUTO_INCREMENT,

    id_pessoa_aluno INT UNSIGNED NOT NULL,
    id_plano INT UNSIGNED NOT NULL,

    data_inicio DATE NOT NULL,
    data_termino DATE NOT NULL,

    situacao ENUM(
        'ativo',
        'encerrado',
        'suspenso',
        'cancelado'
    ) NOT NULL,

    duracao_dias INT UNSIGNED NOT NULL,

    CONSTRAINT pk_contrato
        PRIMARY KEY (id_contrato),

    CONSTRAINT fk_contrato_aluno
        FOREIGN KEY (id_pessoa_aluno)
        REFERENCES aluno(id_pessoa)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_contrato_plano
        FOREIGN KEY (id_plano)
        REFERENCES plano(id_plano)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT ck_contrato_datas
        CHECK (data_termino >= data_inicio),

    CONSTRAINT ck_contrato_duracao
        CHECK (duracao_dias > 0)
) ENGINE = InnoDB;


-- ============================================================
-- TABELA: AVALIACAO_FISICA
-- Regra relacionada: RN08 e RN09
-- ============================================================

CREATE TABLE avaliacao_fisica (
    id_avaliacao INT UNSIGNED NOT NULL AUTO_INCREMENT,

    id_pessoa_aluno INT UNSIGNED NOT NULL,

    data_avaliacao DATE NOT NULL,
    observacoes TEXT NULL,

    CONSTRAINT pk_avaliacao_fisica
        PRIMARY KEY (id_avaliacao),

    CONSTRAINT fk_avaliacao_aluno
        FOREIGN KEY (id_pessoa_aluno)
        REFERENCES aluno(id_pessoa)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE = InnoDB;


-- ============================================================
-- TABELA: MEDIDA
-- ENTIDADE FRACA dependente de AVALIACAO_FISICA.
--
-- Chave:
-- (id_avaliacao, tipo_medida)
--
-- Regra relacionada: RN10 e RN11
-- ============================================================

CREATE TABLE medida (
    id_avaliacao INT UNSIGNED NOT NULL,
    tipo_medida VARCHAR(30) NOT NULL,
    valor_medida DECIMAL(10,2) NOT NULL,
    unidade ENUM(
        'kg',
        'cm',
        'm'
    ) NOT NULL,

    CONSTRAINT pk_medida
        PRIMARY KEY (id_avaliacao, tipo_medida),

    CONSTRAINT fk_medida_avaliacao
        FOREIGN KEY (id_avaliacao)
        REFERENCES avaliacao_fisica(id_avaliacao)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT ck_medida_tipo
        CHECK (
            tipo_medida IN (
                'peso',
                'altura',
                'cintura',
                'braco'
            )
        ),

    CONSTRAINT ck_medida_valor
        CHECK (valor_medida > 0),

    CONSTRAINT ck_medida_unidade
        CHECK (
            (tipo_medida = 'peso' AND unidade = 'kg')
            OR
            (tipo_medida = 'altura' AND unidade = 'm')
            OR
            (
                tipo_medida IN ('cintura', 'braco')
                AND unidade = 'cm'
            )
        )
) ENGINE = InnoDB;


-- ============================================================
-- TABELA: TREINO
-- Um treino pertence a um aluno e possui um profissional
-- responsável pela prescrição.
--
-- Regra relacionada: RN12, RN13, RN17 e RN18
-- ============================================================

CREATE TABLE treino (
    id_treino INT UNSIGNED NOT NULL AUTO_INCREMENT,

    id_pessoa_aluno INT UNSIGNED NOT NULL,
    id_pessoa_profissional INT UNSIGNED NOT NULL,

    data_prescricao DATE NOT NULL,
    nome_treino VARCHAR(100) NOT NULL,

    status_treino ENUM(
        'ativo',
        'encerrado',
        'substituido'
    ) NOT NULL,

    CONSTRAINT pk_treino
        PRIMARY KEY (id_treino),

    CONSTRAINT fk_treino_aluno
        FOREIGN KEY (id_pessoa_aluno)
        REFERENCES aluno(id_pessoa)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_treino_profissional
        FOREIGN KEY (id_pessoa_profissional)
        REFERENCES profissional(id_pessoa)
        ON DELETE RESTRICT
        ON UPDATE CASCADE
) ENGINE = InnoDB;

-- ============================================================
-- TABELA ASSOCIATIVA: PRESCRICAO
--
-- Representa o relacionamento N:N entre PROFISSIONAL e TREINO.
--
-- Permite relacionar os profissionais responsáveis pelas
-- prescrições dos treinos, mantendo o vínculo entre profissional
-- e treino.
--
-- Regra relacionada: RN13, RN17 e RN18
-- ============================================================

CREATE TABLE prescricao (
    id_pessoa_profissional INT UNSIGNED NOT NULL,
    id_treino INT UNSIGNED NOT NULL,

    CONSTRAINT pk_prescricao
        PRIMARY KEY (id_pessoa_profissional, id_treino),

    CONSTRAINT fk_prescricao_profissional
        FOREIGN KEY (id_pessoa_profissional)
        REFERENCES profissional(id_pessoa)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT fk_prescricao_treino
        FOREIGN KEY (id_treino)
        REFERENCES treino(id_treino)
        ON DELETE CASCADE
        ON UPDATE CASCADE
);

-- ============================================================
-- TABELA: EXERCICIO
-- Regra relacionada: RN14 e RN15
-- ============================================================

CREATE TABLE exercicio (
    id_exercicio INT UNSIGNED NOT NULL AUTO_INCREMENT,

    nome_exercicio VARCHAR(120) NOT NULL,
    grupo_muscular VARCHAR(50) NOT NULL,

    CONSTRAINT pk_exercicio
        PRIMARY KEY (id_exercicio),

    CONSTRAINT uq_exercicio_nome
        UNIQUE (nome_exercicio)
) ENGINE = InnoDB;


-- ============================================================
-- TABELA ASSOCIATIVA: TREINO_EXERCICIO
--
-- Representa o relacionamento N:N entre TREINO e EXERCICIO.
--
-- Atributos próprios do relacionamento:
-- quantidade_series
-- repeticoes
-- carga
-- tempo_descanso
-- ordem_execucao
--
-- Regra relacionada: RN14, RN15 e RN16
-- ============================================================

CREATE TABLE treino_exercicio (
    id_treino INT UNSIGNED NOT NULL,
    id_exercicio INT UNSIGNED NOT NULL,

    quantidade_series INT UNSIGNED NOT NULL,
    repeticoes INT UNSIGNED NOT NULL,
    carga DECIMAL(10,2) NULL,
    tempo_descanso INT UNSIGNED NULL,
    ordem_execucao INT UNSIGNED NOT NULL,

    CONSTRAINT pk_treino_exercicio
        PRIMARY KEY (id_treino, id_exercicio),

    CONSTRAINT fk_treino_exercicio_treino
        FOREIGN KEY (id_treino)
        REFERENCES treino(id_treino)
        ON DELETE CASCADE
        ON UPDATE CASCADE,

    CONSTRAINT fk_treino_exercicio_exercicio
        FOREIGN KEY (id_exercicio)
        REFERENCES exercicio(id_exercicio)
        ON DELETE RESTRICT
        ON UPDATE CASCADE,

    CONSTRAINT ck_treino_exercicio_series
        CHECK (quantidade_series > 0),

    CONSTRAINT ck_treino_exercicio_repeticoes
        CHECK (repeticoes > 0),

    CONSTRAINT ck_treino_exercicio_carga
        CHECK (
            carga IS NULL
            OR carga >= 0
        ),

    CONSTRAINT ck_treino_exercicio_descanso
        CHECK (
            tempo_descanso IS NULL
            OR tempo_descanso > 0
        ),

    CONSTRAINT ck_treino_exercicio_ordem
        CHECK (ordem_execucao > 0),

    -- Não permite duas posições iguais dentro do mesmo treino.
    CONSTRAINT uq_treino_exercicio_ordem
        UNIQUE (id_treino, ordem_execucao)
) ENGINE = InnoDB;


-- ============================================================
-- FIM DO DDL
-- ============================================================