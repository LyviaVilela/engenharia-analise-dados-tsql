--==================================
---- EXTRAÇÃO ----------------------
--==================================
CREATE OR ALTER PROCEDURE sp_ETL_Extracao_Municipios
AS
BEGIN
    SET NOCOUNT ON;

    BEGIN TRY
        
        -- Apagar se já existe
        IF OBJECT_ID('Staging_Estimativa_Municipio', 'U') IS NOT NULL
            DROP TABLE Staging_Estimativa_Municipio;

        -- Criação da tabela com mais espaço
        CREATE TABLE Staging_Estimativa_Municipio (
            UF VARCHAR(100),              
            COD_UF VARCHAR(100),
            COD_MUNICIPIO VARCHAR(100),
            NOME_MUNICIPIO VARCHAR(200),
            POPULACAO_ESTIMADA VARCHAR(500)
        );

        PRINT 'Tabela criada';

        -- Bulk Insert
        BULK INSERT Staging_Estimativa_Municipio
        FROM 'C:\Users\Lyvia\OneDrive\Desktop\temps\estimativa_municipio_2024.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            MAXERRORS = 1000,
            CODEPAGE = '65001'  
        );

        PRINT 'Dados carregados: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros extraídos.';
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Ocorreu um erro EX. munici: %s', 16, 1, @ErrorMessage);
        RETURN -1;
    END CATCH
    
    RETURN 0;
END;
GO

-- PRECISA CRIAR ANTES SE NÃO DA ERRO
	ALTER TABLE dbo.UF
    ADD Cod_Uf VARCHAR(10) NULL;

	ALTER TABLE dbo.Municipio
    ADD Cod_Municipio VARCHAR(20) NULL;

--=====================================
-------------TRANSFORMAÇÃO ------------
--=====================================
CREATE OR ALTER PROCEDURE sp_ETL_Transformacao_Municipios
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        
        -- Adicionar colunas se não existirem
        IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('UF') AND name = 'Cod_Uf')
            ALTER TABLE dbo.UF ADD Cod_Uf VARCHAR(10) NULL;

        IF NOT EXISTS(SELECT 1 FROM sys.columns WHERE object_id = OBJECT_ID('Municipio') AND name = 'Cod_Municipio')
            ALTER TABLE dbo.Municipio ADD Cod_Municipio VARCHAR(20) NULL;

        -- Limpar e converter população estimada
        UPDATE Staging_Estimativa_Municipio
        SET POPULACAO_ESTIMADA = TRY_CAST(REPLACE(REPLACE(POPULACAO_ESTIMADA,'"',''),',','') AS BIGINT);

        -- Remove linhas inválidas
        DELETE FROM Staging_Estimativa_Municipio
        WHERE POPULACAO_ESTIMADA IS NULL
           OR NOME_MUNICIPIO IS NULL
           OR COD_MUNICIPIO IS NULL 
           OR UF IS NULL
           OR UF LIKE 'Fonte:%';

        -- Padronizar nomes para maiúsculo
        UPDATE Staging_Estimativa_Municipio
        SET NOME_MUNICIPIO = UPPER(NOME_MUNICIPIO);

        PRINT 'Transformação FINALIZOU.';
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Erro na transformação: %s', 16, 1, @ErrorMessage);
        RETURN -1;
    END CATCH
    
    RETURN 0;
END;
GO
--==============================
-------------LOAD --------------
--=============================
CREATE OR ALTER PROCEDURE sp_ETL_Load_Municipios
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- 1. Atualizar população estimada nos municípios existentes
        UPDATE m
        SET 
            m.Populacao_Estimada = TRY_CAST(
                REPLACE(REPLACE(REPLACE(LTRIM(RTRIM(s.POPULACAO_ESTIMADA)), '.', ''), ',', ''), ' ', '') 
                AS BIGINT
            )
        FROM Municipio m
        INNER JOIN UF u 
            ON u.Id_Uf = m.Id_Uf
        INNER JOIN Staging_Estimativa_Municipio s
            ON LOWER(LTRIM(RTRIM(m.Nome))) = LOWER(LTRIM(RTRIM(s.NOME_MUNICIPIO)))
           AND u.Sigla = LTRIM(RTRIM(s.UF));


        -- 2. Atualizar código e população dos municípios existentes
        UPDATE M
        SET 
            M.Cod_Municipio = S.COD_MUNICIPIO,
            M.Populacao_Estimada = TRY_CAST(S.POPULACAO_ESTIMADA AS BIGINT)
        FROM Municipio M
        INNER JOIN Staging_Estimativa_Municipio S
            ON UPPER(LTRIM(RTRIM(M.Nome))) = UPPER(LTRIM(RTRIM(S.NOME_MUNICIPIO)))
        WHERE S.COD_MUNICIPIO IS NOT NULL;

        PRINT 'Códigos atualizados: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';

        -- 3. Atualizar código UF na tabela UF
        UPDATE u
        SET u.Cod_Uf = s.COD_UF
        FROM UF u
        INNER JOIN (
            SELECT DISTINCT UF, COD_UF
            FROM Staging_Estimativa_Municipio
            WHERE COD_UF IS NOT NULL
        ) s
            ON LTRIM(RTRIM(s.UF)) = u.Sigla;

        PRINT 'Códigos de UF: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';

        COMMIT TRANSACTION;
  
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Erro nO LOAD : %s', 16, 1, @ErrorMessage);
        RETURN -1;
    END CATCH
    
    RETURN 0;
END;
GO
--==========================================
-------------ETL COMPLETO-----------------
--==========================================
CREATE OR ALTER PROCEDURE sp_ETL_Completo_Municipios
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ResultadoExtracao INT;
    DECLARE @ResultadoTransformacao INT;
    DECLARE @ResultadoLoad INT;
    
    BEGIN TRY
        
        -- Executar Extração
        EXEC @ResultadoExtracao = sp_ETL_Extracao_Municipios;
        IF @ResultadoExtracao <> 0
        BEGIN
            RAISERROR('Falha na Extração.', 16, 1);
            RETURN -1;
        END
        
        -- Executar Transformação
        EXEC @ResultadoTransformacao = sp_ETL_Transformacao_Municipios;
        IF @ResultadoTransformacao <> 0
        BEGIN
            RAISERROR('Falha na Transformação.', 16, 1);
            RETURN -1;
        END
        
        -- Executar Load
        EXEC @ResultadoLoad = sp_ETL_Load_Municipios;
        IF @ResultadoLoad <> 0
        BEGIN
            RAISERROR('Falha no Load.', 16, 1);
            RETURN -1;
        END
        
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT 'Erro no ETL: ' + @ErrorMessage;
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END;
GO


--=========================
-- EXECUTAR PASSO A PASSO
--========================

-- Apenas extração
EXEC sp_ETL_Extracao_Municipios;

-- PRECISA CRIAR ANTES DA TRANSFORMAÇÃO SE NÃO DA ERRO----------
	ALTER TABLE dbo.UF
    ADD Cod_Uf VARCHAR(10) NULL;

	ALTER TABLE dbo.Municipio
    ADD Cod_Municipio VARCHAR(20) NULL;
-------------------------------------------------

-- Apenas transformação  
EXEC sp_ETL_Transformacao_Municipios;

-- Apenas carga
EXEC sp_ETL_Load_Municipios;




--========================
--EXECUTAR TUDO DE UMA VEZ
--=======================
EXEC sp_ETL_Completo_Municipios;
