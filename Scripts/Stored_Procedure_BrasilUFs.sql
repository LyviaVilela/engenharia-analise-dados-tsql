CREATE OR ALTER PROCEDURE SP_ETL_Brasil_Populacao
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        PRINT '🚀 Iniciando ETL de População do Brasil...';

        ------------------------------------------------------------------
        -- 1️ EXTRAÇÃO 
        ------------------------------------------------------------------
        PRINT '📂 Extraindo dados do CSV...';
        
        IF OBJECT_ID('tempdb..##Staging_Brasil_UFs', 'U') IS NOT NULL
            DROP TABLE ##Staging_Brasil_UFs;

        CREATE TABLE ##Staging_Brasil_UFs(
            BRASIL_UNIDADES VARCHAR(100),
            POPULACAO_ESTIMADA VARCHAR(50)
        );

        BULK INSERT ##Staging_Brasil_UFs
        FROM 'C:\Users\Lyvia\OneDrive\Desktop\te\estimativa_Brasil_UFs_2024.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            MAXERRORS = 1000,
            CODEPAGE = '65001'
        );

        -- Verifica se dados foram carregados
        DECLARE @LinhasCarregadas INT = (SELECT COUNT(*) FROM ##Staging_Brasil_UFs);
        PRINT '📥 Dados carregados: ' + CAST(@LinhasCarregadas AS VARCHAR) + ' registros';
        
        -- Mostra primeiras linhas para debug
        PRINT '📋 Primeiros registros carregados:';
        SELECT TOP 5 BRASIL_UNIDADES, POPULACAO_ESTIMADA 
        FROM ##Staging_Brasil_UFs;

        ------------------------------------------------------------------
        -- 2️ TRANSFORMAÇÃO
        ------------------------------------------------------------------
        PRINT '⚙️ Transformando dados...';

        -- Remove aspas e vírgulas
        UPDATE ##Staging_Brasil_UFs
        SET POPULACAO_ESTIMADA = REPLACE(REPLACE(POPULACAO_ESTIMADA, '"', ''), ',', '');

        -- Remove linhas indesejadas
        DELETE FROM ##Staging_Brasil_UFs 
        WHERE BRASIL_UNIDADES = 'NULL' 
           OR BRASIL_UNIDADES LIKE 'Fonte:%'
           OR BRASIL_UNIDADES IS NULL
           OR BRASIL_UNIDADES = ''
           OR BRASIL_UNIDADES = 'BRASIL E UNIDADES DA FEDERAÇÃO';

        PRINT '✅ Dados transformados: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros limpos';

        ------------------------------------------------------------------
        -- 3️ LOAD - ATUALIZAR REGIÕES COM DADOS REAIS DO CSV
        ------------------------------------------------------------------
        PRINT '💾 Atualizando populações das Regiões...';

        UPDATE R
        SET Populacao_Estimada = S.TotalPopulacao
        FROM Regiao R
        INNER JOIN (
            SELECT 
                CASE 
                    WHEN BRASIL_UNIDADES IN ('Rondônia','Acre','Amazonas','Roraima','Pará','Amapá','Tocantins') THEN 'NORTE'
                    WHEN BRASIL_UNIDADES IN ('Maranhão','Piauí','Ceará','Rio Grande do Norte','Paraíba','Pernambuco','Alagoas','Sergipe','Bahia') THEN 'NORDESTE'
                    WHEN BRASIL_UNIDADES IN ('Minas Gerais','Espírito Santo','Rio de Janeiro','São Paulo') THEN 'SUDESTE'
                    WHEN BRASIL_UNIDADES IN ('Paraná','Santa Catarina','Rio Grande do Sul') THEN 'SUL'
                    WHEN BRASIL_UNIDADES IN ('Mato Grosso','Mato Grosso do Sul','Goiás','Distrito Federal') THEN 'CENTRO-OESTE'
                END AS RegiaoNome,
                SUM(CAST(POPULACAO_ESTIMADA AS BIGINT)) AS TotalPopulacao
            FROM ##Staging_Brasil_UFs
            WHERE BRASIL_UNIDADES != 'Brasil'
            GROUP BY 
                CASE 
                    WHEN BRASIL_UNIDADES IN ('Rondônia','Acre','Amazonas','Roraima','Pará','Amapá','Tocantins') THEN 'NORTE'
                    WHEN BRASIL_UNIDADES IN ('Maranhão','Piauí','Ceará','Rio Grande do Norte','Paraíba','Pernambuco','Alagoas','Sergipe','Bahia') THEN 'NORDESTE'
                    WHEN BRASIL_UNIDADES IN ('Minas Gerais','Espírito Santo','Rio de Janeiro','São Paulo') THEN 'SUDESTE'
                    WHEN BRASIL_UNIDADES IN ('Paraná','Santa Catarina','Rio Grande do Sul') THEN 'SUL'
                    WHEN BRASIL_UNIDADES IN ('Mato Grosso','Mato Grosso do Sul','Goiás','Distrito Federal') THEN 'CENTRO-OESTE'
                END
        ) S ON R.Nome = S.RegiaoNome;

        PRINT '✅ Regiões atualizadas: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros';

        ------------------------------------------------------------------
        -- 4️ LOAD - ATUALIZAR UFs COM DADOS REAIS DO CSV
        ------------------------------------------------------------------
        PRINT '💾 Atualizando populações das UFs...';

        UPDATE U
        SET 
            Nome = S.BRASIL_UNIDADES,
            Populacao_Estimada = CAST(S.POPULACAO_ESTIMADA AS BIGINT)
        FROM UF U
        INNER JOIN ##Staging_Brasil_UFs S ON 
            CASE S.BRASIL_UNIDADES
                WHEN 'Rondônia' THEN 'RO'
                WHEN 'Acre' THEN 'AC' 
                WHEN 'Amazonas' THEN 'AM'
                WHEN 'Roraima' THEN 'RR'
                WHEN 'Pará' THEN 'PA'
                WHEN 'Amapá' THEN 'AP'
                WHEN 'Tocantins' THEN 'TO'
                WHEN 'Maranhão' THEN 'MA'
                WHEN 'Piauí' THEN 'PI'
                WHEN 'Ceará' THEN 'CE'
                WHEN 'Rio Grande do Norte' THEN 'RN'
                WHEN 'Paraíba' THEN 'PB'
                WHEN 'Pernambuco' THEN 'PE'
                WHEN 'Alagoas' THEN 'AL'
                WHEN 'Sergipe' THEN 'SE'
                WHEN 'Bahia' THEN 'BA'
                WHEN 'Minas Gerais' THEN 'MG'
                WHEN 'Espírito Santo' THEN 'ES'
                WHEN 'Rio de Janeiro' THEN 'RJ'
                WHEN 'São Paulo' THEN 'SP'
                WHEN 'Paraná' THEN 'PR'
                WHEN 'Santa Catarina' THEN 'SC'
                WHEN 'Rio Grande do Sul' THEN 'RS'
                WHEN 'Mato Grosso' THEN 'MT'
                WHEN 'Mato Grosso do Sul' THEN 'MS'
                WHEN 'Goiás' THEN 'GO'
                WHEN 'Distrito Federal' THEN 'DF'
            END = U.Sigla
        WHERE S.BRASIL_UNIDADES != 'Brasil';

        PRINT '✅ UFs atualizadas: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros';

        ------------------------------------------------------------------
        -- 5️ VERIFICAÇÃO FINAL
        ------------------------------------------------------------------
        PRINT '📊 Resumo do processamento:';
        
        DECLARE @TotalRegioes INT = (SELECT COUNT(*) FROM Regiao WHERE Populacao_Estimada IS NOT NULL);
        DECLARE @TotalUFs INT = (SELECT COUNT(*) FROM UF WHERE Populacao_Estimada IS NOT NULL);
        
        PRINT '🏛️ Regiões com população: ' + CAST(@TotalRegioes AS VARCHAR);
        PRINT '🏙️ UFs com população: ' + CAST(@TotalUFs AS VARCHAR);

        -- Limpeza
        DROP TABLE ##Staging_Brasil_UFs;
        
        COMMIT TRANSACTION;
        
        PRINT '🏁 ETL de População concluído com SUCESSO!';

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        IF OBJECT_ID('tempdb..##Staging_Brasil_UFs', 'U') IS NOT NULL
            DROP TABLE ##Staging_Brasil_UFs;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '❌ Erro no ETL: ' + @ErrorMessage;
        RAISERROR('Erro no ETL de População: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO

-- Executar
PRINT 'Executando ETL de população...';
EXEC SP_ETL_Brasil_Populacao;


SELECT * FROM Municipio