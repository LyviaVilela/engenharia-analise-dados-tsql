-- ==================================
-- EXTRAÇÃO
-- ======================================
CREATE OR ALTER PROCEDURE sp_ETL_Extracao_Brasil_UFs
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        -- Drop da tabela staging se existir
        IF OBJECT_ID('Staging_Brasil_UFs', 'U') IS NOT NULL
            DROP TABLE Staging_Brasil_UFs;

        -- Criação da tabela staging
        CREATE TABLE Staging_Brasil_UFs(
            BRASIL_UNIDADES VARCHAR(100),
            POPULAÇÃO_ESTIMADA VARCHAR(50)
        );

        -- Realiza a snserção dos dados do arquivo CSV
        BULK INSERT Staging_Brasil_UFs
        FROM 'C:\Users\Lyvia\OneDrive\Desktop\te\estimativa_Brasil_UFs_2024.csv'
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = ',',
            ROWTERMINATOR = '\n',
            MAXERRORS = 1000,
            CODEPAGE = '65001'  -- UTF-8
        );
        
        PRINT 'Extração concluída: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros extraídos.';
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR('Erro extração: %s', @ErrorSeverity, @ErrorState, @ErrorMessage);
        RETURN -1;
    END CATCH
    
    RETURN 0;
END;
GO

-- PRECISA ANTES CRIAR --------------------------------------------------

ALTER TABLE Regiao
ADD Populacao_Estimada BIGINT NULL;

ALTER TABLE UF
ADD Populacao_Estimada BIGINT NULL;
GO
-- CASO CONTRARIO DA ERRO---------------------------------------

--==============================================
-- TRANSFORMAÇÃO
--===========================================
CREATE OR ALTER PROCEDURE sp_ETL_Transformacao_Brasil_UFs
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
       

        -- Remover vírgulas e aspas da população estimada
        UPDATE Staging_Brasil_UFs
        SET POPULAÇÃO_ESTIMADA = REPLACE(REPLACE(POPULAÇÃO_ESTIMADA, '"', ''), ',', '');

        -- Remover linhas indesejadas
        DELETE FROM Staging_Brasil_UFs 
        WHERE BRASIL_UNIDADES = 'NULL' 
           OR BRASIL_UNIDADES LIKE 'Fonte:%'
           OR BRASIL_UNIDADES IS NULL
           OR BRASIL_UNIDADES = '';

        -- Remover a linha de cabeçalho
        DELETE FROM Staging_Brasil_UFs 
        WHERE BRASIL_UNIDADES = 'BRASIL E UNIDADES DA FEDERAÇÃO';
        
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR('Erro na transformação: %s', @ErrorSeverity, @ErrorState, @ErrorMessage);
        RETURN -1;
    END CATCH
    
    RETURN 0;
END;
GO

--=======================================
------ LOAD 
--==========================
CREATE OR ALTER PROCEDURE sp_ETL_Load_Brasil_UFs
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        -- Atualizar população estimada nas regiões
        UPDATE Regiao
        SET Populacao_Estimada = CASE 
            WHEN UPPER(REPLACE(LTRIM(RTRIM(Nome)),'-','')) = 'NORTE' THEN 18669345
            WHEN UPPER(REPLACE(LTRIM(RTRIM(Nome)),'-','')) = 'NORDESTE' THEN 57112096
            WHEN UPPER(REPLACE(LTRIM(RTRIM(Nome)),'-','')) = 'SUDESTE' THEN 88617693
            WHEN UPPER(REPLACE(LTRIM(RTRIM(Nome)),'-','')) = 'SUL' THEN 31113021
            WHEN UPPER(REPLACE(LTRIM(RTRIM(Nome)),'-','')) IN ('CENTROOESTE','CENTRO-OESTE') THEN 17071595
        END
        WHERE Populacao_Estimada IS NULL
          AND UPPER(REPLACE(LTRIM(RTRIM(Nome)),'-','')) IN ('NORTE','NORDESTE','SUDESTE','SUL','CENTROOESTE','CENTRO-OESTE');

        -- Atualizar nomes e população estimada nas UFs
        UPDATE UF
        SET 
            Nome = CASE UPPER(LTRIM(RTRIM(Sigla)))
                WHEN 'RO' THEN N'Rondônia'
                WHEN 'AC' THEN N'Acre'
                WHEN 'AM' THEN N'Amazonas'
                WHEN 'RR' THEN N'Roraima'
                WHEN 'PA' THEN N'Pará'
                WHEN 'AP' THEN N'Amapá'
                WHEN 'TO' THEN N'Tocantins'
                WHEN 'MA' THEN N'Maranhão'
                WHEN 'PI' THEN N'Piauí'
                WHEN 'CE' THEN N'Ceará'
                WHEN 'RN' THEN N'Rio Grande do Norte'
                WHEN 'PB' THEN N'Paraíba'
                WHEN 'PE' THEN N'Pernambuco'
                WHEN 'AL' THEN N'Alagoas'
                WHEN 'SE' THEN N'Sergipe'
                WHEN 'BA' THEN N'Bahia'
                WHEN 'MG' THEN N'Minas Gerais'
                WHEN 'ES' THEN N'Espírito Santo'
                WHEN 'RJ' THEN N'Rio de Janeiro'
                WHEN 'SP' THEN N'São Paulo'
                WHEN 'PR' THEN N'Paraná'
                WHEN 'SC' THEN N'Santa Catarina'
                WHEN 'RS' THEN N'Rio Grande do Sul'
                WHEN 'MS' THEN N'Mato Grosso do Sul'
                WHEN 'MT' THEN N'Mato Grosso'
                WHEN 'GO' THEN N'Goiás'
                WHEN 'DF' THEN N'Distrito Federal'
                ELSE Nome
            END,
            Populacao_Estimada = CASE UPPER(LTRIM(RTRIM(Sigla)))
                WHEN 'RO' THEN 1746227
                WHEN 'AC' THEN 880631
                WHEN 'AM' THEN 4281209
                WHEN 'RR' THEN 716793
                WHEN 'PA' THEN 8664306
                WHEN 'AP' THEN 802837
                WHEN 'TO' THEN 1577342
                WHEN 'MA' THEN 7010960
                WHEN 'PI' THEN 3375646
                WHEN 'CE' THEN 9233656
                WHEN 'RN' THEN 3446071
                WHEN 'PB' THEN 4145040
                WHEN 'PE' THEN 9539029
                WHEN 'AL' THEN 3220104
                WHEN 'SE' THEN 2291077
                WHEN 'BA' THEN 14850513
                WHEN 'MG' THEN 21322691
                WHEN 'ES' THEN 4102129
                WHEN 'RJ' THEN 17219679
                WHEN 'SP' THEN 45973194
                WHEN 'PR' THEN 11824665
                WHEN 'SC' THEN 8058441
                WHEN 'RS' THEN 11229915
                WHEN 'MS' THEN 2901895
                WHEN 'MT' THEN 3836399
                WHEN 'GO' THEN 7350483
                WHEN 'DF' THEN 2982818
                ELSE Populacao_Estimada
            END
        WHERE UPPER(LTRIM(RTRIM(Sigla))) IN (
            'RO','AC','AM','RR','PA','AP','TO',
            'MA','PI','CE','RN','PB','PE','AL','SE','BA',
            'MG','ES','RJ','SP','PR','SC','RS','MS','MT','GO','DF'
        );

        COMMIT TRANSACTION;
       
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        RAISERROR('Erro no LOAD: %s', @ErrorSeverity, @ErrorState, @ErrorMessage);
        RETURN -1;
    END CATCH
    
    RETURN 0;
END;
GO
--=============================
----- PRINCIPAL TODO ETL ------
--=============================
CREATE OR ALTER PROCEDURE sp_ETL_Completo_Brasil_UFs
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ResultadoExtracao INT;
    DECLARE @ResultadoTransformacao INT;
    DECLARE @ResultadoLoad INT;
    
    BEGIN TRY
        
        
        -- Executar Extração
        EXEC @ResultadoExtracao = sp_ETL_Extracao_Brasil_UFs;
        
        IF @ResultadoExtracao <> 0
        BEGIN
            RAISERROR('Falha  Extração.', 16, 1);
            RETURN -1;
        END
        
        -- Executar Transformação
        EXEC @ResultadoTransformacao = sp_ETL_Transformacao_Brasil_UFs;
        
        IF @ResultadoTransformacao <> 0
        BEGIN
            RAISERROR('Falha Transformação.', 16, 1);
            RETURN -1;
        END
        
        -- Executar Load
        EXEC @ResultadoLoad = sp_ETL_Load_Brasil_UFs;
        
        IF @ResultadoLoad <> 0
        BEGIN
            RAISERROR('Falha LOAD.', 16, 1);
            RETURN -1;
        END
        
        PRINT 'Processo ETL FINALIZOU!';
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        DECLARE @ErrorSeverity INT = ERROR_SEVERITY();
        DECLARE @ErrorState INT = ERROR_STATE();
        
        PRINT 'Erro no ETL: ' + @ErrorMessage;
        RAISERROR(@ErrorMessage, @ErrorSeverity, @ErrorState);
        RETURN -1;
    END CATCH
END;
GO



--==================================
-- EXECUÇÃO PASSO A PASSO 
--==========================

-- Apenas extração
EXEC sp_ETL_Extracao_Brasil_UFs;

-- PRECISA CRIAR ANTES DA TRANSFORMAÇÃO SE NÃO DA ERRO-------
ALTER TABLE Regiao
ADD Populacao_Estimada BIGINT NULL;

ALTER TABLE UF
ADD Populacao_Estimada BIGINT NULL;
GO
--------------------------------------------------------------

-- Apenas transformação
EXEC sp_ETL_Transformacao_Brasil_UFs;

-- Apenas carga
EXEC sp_ETL_Load_Brasil_UFs;

-- teste
SELECT * FROM UF
SELECT * FROM Regiao





---------------------------------------------------------------------------------
-- EXECUÇÃO DO ETL COMPLETO 
--===========================
EXEC sp_ETL_Completo_Brasil_UFs;

