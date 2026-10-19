# Academia_com_avaliacao_fisica

Projeto desenvolvido para a disciplina **Laboratório de Banco de Dados**, com o objetivo de organizar e gerenciar informações de uma academia, incluindo alunos, profissionais, planos, treinos, exercícios e avaliações físicas.

## Informações acadêmicas

- **Disciplina:** Laboratório de Banco de Dados
- **Professor:** Samuel Novais Moura Júnior
- **Integrantes:**
  - Gabriel Araújo de Almeida
  - João Paulo Sebastian Santos de Morais
- **Instituição:** Universidade Católica de Brasília (UCB)
- **Ano:** 2026

## Sobre o projeto

O projeto consiste no desenvolvimento de um banco de dados para uma academia, com foco no gerenciamento de alunos, profissionais, planos e contratos, prescrição de treinos e histórico de medidas antropométricas.

O sistema busca organizar as informações e manter a integridade dos dados, permitindo o acompanhamento dos treinos e das avaliações físicas ao longo do tempo.

O projeto foi desenvolvido em etapas, começando pela modelagem conceitual e lógica do banco de dados e avançando para a implementação SQL, a aplicação Java, a segurança, a auditoria e a otimização de consultas.

## Tecnologias utilizadas

- **MySQL 8.0+:** criação e gerenciamento do banco de dados.
- **Java:** desenvolvimento da aplicação.
- **Java Swing:** construção das interfaces gráficas.
- **NetBeans:** ambiente de desenvolvimento.
- **JDBC:** conexão entre a aplicação Java e o MySQL.
- **GitHub:** organização e versionamento dos arquivos do projeto.

## Funcionalidades e recursos

O projeto contempla:

- Cadastro e gerenciamento de pessoas, alunos e profissionais.
- Gerenciamento de planos e exercícios.
- Registro de treinos e exercícios associados.
- Registro de avaliações físicas e medidas antropométricas.
- Consultas com filtros e relacionamentos entre tabelas.
- Operações de cadastro, consulta, alteração e exclusão.
- Utilização de transações para operações que envolvem mais de uma tabela.
- Controle de acesso por usuários e permissões.
- Proteção de senhas por derivação criptográfica.
- Auditoria de alterações importantes.
- Análise de consultas e utilização de índices.
- Planejamento de backup e recuperação do banco de dados.

## Modelagem do banco de dados

A modelagem foi desenvolvida considerando os requisitos do projeto e os relacionamentos necessários para representar as atividades de uma academia.

Entre os conceitos contemplados estão:

- Especialização e generalização entre pessoa, aluno e profissional.
- Relacionamentos muitos-para-muitos (N:N), representados por entidades associativas.
- Autorrelacionamento entre profissionais.
- Entidade fraca para representar medidas vinculadas a uma avaliação física.
- Histórico de avaliações e medidas ao longo do tempo.
- Restrições de integridade e regras de negócio.

O banco utiliza o mecanismo InnoDB, permitindo trabalhar com transações e integridade referencial.

## Como executar o projeto

### 1. Preparar o banco de dados

1. Instale e inicie o MySQL 8.0 ou superior.
2. Abra o MySQL Workbench ou outro cliente compatível.
3. Execute os scripts SQL do projeto na ordem indicada pelos arquivos e suas dependências.
4. Confirme a criação do banco `academia_avaliacao` e das tabelas necessárias.

### 2. Executar a aplicação Java

1. Abra o projeto da aplicação no NetBeans.
2. Verifique se o driver JDBC do MySQL está disponível.
3. Confira as configurações de conexão com o banco de dados.
4. Confirme que o MySQL está em execução e que o usuário utilizado possui as permissões necessárias.
5. Execute a classe principal da aplicação.

## Consultas, segurança e otimização

O projeto também contempla atividades voltadas à qualidade e à manutenção do banco de dados, incluindo consultas com filtros e junções, utilização de `PreparedStatement`, transações, controle de permissões, gatilhos de auditoria e análise de planos de execução com `EXPLAIN`.

Esses recursos contribuem para a integridade, a rastreabilidade das alterações e a eficiência das operações realizadas no banco.

## Backup e recuperação

Foi definida uma estratégia de backup com cópias diárias, semanais e mensais, considerando diferentes períodos de retenção.

Também foi descrito um procedimento de restauração em banco de teste. A validação completa da recuperação deve considerar não apenas a ausência de erros durante a restauração, mas também a comparação dos dados e a verificação da integridade das informações.

## Demonstração do projeto

A demonstração pode apresentar:

1. A estrutura do banco de dados no MySQL Workbench.
2. A execução da aplicação Java.
3. Os cadastros e as consultas disponíveis.
4. O relacionamento entre as entidades.
5. A execução de consultas SQL.
6. Os mecanismos de segurança e auditoria desenvolvidos.
7. A análise de consultas e índices.

## Considerações finais

O projeto Academia com Avaliação Física reúne conceitos de modelagem de dados, implementação SQL, desenvolvimento de aplicação Java, segurança, auditoria e otimização.

A divisão do trabalho em etapas permite documentar a evolução do projeto e demonstrar como os conceitos estudados na disciplina podem ser aplicados a um cenário real de gerenciamento de informações.

O repositório reúne os scripts, a aplicação, a documentação e as evidências produzidas durante o desenvolvimento.
