USE Sistema_Informacoes_Hospitalares;
GO

-- VIEW 1: Cadastro Completo dos Hospitais
-- Informações detalhadas de localização e contato 
CREATE VIEW vw_Hospitais_Completo AS
SELECT 
    h.Id_Hospital AS ID_Hospital,
    h.CNES AS Codigo_CNES,
    h.Nome_Hospital AS Nome_Hospital,
    h.Razao_Social AS Razao_Social,
    h.Tipo_Gestao AS Tipo_Gestao,
    m.Nome AS Municipio,
    uf.Nome AS Estado,
    uf.Sigla AS UF,
    r.Nome AS Regiao,
    nj.Descricao AS Natureza_Juridica,
    e.No_Logradouro AS Logradouro,
    e.Nu_Endereco AS Numero,
    e.No_Bairro AS Bairro,
    e.Co_Cep AS CEP,
    e.Nu_Telefone AS Telefone,
    e.No_Email AS Email
FROM Hospital h
JOIN Municipio m ON h.Id_Municipio = m.Id_Municipio
JOIN UF uf ON h.Id_Uf = uf.Id_Uf
JOIN Regiao r ON uf.Id_Regiao = r.Id_Regiao
JOIN Natureza_Juridica nj ON h.Id_Natureza_Juridica = nj.Id_Natureza_Juridica
JOIN Endereco_Hospital e ON h.Id_Endereco = e.Id_Endereco;
GO

SELECT * FROM vw_Hospitais_Completo;

-- VIEW 2: Capacidade de Leitos por Hospital 
-- Análise da disponibilidade de leitos
CREATE VIEW vw_Capacidade_Leitos AS
SELECT 
    h.Id_Hospital,
    h.Nome_Hospital,
    h.CNES,
    tl.Descricao AS Tipo_Leito,
    tl.Categoria,
    SUM(l.Quantidade_Existentes) AS Total_Leitos_Existentes,
    SUM(l.Quantidade_Sus) AS Total_Leitos_SUS,
    CASE 
        WHEN SUM(l.Quantidade_Existentes) > 0 
        THEN CAST(SUM(l.Quantidade_Sus) AS FLOAT) / SUM(l.Quantidade_Existentes) * 100 
        ELSE 0 
    END AS Percentual_SUS
FROM Hospital h
INNER JOIN Leito l ON h.Id_Hospital = l.Id_Hospital
INNER JOIN Tipo_Leito tl ON l.Id_Tipo_Leito = tl.Id_Tipo_Leito
GROUP BY h.Id_Hospital, h.Nome_Hospital, h.CNES, tl.Descricao, tl.Categoria;
GO

SELECT * FROM vw_Capacidade_Leitos;
-- VIEW 3: Perfil dos Pacientes
-- Análise demográfica dos pacientes
CREATE VIEW vw_Perfil_Pacientes AS
SELECT 
    p.Id_Paciente,
    p.Idade,
    p.Sexo,
    p.Data_Nascimento,
    p.Nacionalidade,
    p.Etnia,
    p.Num_Filhos,
    rc.Descricao AS Raca_Cor,
    ne.Descricao_Escolaridade AS Escolaridade,
    m.Nome AS Municipio,
    uf.Sigla AS UF
FROM Paciente p
INNER JOIN RACA_COR rc ON p.Id_Raca = rc.Id_Raca
INNER JOIN Nivel_de_Escolaridade ne ON p.Id_Escolaridade = ne.Id_Escolaridade
INNER JOIN Municipio m ON p.Id_Municipio = m.Id_Municipio
INNER JOIN UF uf ON m.Id_Uf = uf.Id_Uf;
GO

SELECT * FROM vw_Perfil_Pacientes;

-- VIEW 4: Atendimentos Completos
-- Visão detalhada dos atendimentos
CREATE VIEW vw_Atendimentos_Detalhados AS
SELECT 
    a.Id_Atendimento,
    a.Data_Hora,
    a.Inscricao_Paciente,
    p.Id_Paciente,
    p.Idade AS Idade_Paciente,
    p.Sexo,
    h.Nome_Hospital,
    h.CNES,
    cr.Descricao AS Classificacao_Risco,
    ta.Descricao AS Tipo_Atendimento,
    m.Nome AS Municipio_Paciente,
    uf.Sigla AS UF_Paciente
FROM Atendimento a
INNER JOIN Paciente p ON a.Id_Paciente = p.Id_Paciente
INNER JOIN Hospital h ON a.Id_Hospital = h.Id_Hospital
INNER JOIN Classificacao_Risco cr ON a.Id_Class_Risco = cr.Id_Class_Risco
INNER JOIN Tipo_Atendimento ta ON a.Id_Tipo_Atendimento = ta.Id_Tipo_Atendimento
INNER JOIN Municipio m ON p.Id_Municipio = m.Id_Municipio
INNER JOIN UF uf ON m.Id_Uf = uf.Id_Uf;
GO

SELECT * FROM vw_Atendimentos_Detalhados;


-- VIEW 5: Internações com Análise Financeira
-- Consolidação de internações e custos
CREATE VIEW vw_Internacoes_Financeiro AS
SELECT 
    i.Id_Internacao,
    i.Data_Internacao,
    i.Data_Saida,
    DATEDIFF(DAY, i.Data_Internacao, COALESCE(i.Data_Saida, GETDATE())) AS Dias_Internacao,
    i.Morte,
    p.Id_Paciente,
    p.Idade,
    p.Sexo,
    h.Nome_Hospital,
    h.CNES,
    f.Total_Procedimento,
    f.Valor_Hospitalar,
    f.Valor_Profissional,
    f.Valor_UTI,
    f.Numero_Procedimentos,
    CASE 
        WHEN i.Morte = 1 THEN 'Óbito'
        WHEN i.Data_Saida IS NULL THEN 'Em Internação'
        ELSE 'Alta'
    END AS Status_Internacao
FROM Internacao i
INNER JOIN Paciente p ON i.Id_Paciente = p.Id_Paciente
INNER JOIN Hospital h ON i.Id_Hospital = h.Id_Hospital
LEFT JOIN Financeiro_AIH f ON i.Id_Internacao = f.Id_Internacao;
GO

SELECT * FROM vw_Internacoes_Financeiro;

-- VIEW 6: Taxa de Ocupação UTI -- FUNCIONOU 
-- Monitoramento de UTIs
CREATE VIEW vw_Ocupacao_UTI AS
SELECT 
    h.Id_Hospital,
    h.Nome_Hospital,
    h.CNES,
    lud.UTI_TOTAL_EXIST AS UTI_Total_Existente,
    lud.UTI_TOTAL_SUS AS UTI_Total_SUS,
    lud.UTI_ADULTO_EXIST AS UTI_Adulto_Existente,
    lud.UTI_ADULTO_SUS AS UTI_Adulto_SUS,
    lud.UTI_PEDIATRICO_EXIST AS UTI_Pediatrico_Existente,
    lud.UTI_PEDIATRICO_SUS AS UTI_Pediatrico_SUS,
    lud.UTI_NEONATAL_EXIST AS UTI_Neonatal_Existente,
    lud.UTI_NEONATAL_SUS AS UTI_Neonatal_SUS
FROM Hospital h
INNER JOIN Leito_UTI_Detalhe lud ON h.Id_Hospital = lud.Id_Hospital;
GO

SELECT * FROM vw_Ocupacao_UTI;

-- VIEW 7: Profissionais por Especialidade
-- Distribuição do corpo clínico
CREATE VIEW vw_Profissionais_Especialidade AS
SELECT 
    h.Id_Hospital,
    h.Nome_Hospital,
    em.Nome AS Especialidade,
    COUNT(ps.Id_Profissional_Saude) AS Qtd_Profissionais,
    STRING_AGG(ps.Nome, '; ') AS Lista_Profissionais
FROM Hospital h
INNER JOIN Profissional_Saude ps ON h.Id_Hospital = ps.Id_Hospital
INNER JOIN Especialidade_Medica em ON ps.Id_Especialidade = em.Id_Especialidade
GROUP BY h.Id_Hospital, h.Nome_Hospital, em.Nome;
GO

SELECT * FROM vw_Profissionais_Especialidade;

-- VIEW 8: Estatísticas de Mortalidade
-- Análise de óbitos
CREATE VIEW vw_Estatisticas_Mortalidade AS
SELECT 
    h.Id_Hospital,
    h.Nome_Hospital,
    COUNT(i.Id_Internacao) AS Total_Internacoes,
    SUM(CASE WHEN i.Morte = 1 THEN 1 ELSE 0 END) AS Total_Obitos,
    CASE 
        WHEN COUNT(i.Id_Internacao) > 0 
        THEN CAST(SUM(CASE WHEN i.Morte = 1 THEN 1 ELSE 0 END) AS FLOAT) / COUNT(i.Id_Internacao) * 100 
        ELSE 0 
    END AS Taxa_Mortalidade,
    AVG(DATEDIFF(DAY, i.Data_Internacao, COALESCE(i.Data_Saida, GETDATE()))) AS Media_Dias_Internacao
FROM Hospital h
LEFT JOIN Internacao i ON h.Id_Hospital = i.Id_Hospital
GROUP BY h.Id_Hospital, h.Nome_Hospital;
GO

SELECT * FROM vw_Estatisticas_Mortalidade;

-- VIEW 9: Recursos Hospitalares por Tipo
-- Inventário de recursos
CREATE VIEW vw_Recursos_Hospitalares AS
SELECT 
    h.Id_Hospital,
    h.Nome_Hospital,
    tr.Descricao AS Tipo_Recurso,
    rh.Nome AS Nome_Recurso,
    rh.Quantidade,
    rh.Valor_Alocado,
    rh.Estado_Conservacao,
    rh.Data_Validade,
    rh.Fornecedor
FROM Hospital h
INNER JOIN Recurso_Hospitalar rh ON h.Id_Hospital = rh.Id_Hospital
INNER JOIN Tipo_Recurso tr ON rh.Id_Tipo_Recurso = tr.Id_Tipo_Recurso;
GO

SELECT * FROM vw_Recursos_Hospitalares;

-- VIEW 10: Demanda Hospitalar
-- Análise de demanda e tempo de espera
CREATE VIEW vw_Analise_Demanda AS
SELECT 
    h.Id_Hospital,
    h.Nome_Hospital,
    td.Descricao AS Tipo_Demanda,
    dh.Data,
    dh.Qt_Solicitacao,
    dh.Tempo_Medio_Espera,
    YEAR(dh.Data) AS Ano,
    MONTH(dh.Data) AS Mes
FROM Hospital h
INNER JOIN Demanda_Hospitalar dh ON h.Id_Hospital = dh.Id_Hospital
INNER JOIN Tipo_Demanda td ON dh.Id_Tipo_Demanda = td.Id_Tipo_Demanda;
GO

SELECT * FROM vw_Analise_Demanda;

-- VIEW 11: Procedimentos Realizados com Valores
-- Análise de procedimentos e custos
CREATE VIEW vw_Procedimentos_Valores AS
SELECT 
    i.Id_Internacao,
    h.Nome_Hospital,
    p.Id_Paciente,
    pm.Descricao AS Procedimento,
    pi.Procedimento_Realizado,
    pm.Val_Tot AS Valor_Total_Tabela,
    pi.Val_Sh_Fed,
    pi.Val_Sp_Fed,
    pi.Val_Uci,
    i.Data_Internacao
FROM Procedimento_Internacao pi
INNER JOIN Internacao i ON pi.Id_Internacao = i.Id_Internacao
INNER JOIN Hospital h ON i.Id_Hospital = h.Id_Hospital
INNER JOIN Paciente p ON i.Id_Paciente = p.Id_Paciente
INNER JOIN Procedimento_Medico pm ON pi.Id_Procedimento_Medico = pm.Id_Procedimento_Medico;
GO

SELECT * FROM vw_Procedimentos_Valores;


-- VIEW 12: Dashboard Executivo
-- KPIs principais por região
CREATE VIEW vw_Dashboard_Executivo AS
SELECT 
    r.Nome AS Regiao,
    uf.Sigla AS UF,
    COUNT(DISTINCT h.Id_Hospital) AS Total_Hospitais,
    SUM(l.Quantidade_Existentes) AS Total_Leitos,
    SUM(l.Quantidade_Sus) AS Total_Leitos_SUS,
    COUNT(DISTINCT ps.Id_Profissional_Saude) AS Total_Profissionais,
    COUNT(DISTINCT a.Id_Atendimento) AS Total_Atendimentos,
    COUNT(DISTINCT i.Id_Internacao) AS Total_Internacoes
FROM Regiao r
INNER JOIN UF uf ON r.Id_Regiao = uf.Id_Regiao
LEFT JOIN Hospital h ON uf.Id_Uf = h.Id_Uf
LEFT JOIN Leito l ON h.Id_Hospital = l.Id_Hospital
LEFT JOIN Profissional_Saude ps ON h.Id_Hospital = ps.Id_Hospital
LEFT JOIN Atendimento a ON h.Id_Hospital = a.Id_Hospital
LEFT JOIN Internacao i ON h.Id_Hospital = i.Id_Hospital
GROUP BY r.Nome, uf.Sigla;
GO

SELECT * FROM vw_Dashboard_Executivo;

PRINT 'Views criadas com sucesso!';
GO