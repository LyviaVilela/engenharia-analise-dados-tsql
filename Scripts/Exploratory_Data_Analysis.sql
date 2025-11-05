-- ============================
-- 1️ Quantidade total de registros
-- ============================
SELECT COUNT(*) AS total_linhas
FROM Staging_Leitos_Hospitais;

-- ============================
-- 2️ Valores nulos ou vazios por coluna
-- ============================
SELECT
    SUM(CASE WHEN COMP IS NULL OR COMP = '' THEN 1 ELSE 0 END) AS comp_nulos,
    SUM(CASE WHEN REGIAO IS NULL OR REGIAO = '' THEN 1 ELSE 0 END) AS regiao_nulos,
    SUM(CASE WHEN UF IS NULL OR UF = '' THEN 1 ELSE 0 END) AS uf_nulos,
    SUM(CASE WHEN MUNICIPIO IS NULL OR MUNICIPIO = '' THEN 1 ELSE 0 END) AS municipio_nulos,
    SUM(CASE WHEN MOTIVO_DESABILITACAO IS NULL OR MOTIVO_DESABILITACAO = '' THEN 1 ELSE 0 END) AS motivo_desabilitacao_nulos,
    SUM(CASE WHEN CNES IS NULL OR CNES = '' THEN 1 ELSE 0 END) AS cnes_nulos,
    SUM(CASE WHEN NOME_ESTABELECIMENTO IS NULL OR NOME_ESTABELECIMENTO = '' THEN 1 ELSE 0 END) AS nome_estabelecimento_nulos,
    SUM(CASE WHEN LEITOS_EXISTENTES IS NULL OR LEITOS_EXISTENTES = '' THEN 1 ELSE 0 END) AS leitos_existentes_nulos,
    SUM(CASE WHEN LEITOS_SUS IS NULL OR LEITOS_SUS = '' THEN 1 ELSE 0 END) AS leitos_sus_nulos,
    SUM(CASE WHEN UTI_TOTAL_EXIST IS NULL OR UTI_TOTAL_EXIST = '' THEN 1 ELSE 0 END) AS uti_total_exist_nulos
FROM Staging_Leitos_Hospitais;

-- ============================
-- 3️ Valores únicos por coluna (exemplo para UF, MUNICIPIO e TP_GESTAO)
-- ============================
SELECT UF, COUNT(*) AS total_por_uf
FROM Staging_Leitos_Hospitais
GROUP BY UF
ORDER BY total_por_uf DESC;

SELECT MUNICIPIO, COUNT(*) AS total_por_municipio
FROM Staging_Leitos_Hospitais
GROUP BY MUNICIPIO
ORDER BY total_por_municipio DESC;

SELECT TP_GESTAO, COUNT(*) AS total_por_tp_gestao
FROM Staging_Leitos_Hospitais
GROUP BY TP_GESTAO
ORDER BY total_por_tp_gestao DESC;

-- ============================
-- 4️ Estatísticas das colunas numéricas (convertendo de VARCHAR para INT/DECIMAL)
-- ============================
-- LEITOS_EXISTENTES
SELECT
    MIN(CAST(LEITOS_EXISTENTES AS INT)) AS min_leitos,
    MAX(CAST(LEITOS_EXISTENTES AS INT)) AS max_leitos,
    AVG(CAST(LEITOS_EXISTENTES AS FLOAT)) AS media_leitos
FROM Staging_Leitos_Hospitais
WHERE ISNUMERIC(LEITOS_EXISTENTES) = 1;

-- LEITOS_SUS
SELECT
    MIN(CAST(LEITOS_SUS AS INT)) AS min_sus,
    MAX(CAST(LEITOS_SUS AS INT)) AS max_sus,
    AVG(CAST(LEITOS_SUS AS FLOAT)) AS media_sus
FROM Staging_Leitos_Hospitais
WHERE ISNUMERIC(LEITOS_SUS) = 1;

-- UTI_TOTAL_EXIST
SELECT
    MIN(CAST(UTI_TOTAL_EXIST AS INT)) AS min_uti,
    MAX(CAST(UTI_TOTAL_EXIST AS INT)) AS max_uti,
    AVG(CAST(UTI_TOTAL_EXIST AS FLOAT)) AS media_uti
FROM Staging_Leitos_Hospitais
WHERE ISNUMERIC(UTI_TOTAL_EXIST) = 1;

-- ============================
-- 5️ Duplicatas (por exemplo, por COMP, MUNICIPIO e CNES)
-- ============================
SELECT COMP, MUNICIPIO, CNES, COUNT(*) AS qtd
FROM Staging_Leitos_Hospitais
GROUP BY COMP, MUNICIPIO, CNES
HAVING COUNT(*) > 1
ORDER BY qtd DESC;

-- ============================
-- 6️ Distribuição de categorias (exemplo: NATUREZA_JURIDICA)
-- ============================
SELECT NATUREZA_JURIDICA, COUNT(*) AS total
FROM Staging_Leitos_Hospitais
GROUP BY NATUREZA_JURIDICA
ORDER BY total DESC;

-- ============================
-- 7️ Checar formatação de CEP e telefone
-- ============================
-- CEPs com tamanho diferente de 8
SELECT CO_CEP
FROM Staging_Leitos_Hospitais
WHERE LEN(CO_CEP) <> 8 AND CO_CEP IS NOT NULL;

-- Telefones com tamanho diferente de esperado (exemplo 10 ou 11 dígitos)
SELECT NU_TELEFONE
FROM Staging_Leitos_Hospitais
WHERE LEN(NU_TELEFONE) NOT IN (10,11) AND NU_TELEFONE IS NOT NULL;



