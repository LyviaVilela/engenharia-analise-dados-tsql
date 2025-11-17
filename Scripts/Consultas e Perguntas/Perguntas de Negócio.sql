--------------- Análise de Capacidade Hospitalar--------------------------

--Quantos leitos de UTI (total, adulto, pediátrico) existem por região/estado? -- FUNCIONA
SELECT 
    r.Nome AS Regiao,
    u.Sigla AS Estado,
    SUM(TRY_CONVERT(INT, l.UTI_TOTAL_EXIST)) AS Total_UTI,
    SUM(TRY_CONVERT(INT, l.UTI_ADULTO_EXIST)) AS UTI_Adulto,
    SUM(TRY_CONVERT(INT, l.UTI_PEDIATRICO_EXIST)) AS UTI_Pediatrico,
    SUM(TRY_CONVERT(INT, l.UTI_NEONATAL_EXIST)) AS UTI_Neonatal,
    SUM(TRY_CONVERT(INT, l.UTI_TOTAL_SUS)) AS UTI_SUS,
    ROUND(
        SUM(TRY_CONVERT(INT, l.UTI_TOTAL_SUS)) * 100.0 
        / NULLIF(SUM(TRY_CONVERT(INT, l.UTI_TOTAL_EXIST)), 0), 
        2
    ) AS Percentual_SUS
FROM Leito_UTI_Detalhe l
JOIN Hospital h ON l.Id_Hospital = h.Id_Hospital
JOIN UF u ON h.Id_Uf = u.Id_Uf
JOIN Regiao r ON u.Id_Regiao = r.Id_Regiao
GROUP BY r.Nome, u.Sigla
ORDER BY r.Nome, Total_UTI DESC;

--Qual a proporção de leitos SUS vs. particulares por tipo de UTI? --FUNCIONA
SELECT 
    'UTI Adulto' AS Tipo_UTI,
    SUM(TRY_CONVERT(INT, UTI_ADULTO_EXIST)) AS Total_Existente,
    SUM(TRY_CONVERT(INT, UTI_ADULTO_SUS)) AS Total_SUS,
    SUM(TRY_CONVERT(INT, UTI_ADULTO_EXIST) - TRY_CONVERT(INT, UTI_ADULTO_SUS)) AS Total_Nao_SUS,
    ROUND(
        SUM(TRY_CONVERT(INT, UTI_ADULTO_SUS)) * 100.0 / NULLIF(SUM(TRY_CONVERT(INT, UTI_ADULTO_EXIST)), 0)
    , 2) AS Percentual_SUS
FROM Leito_UTI_Detalhe
WHERE TRY_CONVERT(INT, UTI_ADULTO_EXIST) > 0

UNION ALL

SELECT 
    'UTI Pediátrico',
    SUM(TRY_CONVERT(INT, UTI_PEDIATRICO_EXIST)),
    SUM(TRY_CONVERT(INT, UTI_PEDIATRICO_SUS)),
    SUM(TRY_CONVERT(INT, UTI_PEDIATRICO_EXIST) - TRY_CONVERT(INT, UTI_PEDIATRICO_SUS)),
    ROUND(
        SUM(TRY_CONVERT(INT, UTI_PEDIATRICO_SUS)) * 100.0 / NULLIF(SUM(TRY_CONVERT(INT, UTI_PEDIATRICO_EXIST)), 0)
    , 2)
FROM Leito_UTI_Detalhe
WHERE TRY_CONVERT(INT, UTI_PEDIATRICO_EXIST) > 0

UNION ALL

SELECT 
    'UTI Neonatal',
    SUM(TRY_CONVERT(INT, UTI_NEONATAL_EXIST)),
    SUM(TRY_CONVERT(INT, UTI_NEONATAL_SUS)),
    SUM(TRY_CONVERT(INT, UTI_NEONATAL_EXIST) - TRY_CONVERT(INT, UTI_NEONATAL_SUS)),
    ROUND(
        SUM(TRY_CONVERT(INT, UTI_NEONATAL_SUS)) * 100.0 / NULLIF(SUM(TRY_CONVERT(INT, UTI_NEONATAL_EXIST)), 0)
    , 2)
FROM Leito_UTI_Detalhe
WHERE TRY_CONVERT(INT, UTI_NEONATAL_EXIST) > 0;

--Como a disponibilidade de leitos de UTI coronariana se distribui entre as regiões do país em relação à população total? -- FUNCIONA
SELECT 
    r.Nome AS Região,
    SUM(CAST(l.UTI_CORONARIANA_EXIST AS INT)) AS UTI_Coronariana,
    r.Populacao_Estimada AS Populacao_Regiao,
    ROUND(SUM(CAST(l.UTI_CORONARIANA_EXIST AS INT)) * 100000.0 / NULLIF(r.Populacao_Estimada, 0), 2) AS UTI_Coronariana_por_100k
FROM Leito_UTI_Detalhe l
JOIN Hospital h ON l.Id_Hospital = h.Id_Hospital
JOIN UF u ON h.Id_Uf = u.Id_Uf
JOIN Regiao r ON u.Id_Regiao = r.Id_Regiao
WHERE r.Populacao_Estimada > 0
GROUP BY r.Nome, r.Populacao_Estimada
ORDER BY UTI_Coronariana_por_100k DESC;

--2 Top 10 municípios com melhor e pior taxa de leitos por habitante — correlação com porte populacional -- RESPONDEU

WITH leitos_por_mun AS (
  SELECT m.Id_Municipio, m.Nome,
         SUM(COALESCE(l.Leitos_Existentes,0)) AS leitos_total,
         m.Populacao_Estimada,
         (SUM(COALESCE(l.Leitos_Existentes,0)) / NULLIF(m.Populacao_Estimada,0))*1000.0 AS leitos_por_1000
  FROM Municipio m
  JOIN Hospital h ON h.Id_Municipio = m.Id_Municipio
  LEFT JOIN Leito l ON l.Id_Hospital = h.Id_Hospital
  GROUP BY m.Id_Municipio, m.Nome, m.Populacao_Estimada
)
SELECT TOP 10 * FROM leitos_por_mun
ORDER BY leitos_por_1000 DESC;

-- Quais hospitais têm maior ociosidade de UTI?
SELECT 
    h.CNES,
    h.Nome_Hospital,
    u.Sigla AS UF,
    TRY_CAST(l.UTI_TOTAL_EXIST AS INT) AS Leitos_UTI_Total,
    TRY_CAST(l.UTI_TOTAL_SUS AS INT) AS Leitos_UTI_SUS,
    ROUND(
        (TRY_CAST(l.UTI_TOTAL_EXIST AS FLOAT) - TRY_CAST(l.UTI_TOTAL_SUS AS FLOAT)) * 100.0 /
        NULLIF(TRY_CAST(l.UTI_TOTAL_EXIST AS FLOAT), 0),
        2
    ) AS Percentual_Ociosidade
FROM Hospital h
JOIN Leito_UTI_Detalhe l ON h.Id_Hospital = l.Id_Hospital
JOIN UF u ON h.Id_Uf = u.Id_Uf
WHERE TRY_CAST(l.UTI_TOTAL_EXIST AS FLOAT) > 0
ORDER BY Percentual_Ociosidade DESC;

-- Onde faltam leitos de UTI em relação à população?
SELECT 
    u.Sigla AS UF,
    TRY_CAST(REPLACE(REPLACE(u.Populacao_Estimada, '"', ''), ',', '') AS BIGINT) AS Populacao_Estimada,
    SUM(TRY_CAST(REPLACE(REPLACE(l.UTI_TOTAL_EXIST, '"', ''), ',', '') AS INT)) AS Total_Leitos_UTI,
    ROUND(
        SUM(TRY_CAST(REPLACE(REPLACE(l.UTI_TOTAL_EXIST, '"', ''), ',', '') AS FLOAT)) * 100000.0 / 
        NULLIF(TRY_CAST(REPLACE(REPLACE(u.Populacao_Estimada, '"', ''), ',', '') AS FLOAT), 0),
        2
    ) AS Leitos_por_100k_Hab,
    CASE 
        WHEN SUM(TRY_CAST(REPLACE(REPLACE(l.UTI_TOTAL_EXIST, '"', ''), ',', '') AS FLOAT)) * 100000.0 / 
             NULLIF(TRY_CAST(REPLACE(REPLACE(u.Populacao_Estimada, '"', ''), ',', '') AS FLOAT), 0) < 10 THEN 'CRÍTICO'
        WHEN SUM(TRY_CAST(REPLACE(REPLACE(l.UTI_TOTAL_EXIST, '"', ''), ',', '') AS FLOAT)) * 100000.0 / 
             NULLIF(TRY_CAST(REPLACE(REPLACE(u.Populacao_Estimada, '"', ''), ',', '') AS FLOAT), 0) < 20 THEN 'ALERTA'
        ELSE 'ADEQUADO'
    END AS Situacao
FROM UF u
JOIN Hospital h ON u.Id_Uf = h.Id_Uf
JOIN Leito_UTI_Detalhe l ON h.Id_Hospital = l.Id_Hospital
WHERE TRY_CAST(REPLACE(REPLACE(u.Populacao_Estimada, '"', ''), ',', '') AS FLOAT) > 0
GROUP BY u.Sigla, u.Populacao_Estimada
ORDER BY Leitos_por_100k_Hab ASC;

-- Qual tipo de gestão tem mais leitos de UTI?
SELECT 
    h.Tipo_Gestao,
    COUNT(DISTINCT h.Id_Hospital) AS Qtd_Hospitais,
    SUM(CAST(l.UTI_TOTAL_EXIST AS INT)) AS Total_Leitos_UTI,
    SUM(CAST(l.UTI_TOTAL_SUS AS INT)) AS Leitos_UTI_SUS,
    ROUND(
        SUM(CAST(l.UTI_TOTAL_SUS AS INT)) * 100.0 / 
        NULLIF(SUM(CAST(l.UTI_TOTAL_EXIST AS INT)), 0), 
    2) AS Percentual_SUS
FROM Hospital h
JOIN Leito_UTI_Detalhe l ON h.Id_Hospital = l.Id_Hospital
WHERE h.Tipo_Gestao IS NOT NULL
GROUP BY h.Tipo_Gestao
ORDER BY Total_Leitos_UTI DESC;

-- Como a natureza jurídica influencia na oferta de leitos?
SELECT 
    nj.Descricao AS Natureza_Juridica,
    COUNT(DISTINCT h.Id_Hospital) AS Qtd_Hospitais,
    SUM(CAST(l.UTI_TOTAL_EXIST AS INT)) AS Total_UTI,
    SUM(CAST(l.UTI_ADULTO_EXIST AS INT)) AS UTI_Adulto,
    SUM(CAST(l.UTI_PEDIATRICO_EXIST AS INT)) AS UTI_Pediatrico,
    ROUND(
        AVG(CAST(l.UTI_TOTAL_EXIST AS INT)), 
    2) AS Media_Leitos_por_Hospital
FROM Hospital h
JOIN Natureza_Juridica nj ON h.Id_Natureza_Juridica = nj.Id_Natureza_Juridica
JOIN Leito_UTI_Detalhe l ON h.Id_Hospital = l.Id_Hospital
GROUP BY nj.Descricao
ORDER BY Total_UTI DESC;


--Estados com maior deficiência de UTI SUS
SELECT 
    u.Sigla AS UF,
    u.Populacao_Estimada,
    SUM(CAST(l.UTI_TOTAL_EXIST AS INT)) AS Total_Leitos_UTI,
    SUM(CAST(l.UTI_TOTAL_SUS AS INT)) AS Leitos_UTI_SUS,
    ROUND(SUM(CAST(l.UTI_TOTAL_SUS AS INT)) * 100000.0 / u.Populacao_Estimada, 2) AS Leitos_SUS_por_100k,
    CASE 
        WHEN SUM(CAST(l.UTI_TOTAL_SUS AS INT)) * 100000.0 / u.Populacao_Estimada < 5 THEN 'EMERGÊNCIA'
        WHEN SUM(CAST(l.UTI_TOTAL_SUS AS INT)) * 100000.0 / u.Populacao_Estimada < 10 THEN 'CRÍTICO'
        ELSE 'REGULAR'
    END AS Situacao_SUS
FROM UF u
JOIN Hospital h ON u.Id_Uf = h.Id_Uf
JOIN Leito_UTI_Detalhe l ON h.Id_Hospital = l.Id_Hospital
WHERE u.Populacao_Estimada > 0
GROUP BY u.Sigla, u.Populacao_Estimada
ORDER BY Leitos_SUS_por_100k ASC;


-- Regiões com maior carência de leitos especializados
SELECT 
    r.Nome AS Região,
    SUM(CAST(l.UTI_CORONARIANA_EXIST AS INT)) AS UTI_Coronariana,
    r.Populacao_Estimada,
    ROUND(SUM(CAST(l.UTI_CORONARIANA_EXIST AS INT)) * 100000.0 / NULLIF(r.Populacao_Estimada, 0), 2) AS UTI_Coronariana_por_100k,
    CASE 
        WHEN SUM(CAST(l.UTI_CORONARIANA_EXIST AS INT)) * 100000.0 / r.Populacao_Estimada < 1 THEN 'ALTA PRIORIDADE'
        WHEN SUM(CAST(l.UTI_CORONARIANA_EXIST AS INT)) * 100000.0 / r.Populacao_Estimada < 2 THEN 'MÉDIA PRIORIDADE'
        ELSE 'REGULAR'
    END AS Prioridade_Investimento
FROM Leito_UTI_Detalhe l
JOIN Hospital h ON l.Id_Hospital = h.Id_Hospital
JOIN UF u ON h.Id_Uf = u.Id_Uf
JOIN Regiao r ON u.Id_Regiao = r.Id_Regiao
WHERE r.Populacao_Estimada > 0
GROUP BY r.Nome, r.Populacao_Estimada
ORDER BY UTI_Coronariana_por_100k ASC;


-- Os leitos estão concentrados em poucos hospitais?
WITH ranking_hospitais AS (
    SELECT 
        h.CNES,
        h.Nome_Hospital,
        u.Sigla AS UF,
        CAST(l.UTI_TOTAL_EXIST AS INT) AS Leitos_UTI,
        SUM(CAST(l.UTI_TOTAL_EXIST AS INT)) OVER () AS Total_Leitos_Brasil,
        ROUND(CAST(l.UTI_TOTAL_EXIST AS INT) * 100.0 / SUM(CAST(l.UTI_TOTAL_EXIST AS INT)) OVER (), 4) AS Percentual_Total
    FROM Hospital h
    JOIN Leito_UTI_Detalhe l ON h.Id_Hospital = l.Id_Hospital
    JOIN UF u ON h.Id_Uf = u.Id_Uf
    WHERE CAST(l.UTI_TOTAL_EXIST AS INT) > 0
)
SELECT 
    COUNT(*) AS Total_Hospitais_UTI,
    SUM(Leitos_UTI) AS Total_Leitos,
    AVG(Leitos_UTI) AS Media_Leitos_por_Hospital,
    MAX(Leitos_UTI) AS Maior_Hospital,
    -- Quantos hospitais concentram 50% dos leitos?
    (SELECT COUNT(*) FROM ranking_hospitais WHERE Percentual_Total >= 0.5) AS Hospitais_Com_Mais_de_0_5_Porcento
FROM ranking_hospitais;


-- Quais hospitais são referência em leitos pediátricos/neonatais?
SELECT TOP 10
    h.CNES,
    h.Nome_Hospital,
    u.Sigla AS UF,
    CAST(l.UTI_PEDIATRICO_EXIST AS INT) AS UTI_Pediatrico,
    CAST(l.UTI_NEONATAL_EXIST AS INT) AS UTI_Neonatal,
    CAST(l.UTI_TOTAL_EXIST AS INT) AS UTI_Total,
    ROUND((CAST(l.UTI_PEDIATRICO_EXIST AS INT) + CAST(l.UTI_NEONATAL_EXIST AS INT)) * 100.0 / 
          NULLIF(CAST(l.UTI_TOTAL_EXIST AS INT), 0), 2) AS Percentual_Pediatrico
FROM Hospital h
JOIN Leito_UTI_Detalhe l ON h.Id_Hospital = l.Id_Hospital
JOIN UF u ON h.Id_Uf = u.Id_Uf
WHERE CAST(l.UTI_PEDIATRICO_EXIST AS INT) > 0 OR CAST(l.UTI_NEONATAL_EXIST AS INT) > 0
ORDER BY (CAST(l.UTI_PEDIATRICO_EXIST AS INT) + CAST(l.UTI_NEONATAL_EXIST AS INT)) DESC;


-- Onde há capacidade ociosa que poderia ser convertida para SUS?
SELECT 
    u.Sigla AS UF,
    COUNT(*) AS Hospitais_Com_Ociosidade,
    SUM(CAST(l.UTI_TOTAL_EXIST AS INT) - CAST(l.UTI_TOTAL_SUS AS INT)) AS Leitos_Ociosos_Total,
    AVG(CAST(l.UTI_TOTAL_EXIST AS INT) - CAST(l.UTI_TOTAL_SUS AS INT)) AS Media_Leitos_Ociosos
FROM Hospital h
JOIN Leito_UTI_Detalhe l ON h.Id_Hospital = l.Id_Hospital
JOIN UF u ON h.Id_Uf = u.Id_Uf
WHERE CAST(l.UTI_TOTAL_EXIST AS INT) > CAST(l.UTI_TOTAL_SUS AS INT)
  AND (CAST(l.UTI_TOTAL_EXIST AS INT) - CAST(l.UTI_TOTAL_SUS AS INT)) >= 5  -- Pelo menos 5 leitos ociosos
GROUP BY u.Sigla
ORDER BY Leitos_Ociosos_Total DESC;


-- Qual a diversidade de oferta de leitos por região?

SELECT 
    r.Nome AS Regiao,
    COUNT(DISTINCT h.Id_Hospital) AS Total_Hospitais_UTI,
    SUM(CAST(l.UTI_TOTAL_EXIST AS INT)) AS Total_Leitos,
    SUM(CAST(l.UTI_ADULTO_EXIST AS INT)) AS Leitos_Adulto,
    SUM(CAST(l.UTI_PEDIATRICO_EXIST AS INT)) AS Leitos_Pediatrico,
    SUM(CAST(l.UTI_NEONATAL_EXIST AS INT)) AS Leitos_Neonatal,
    SUM(CAST(l.UTI_CORONARIANA_EXIST AS INT)) AS Leitos_Coronariana,

    -- Índice de diversidade (quantos tipos diferentes de UTI por hospital)
    ROUND(
        (COUNT(CASE WHEN CAST(l.UTI_ADULTO_EXIST AS INT) > 0 THEN 1 END) +
         COUNT(CASE WHEN CAST(l.UTI_PEDIATRICO_EXIST AS INT) > 0 THEN 1 END) +
         COUNT(CASE WHEN CAST(l.UTI_NEONATAL_EXIST AS INT) > 0 THEN 1 END)) * 1.0 / 
        COUNT(DISTINCT h.Id_Hospital)
    , 2) AS Diversidade_Leitos_por_Hospital
FROM Regiao r
JOIN UF u ON r.Id_Regiao = u.Id_Regiao
JOIN Hospital h ON u.Id_Uf = h.Id_Uf
JOIN Leito_UTI_Detalhe l ON h.Id_Hospital = l.Id_Hospital
GROUP BY r.Nome
ORDER BY Diversidade_Leitos_por_Hospital DESC;










--    CAPACIDADE HOSPITALAR BRASIL
SELECT 
    -- CAPACIDADE TOTAL
    (SELECT SUM(TRY_CONVERT(INT, UTI_TOTAL_EXIST)) FROM Leito_UTI_Detalhe) AS Total_Leitos_UTI_Brasil,
    (SELECT SUM(TRY_CONVERT(INT, UTI_TOTAL_SUS)) FROM Leito_UTI_Detalhe) AS Total_Leitos_UTI_SUS,
    ROUND(
        (SELECT SUM(TRY_CONVERT(INT, UTI_TOTAL_SUS)) FROM Leito_UTI_Detalhe) * 100.0 / 
        NULLIF((SELECT SUM(TRY_CONVERT(INT, UTI_TOTAL_EXIST)) FROM Leito_UTI_Detalhe), 0)
    , 2) AS Percentual_SUS_Nacional,

    -- SITUAÇÃO CRÍTICA
    (SELECT COUNT(*) FROM (
        SELECT u.Sigla
        FROM UF u
        JOIN Hospital h ON u.Id_Uf = h.Id_Uf
        JOIN Leito_UTI_Detalhe l ON h.Id_Hospital = l.Id_Hospital
        WHERE u.Populacao_Estimada > 0
        GROUP BY u.Sigla, u.Populacao_Estimada
        HAVING SUM(CAST(l.UTI_TOTAL_SUS AS INT)) * 100000.0 / u.Populacao_Estimada < 10
    ) AS criticos) AS UFs_Situacao_Critica,

    -- CONCENTRAÇÃO
    (SELECT COUNT(*) FROM Hospital h 
     JOIN Leito_UTI_Detalhe l ON h.Id_Hospital = l.Id_Hospital 
     WHERE CAST(l.UTI_TOTAL_EXIST AS INT) > 0) AS Total_Hospitais_Com_UTI,

    -- DIVERSIDADE
    (SELECT ROUND(AVG(
        CASE WHEN CAST(UTI_ADULTO_EXIST AS INT) > 0 THEN 1 ELSE 0 END +
        CASE WHEN CAST(UTI_PEDIATRICO_EXIST AS INT) > 0 THEN 1 ELSE 0 END +
        CASE WHEN CAST(UTI_NEONATAL_EXIST AS INT) > 0 THEN 1 ELSE 0 END
    ), 2) FROM Leito_UTI_Detalhe) AS Diversidade_Media_Tipos_UTI,

    -- OCIOSIDADE ESTRATÉGICA
    (SELECT COUNT(*) FROM Leito_UTI_Detalhe 
     WHERE CAST(UTI_TOTAL_EXIST AS INT) > CAST(UTI_TOTAL_SUS AS INT)
       AND (CAST(UTI_TOTAL_EXIST AS INT) - CAST(UTI_TOTAL_SUS AS INT)) >= 5) AS Hospitais_Com_Ociosidade_Significativa;



-- Estados por Necessidade de Investimento
-- Capacidade de resposta a surtos/pandemia por região
SELECT 
    r.Nome AS Regiao,
    -- Capacidade Absoluta
    SUM(CAST(l.UTI_TOTAL_EXIST AS INT)) AS Leitos_UTI_Total,
    -- Capacidade SUS
    SUM(CAST(l.UTI_TOTAL_SUS AS INT)) AS Leitos_UTI_SUS,
    -- Densidade
    ROUND(SUM(CAST(l.UTI_TOTAL_EXIST AS INT)) * 100000.0 / r.Populacao_Estimada, 2) AS Densidade_Leitos,
    -- Diversidade
    COUNT(DISTINCT CASE WHEN CAST(l.UTI_ADULTO_EXIST AS INT) > 0 THEN h.Id_Hospital END) AS Hospitais_Adulto,
    COUNT(DISTINCT CASE WHEN CAST(l.UTI_PEDIATRICO_EXIST AS INT) > 0 THEN h.Id_Hospital END) AS Hospitais_Pediatrico,
    COUNT(DISTINCT CASE WHEN CAST(l.UTI_NEONATAL_EXIST AS INT) > 0 THEN h.Id_Hospital END) AS Hospitais_Neonatal,
    -- Score de Resiliência
    ROUND(
        (SUM(CAST(l.UTI_TOTAL_SUS AS INT)) * 100000.0 / r.Populacao_Estimada) *
        (COUNT(DISTINCT h.Id_Hospital) * 1.0 / r.Populacao_Estimada * 100000) *
        (COUNT(DISTINCT CASE WHEN CAST(l.UTI_ADULTO_EXIST AS INT) > 0 THEN h.Id_Hospital END) +
         COUNT(DISTINCT CASE WHEN CAST(l.UTI_PEDIATRICO_EXIST AS INT) > 0 THEN h.Id_Hospital END)) * 1.0 /
        COUNT(DISTINCT h.Id_Hospital)
    , 2) AS Indice_Resiliencia
FROM Regiao r
JOIN UF u ON r.Id_Regiao = u.Id_Regiao
JOIN Hospital h ON u.Id_Uf = h.Id_Uf
JOIN Leito_UTI_Detalhe l ON h.Id_Hospital = l.Id_Hospital
WHERE r.Populacao_Estimada > 0
GROUP BY r.Nome, r.Populacao_Estimada
ORDER BY Indice_Resiliencia DESC;




-- Ranking de Estados por Necessidade de Investimento
-- Mapa de Prioridades de Investimento (CORRIGIDA)
SELECT 
    u.Sigla AS UF,
    u.Populacao_Estimada,
    -- Necessidade de leitos SUS
    CASE 
        WHEN SUM(CAST(l.UTI_TOTAL_SUS AS INT)) * 100000.0 / u.Populacao_Estimada < 5 THEN 10
        WHEN SUM(CAST(l.UTI_TOTAL_SUS AS INT)) * 100000.0 / u.Populacao_Estimada < 10 THEN 7
        ELSE 3
    END AS Pontuacao_SUS,
    -- Necessidade de leitos especializados
    CASE 
        WHEN SUM(CAST(l.UTI_CORONARIANA_EXIST AS INT)) * 100000.0 / u.Populacao_Estimada < 1 THEN 8
        WHEN SUM(CAST(l.UTI_CORONARIANA_EXIST AS INT)) * 100000.0 / u.Populacao_Estimada < 2 THEN 5
        ELSE 2
    END AS Pontuacao_Especializada,
    -- Ociosidade (potencial de aproveitamento)
    CASE 
        WHEN SUM(CAST(l.UTI_TOTAL_EXIST AS INT) - CAST(l.UTI_TOTAL_SUS AS INT)) >= 10 THEN 6
        WHEN SUM(CAST(l.UTI_TOTAL_EXIST AS INT) - CAST(l.UTI_TOTAL_SUS AS INT)) >= 5 THEN 3
        ELSE 0
    END AS Pontuacao_Ociosidade,
    -- SCORE FINAL
    (CASE 
        WHEN SUM(CAST(l.UTI_TOTAL_SUS AS INT)) * 100000.0 / u.Populacao_Estimada < 5 THEN 10
        WHEN SUM(CAST(l.UTI_TOTAL_SUS AS INT)) * 100000.0 / u.Populacao_Estimada < 10 THEN 7
        ELSE 3
    END +
    CASE 
        WHEN SUM(CAST(l.UTI_CORONARIANA_EXIST AS INT)) * 100000.0 / u.Populacao_Estimada < 1 THEN 8
        WHEN SUM(CAST(l.UTI_CORONARIANA_EXIST AS INT)) * 100000.0 / u.Populacao_Estimada < 2 THEN 5
        ELSE 2
    END +
    CASE 
        WHEN SUM(CAST(l.UTI_TOTAL_EXIST AS INT) - CAST(l.UTI_TOTAL_SUS AS INT)) >= 10 THEN 6
        WHEN SUM(CAST(l.UTI_TOTAL_EXIST AS INT) - CAST(l.UTI_TOTAL_SUS AS INT)) >= 5 THEN 3
        ELSE 0
    END) AS Score_Prioridade,
    CASE 
        WHEN (CASE 
                WHEN SUM(CAST(l.UTI_TOTAL_SUS AS INT)) * 100000.0 / u.Populacao_Estimada < 5 THEN 10
                WHEN SUM(CAST(l.UTI_TOTAL_SUS AS INT)) * 100000.0 / u.Populacao_Estimada < 10 THEN 7
                ELSE 3
            END +
            CASE 
                WHEN SUM(CAST(l.UTI_CORONARIANA_EXIST AS INT)) * 100000.0 / u.Populacao_Estimada < 1 THEN 8
                WHEN SUM(CAST(l.UTI_CORONARIANA_EXIST AS INT)) * 100000.0 / u.Populacao_Estimada < 2 THEN 5
                ELSE 2
            END +
            CASE 
                WHEN SUM(CAST(l.UTI_TOTAL_EXIST AS INT) - CAST(l.UTI_TOTAL_SUS AS INT)) >= 10 THEN 6
                WHEN SUM(CAST(l.UTI_TOTAL_EXIST AS INT) - CAST(l.UTI_TOTAL_SUS AS INT)) >= 5 THEN 3
                ELSE 0
            END) >= 20 THEN 'PRIORIDADE MÁXIMA'
        WHEN (CASE 
                WHEN SUM(CAST(l.UTI_TOTAL_SUS AS INT)) * 100000.0 / u.Populacao_Estimada < 5 THEN 10
                WHEN SUM(CAST(l.UTI_TOTAL_SUS AS INT)) * 100000.0 / u.Populacao_Estimada < 10 THEN 7
                ELSE 3
            END +
            CASE 
                WHEN SUM(CAST(l.UTI_CORONARIANA_EXIST AS INT)) * 100000.0 / u.Populacao_Estimada < 1 THEN 8
                WHEN SUM(CAST(l.UTI_CORONARIANA_EXIST AS INT)) * 100000.0 / u.Populacao_Estimada < 2 THEN 5
                ELSE 2
            END +
            CASE 
                WHEN SUM(CAST(l.UTI_TOTAL_EXIST AS INT) - CAST(l.UTI_TOTAL_SUS AS INT)) >= 10 THEN 6
                WHEN SUM(CAST(l.UTI_TOTAL_EXIST AS INT) - CAST(l.UTI_TOTAL_SUS AS INT)) >= 5 THEN 3
                ELSE 0
            END) >= 15 THEN 'ALTA PRIORIDADE'
        WHEN (CASE 
                WHEN SUM(CAST(l.UTI_TOTAL_SUS AS INT)) * 100000.0 / u.Populacao_Estimada < 5 THEN 10
                WHEN SUM(CAST(l.UTI_TOTAL_SUS AS INT)) * 100000.0 / u.Populacao_Estimada < 10 THEN 7
                ELSE 3
            END +
            CASE 
                WHEN SUM(CAST(l.UTI_CORONARIANA_EXIST AS INT)) * 100000.0 / u.Populacao_Estimada < 1 THEN 8
                WHEN SUM(CAST(l.UTI_CORONARIANA_EXIST AS INT)) * 100000.0 / u.Populacao_Estimada < 2 THEN 5
                ELSE 2
            END +
            CASE 
                WHEN SUM(CAST(l.UTI_TOTAL_EXIST AS INT) - CAST(l.UTI_TOTAL_SUS AS INT)) >= 10 THEN 6
                WHEN SUM(CAST(l.UTI_TOTAL_EXIST AS INT) - CAST(l.UTI_TOTAL_SUS AS INT)) >= 5 THEN 3
                ELSE 0
            END) >= 10 THEN 'MÉDIA PRIORIDADE'
        ELSE 'BAIXA PRIORIDADE'
    END AS Nivel_Prioridade,
    -- Métricas de referência
    ROUND(SUM(CAST(l.UTI_TOTAL_SUS AS INT)) * 100000.0 / u.Populacao_Estimada, 2) AS Leitos_SUS_por_100k,
    ROUND(SUM(CAST(l.UTI_CORONARIANA_EXIST AS INT)) * 100000.0 / u.Populacao_Estimada, 2) AS Leitos_Coronariana_por_100k,
    SUM(CAST(l.UTI_TOTAL_EXIST AS INT) - CAST(l.UTI_TOTAL_SUS AS INT)) AS Leitos_Ociosos_Total
FROM UF u
JOIN Hospital h ON u.Id_Uf = h.Id_Uf
JOIN Leito_UTI_Detalhe l ON h.Id_Hospital = l.Id_Hospital
WHERE u.Populacao_Estimada > 0
GROUP BY u.Sigla, u.Populacao_Estimada
ORDER BY Score_Prioridade DESC;





