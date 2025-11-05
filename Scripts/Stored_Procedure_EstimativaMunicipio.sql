CREATE OR ALTER PROCEDURE SP_ETL_Estimativa_Municipio
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        BEGIN TRANSACTION;

        PRINT '🚀 Iniciando ETL de Estimativa Municipal...';

        ------------------------------------------------------------------
        -- 1️ EXTRAÇÃO 
        ------------------------------------------------------------------
        PRINT '📂 Extraindo dados do CSV...';

        -- ✅ CORREÇÃO: Usar tabela temporária GLOBAL
        IF OBJECT_ID('tempdb..##Staging_Estimativa_Municipio', 'U') IS NOT NULL
            DROP TABLE ##Staging_Estimativa_Municipio;

        CREATE TABLE ##Staging_Estimativa_Municipio (
            UF VARCHAR(10),              
            COD_UF VARCHAR(10),
            COD_MUNICIPIO VARCHAR(20),
            NOME_MUNICIPIO VARCHAR(200),
            POPULACAO_ESTIMADA VARCHAR(50)
        );

        -- BULK INSERT
        BULK INSERT ##Staging_Estimativa_Municipio
        FROM 'C:\Users\Lyvia\OneDrive\Desktop\temps\estimativa_municipio_2024.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            MAXERRORS = 1000,
            CODEPAGE = '65001'  
        );

        DECLARE @LinhasCarregadas INT = (SELECT COUNT(*) FROM ##Staging_Estimativa_Municipio);
        PRINT '📥 Dados carregados: ' + CAST(@LinhasCarregadas AS VARCHAR) + ' registros';

        ------------------------------------------------------------------
        -- 2️ TRANSFORMAÇÃO 
        ------------------------------------------------------------------
        PRINT '⚙️ Transformando dados...';

        -- Limpeza e padronização
        UPDATE ##Staging_Estimativa_Municipio
        SET 
            UF = LTRIM(RTRIM(UF)),
            COD_UF = LTRIM(RTRIM(COD_UF)),
            COD_MUNICIPIO = LTRIM(RTRIM(COD_MUNICIPIO)),
            NOME_MUNICIPIO = UPPER(LTRIM(RTRIM(NOME_MUNICIPIO))),
            POPULACAO_ESTIMADA = REPLACE(REPLACE(POPULACAO_ESTIMADA, '"', ''), ',', '');

        -- Remove linhas inválidas
        DELETE FROM ##Staging_Estimativa_Municipio
        WHERE POPULACAO_ESTIMADA IS NULL
           OR NOME_MUNICIPIO IS NULL
           OR COD_MUNICIPIO IS NULL 
           OR UF IS NULL
           OR UF LIKE 'Fonte:%'
           OR TRY_CAST(POPULACAO_ESTIMADA AS BIGINT) IS NULL;

        PRINT '✅ Dados transformados: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros limpos';

        ------------------------------------------------------------------
        -- 3️ LOAD - ATUALIZAR UF COM COD_UF
        ------------------------------------------------------------------
        PRINT '💾 Atualizando códigos das UFs...';

        UPDATE u
        SET u.COD_UF = s.COD_UF
        FROM UF u
        INNER JOIN (
            SELECT DISTINCT UF, COD_UF
            FROM ##Staging_Estimativa_Municipio
            WHERE COD_UF IS NOT NULL
        ) s ON LTRIM(RTRIM(s.UF)) = u.Sigla;

        PRINT '✅ Códigos de UF atualizados: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros';

        ------------------------------------------------------------------
        -- 4️ LOAD - ATUALIZAR MUNICÍPIOS EXISTENTES
        ------------------------------------------------------------------
        PRINT '💾 Atualizando municípios existentes...';

        UPDATE M
        SET 
            M.Cod_Municipio = S.COD_MUNICIPIO,
            M.Populacao_Estimada = TRY_CAST(S.POPULACAO_ESTIMADA AS BIGINT)
        FROM Municipio M
        INNER JOIN UF U ON U.Id_Uf = M.Id_Uf
        INNER JOIN ##Staging_Estimativa_Municipio S
            ON M.Nome = S.NOME_MUNICIPIO  -- Já está em uppercase
            AND U.Sigla = S.UF;           -- Já está limpo

        DECLARE @MunicipiosAtualizados INT = @@ROWCOUNT;
        PRINT '✅ Municípios atualizados: ' + CAST(@MunicipiosAtualizados AS VARCHAR) + ' registros';

        ------------------------------------------------------------------
        -- 5️ LOAD - INSERIR NOVOS MUNICÍPIOS (SE NECESSÁRIO)
        ------------------------------------------------------------------
        PRINT '💾 Inserindo novos municípios...';

        INSERT INTO Municipio (Id_Uf, Nome, Cod_Municipio, Populacao_Estimada)
        SELECT 
            U.Id_Uf,
            S.NOME_MUNICIPIO,
            S.COD_MUNICIPIO,
            TRY_CAST(S.POPULACAO_ESTIMADA AS BIGINT)
        FROM ##Staging_Estimativa_Municipio S
        INNER JOIN UF U ON U.Sigla = S.UF
        WHERE NOT EXISTS (
            SELECT 1 FROM Municipio M 
            WHERE M.Nome = S.NOME_MUNICIPIO 
            AND M.Id_Uf = U.Id_Uf
        );

        DECLARE @NovosMunicipios INT = @@ROWCOUNT;
        PRINT '✅ Novos municípios inseridos: ' + CAST(@NovosMunicipios AS VARCHAR) + ' registros';

        ------------------------------------------------------------------
        -- 6️ VERIFICAÇÃO FINAL
        ------------------------------------------------------------------
        PRINT '📊 Resumo do processamento:';
        
        DECLARE @TotalMunicipios INT = (SELECT COUNT(*) FROM Municipio WHERE Populacao_Estimada IS NOT NULL);
        DECLARE @TotalUFs INT = (SELECT COUNT(*) FROM UF WHERE COD_UF IS NOT NULL);
        
        PRINT '🏙️ Municípios com população: ' + CAST(@TotalMunicipios AS VARCHAR);
        PRINT '🏛️ UFs com código: ' + CAST(@TotalUFs AS VARCHAR);
        PRINT '🔄 Municípios atualizados: ' + CAST(@MunicipiosAtualizados AS VARCHAR);
        PRINT '🆕 Novos municípios: ' + CAST(@NovosMunicipios AS VARCHAR);

        -- Limpeza
        DROP TABLE ##Staging_Estimativa_Municipio;
        
        COMMIT TRANSACTION;
        
        PRINT '🏁 ETL de Municípios concluído com SUCESSO!';

    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION;
        
        IF OBJECT_ID('tempdb..##Staging_Estimativa_Municipio', 'U') IS NOT NULL
            DROP TABLE ##Staging_Estimativa_Municipio;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT '❌ Erro no ETL: ' + @ErrorMessage;
        RAISERROR('Erro no ETL de Municípios: %s', 16, 1, @ErrorMessage);
    END CATCH
END
GO

-- Executar
PRINT 'Executando ETL de municípios...';
EXEC SP_ETL_Estimativa_Municipio;
