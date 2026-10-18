# B2 – Camada de acesso a dados (roteiro e texto-base do relatório)

## 1. Prepared statements
Todas as consultas dos DAOs usam `PreparedStatement` com parâmetros `?`
(`AlunoDAO`, `ConsultaDAO`, `TreinoDAO`, `UsuarioAplicacaoDAO` e demais).
Verificação feita no código-fonte: não há uso de `createStatement()` nem
concatenação de variáveis em SQL. Comando para evidenciar no relatório:

    grep -rn "createStatement" src/        -> sem resultados

Inclua no relatório um trecho de `ConsultaDAO.alunosPorMatricula`
(`WHERE a.matricula = ?` + `pst.setString(1, matricula)`).

## 2. Demonstração de tentativa de injeção de SQL
**Alvo:** tela "Consulta de Alunos" (campo matrícula) -> `ConsultaDAO.alunosPorMatricula`.

**Passo A – pela interface:** digite `' OR '1'='1` no campo matrícula e
tire print: a tabela volta vazia (0 linhas).

**Passo B – pelo código:** rode `TesteInjecao.java` e cole a saída.
Resultado esperado:

| Entrada                                   | Linhas |
|-------------------------------------------|--------|
| `2025ALU0001` (legítima)                  | 1      |
| `' OR '1'='1`                             | 0      |
| `x' OR 1=1 -- `                           | 0      |
| `'; DROP TABLE aluno; -- `                | 0      |
| `' UNION SELECT ... FROM pessoa -- `      | 0      |

Última linha da saída: "Tabela aluno íntegra", comprovando que o
`DROP TABLE` não foi executado.

**Por que resiste:** o texto digitado é enviado como VALOR do parâmetro,
nunca interpretado como SQL. O banco compara a matrícula com a string
literal `' OR '1'='1`, que não existe.

**Contraste (executar no console do MySQL, NÃO no código):** é o que
aconteceria se a consulta fosse montada por concatenação:

    SELECT p.nome, a.matricula
    FROM aluno a JOIN pessoa p ON p.id_pessoa = a.id_pessoa
    WHERE a.matricula = '' OR '1'='1';

Retorna todos os alunos (a condição vira sempre verdadeira). Com
parâmetro, a mesma entrada retorna 0 linhas.

## 3. Credenciais fora do código-fonte
1. Substituir `DAO.java` e adicionar `ConfigBanco.java` (pacote `br.com.modelo`).
2. Copiar `config.properties.example` para `config.properties` na RAIZ do
   projeto e preencher. (Alternativa: variáveis de ambiente
   `ACADEMIA_DB_URL`, `ACADEMIA_DB_USER`, `ACADEMIA_DB_PASSWORD`.)
3. Adicionar `.gitignore` (inclui `config.properties`, `build/`, `dist/`,
   `nbproject/private/`).
4. Versionar apenas `config.properties.example`.

**Se a senha antiga já foi commitada ou enviada em zip:**
- Troque a senha no MySQL (`ALTER USER ... IDENTIFIED BY '...'`): remover
  do código não apaga do histórico do Git.
- Se houver repositório, `git rm --cached config.properties` (se entrou
  por engano) e, para limpar o histórico, `git filter-repo`.
- Use um usuário próprio da aplicação em vez de `root`:

      CREATE USER 'academia_app'@'localhost' IDENTIFIED BY '<senha-forte>';
      GRANT SELECT, INSERT, UPDATE, DELETE
          ON academia_avaliacao.* TO 'academia_app'@'localhost';

  (Scripts de DDL e de índices, B4, continuam rodando com usuário administrador.)

## 4. Checklist de evidências para o relatório
- [ ] Trecho de código com `PreparedStatement` e `setString`
- [ ] Resultado do `grep` sem `createStatement`
- [ ] Print da tela com a entrada `' OR '1'='1` e resultado vazio
- [ ] Saída de `TesteInjecao.java`
- [ ] Contraste da consulta concatenada (console MySQL)
- [ ] `DAO.java` sem senha + `config.properties.example` + `.gitignore`
- [ ] Print do `git status` mostrando que `config.properties` é ignorado
