--===================================
-- EXTRAÇÃO
--===============================
CREATE OR ALTER PROCEDURE sp_ETL_Extracao_Leitos
    @CaminhoArquivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        PRINT ' extração de leitos ';
        
        -- Drop da tabela staging se existir
        IF OBJECT_ID('Staging_Leitos_Hospitais', 'U') IS NOT NULL
            DROP TABLE Staging_Leitos_Hospitais;
        
        -- Criação da tabela staging
        CREATE TABLE Staging_Leitos_Hospitais (
            COMP VARCHAR(100),
            REGIAO VARCHAR(100),
            UF VARCHAR(100),
            MUNICIPIO VARCHAR(200),
            MOTIVO_DESABILITACAO VARCHAR(500),
            CNES VARCHAR(100),
            NOME_ESTABELECIMENTO VARCHAR(500),
            RAZAO_SOCIAL VARCHAR(500),
            TP_GESTAO VARCHAR(100),
            CO_TIPO_UNIDADE VARCHAR(100),
            DS_TIPO_UNIDADE VARCHAR(200),
            NATUREZA_JURIDICA VARCHAR(100),
            DESC_NATUREZA_JURIDICA VARCHAR(200),
            NO_LOGRADOURO VARCHAR(500),
            NU_ENDERECO VARCHAR(100),
            NO_COMPLEMENTO VARCHAR(500),
            NO_BAIRRO VARCHAR(200),
            CO_CEP VARCHAR(100),
            NU_TELEFONE VARCHAR(100),
            NO_EMAIL VARCHAR(300),
            LEITOS_EXISTENTES VARCHAR(100),
            LEITOS_SUS VARCHAR(100),
            UTI_TOTAL_EXIST VARCHAR(100),
            UTI_TOTAL_SUS VARCHAR(100),
            UTI_ADULTO_EXIST VARCHAR(100),
            UTI_ADULTO_SUS VARCHAR(100),
            UTI_PEDIATRICO_EXIST VARCHAR(100),
            UTI_PEDIATRICO_SUS VARCHAR(100),
            UTI_NEONATAL_EXIST VARCHAR(100),
            UTI_NEONATAL_SUS VARCHAR(100),
            UTI_QUEIMADO_EXIST VARCHAR(100),
            UTI_QUEIMADO_SUS VARCHAR(100),
            UTI_CORONARIANA_EXIST VARCHAR(100),
            UTI_CORONARIANA_SUS VARCHAR(100)
		
        );
        
        PRINT 'Tabela foi criada!';
        
        -- Bulk Insert
        DECLARE @SqlQuery NVARCHAR(MAX);
        SET @SqlQuery = '
        BULK INSERT Staging_Leitos_Hospitais
        FROM ''' + @CaminhoArquivo + '''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''0x0a'',
            MAXERRORS = 1000
        )';
        EXEC sp_executesql @SqlQuery;
        
        DECLARE @LinhasCarregadas INT;
        SELECT @LinhasCarregadas = COUNT(*) FROM Staging_Leitos_Hospitais;
        PRINT 'Total : ' + CAST(@LinhasCarregadas AS VARCHAR) + ' registros.';
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Erro na extração: %s', 16, 1, @ErrorMessage);
        RETURN -1;
    END CATCH
    
    RETURN 0;
END;
GO


--===================================
-- TRANSFORMAÇÃO
--===============================
CREATE OR ALTER PROCEDURE sp_ETL_Transformacao_Leitos
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY

        -- =============================================
        -- LIMPEZA INICIAL - REMOÇÃO DE ASPAS
        -- =============================================
        PRINT 'Iniciando remoção de aspas...';
        UPDATE Staging_Leitos_Hospitais
        SET
            COMP = REPLACE(COMP, '"', ''),
            REGIAO = REPLACE(REGIAO, '"', ''),
            UF = REPLACE(UF, '"', ''),
            MUNICIPIO = REPLACE(MUNICIPIO, '"', ''),
            MOTIVO_DESABILITACAO = REPLACE(MOTIVO_DESABILITACAO, '"', ''),
            CNES = REPLACE(CNES, '"', ''),
            NOME_ESTABELECIMENTO = REPLACE(NOME_ESTABELECIMENTO, '"', ''),
            RAZAO_SOCIAL = REPLACE(RAZAO_SOCIAL, '"', ''),
            TP_GESTAO = REPLACE(TP_GESTAO, '"', ''),
            CO_TIPO_UNIDADE = REPLACE(CO_TIPO_UNIDADE, '"', ''),
            DS_TIPO_UNIDADE = REPLACE(DS_TIPO_UNIDADE, '"', ''),
            NATUREZA_JURIDICA = REPLACE(NATUREZA_JURIDICA, '"', ''),
            DESC_NATUREZA_JURIDICA = REPLACE(DESC_NATUREZA_JURIDICA, '"', ''),
            NO_LOGRADOURO = REPLACE(NO_LOGRADOURO, '"', ''),
            NU_ENDERECO = REPLACE(NU_ENDERECO, '"', ''),
            NO_COMPLEMENTO = REPLACE(NO_COMPLEMENTO, '"', ''),
            NO_BAIRRO = REPLACE(NO_BAIRRO, '"', ''),
            CO_CEP = REPLACE(CO_CEP, '"', ''),
            NU_TELEFONE = REPLACE(NU_TELEFONE, '"', ''),
            NO_EMAIL = REPLACE(NO_EMAIL, '"', ''),
            LEITOS_EXISTENTES = REPLACE(LEITOS_EXISTENTES, '"', ''),
            LEITOS_SUS = REPLACE(LEITOS_SUS, '"', ''),
            UTI_TOTAL_EXIST = REPLACE(UTI_TOTAL_EXIST, '"', ''),
            UTI_TOTAL_SUS = REPLACE(UTI_TOTAL_SUS, '"', ''),
            UTI_ADULTO_EXIST = REPLACE(UTI_ADULTO_EXIST, '"', ''),
            UTI_ADULTO_SUS = REPLACE(UTI_ADULTO_SUS, '"', ''),
            UTI_PEDIATRICO_EXIST = REPLACE(UTI_PEDIATRICO_EXIST, '"', ''),
            UTI_PEDIATRICO_SUS = REPLACE(UTI_PEDIATRICO_SUS, '"', ''),
            UTI_NEONATAL_EXIST = REPLACE(UTI_NEONATAL_EXIST, '"', ''),
            UTI_NEONATAL_SUS = REPLACE(UTI_NEONATAL_SUS, '"', ''),
            UTI_QUEIMADO_EXIST = REPLACE(UTI_QUEIMADO_EXIST, '"', ''),
            UTI_QUEIMADO_SUS = REPLACE(UTI_QUEIMADO_SUS, '"', ''),
            UTI_CORONARIANA_EXIST = REPLACE(UTI_CORONARIANA_EXIST, '"', ''),
            UTI_CORONARIANA_SUS = REPLACE(UTI_CORONARIANA_SUS, '"', '');
        
        -- =============================================
        --  NORMALIZAÇÃO DE CAMPOS NUMÉRICOS
        -- =============================================
        UPDATE Staging_Leitos_Hospitais
        SET 
            LEITOS_EXISTENTES = CASE WHEN TRY_CAST(LEITOS_EXISTENTES AS INT) IS NOT NULL THEN LEITOS_EXISTENTES ELSE NULL END,
            LEITOS_SUS = CASE WHEN TRY_CAST(LEITOS_SUS AS INT) IS NOT NULL THEN LEITOS_SUS ELSE NULL END,
            UTI_TOTAL_EXIST = CASE WHEN TRY_CAST(UTI_TOTAL_EXIST AS INT) IS NOT NULL THEN UTI_TOTAL_EXIST ELSE NULL END,
            UTI_TOTAL_SUS = CASE WHEN TRY_CAST(UTI_TOTAL_SUS AS INT) IS NOT NULL THEN UTI_TOTAL_SUS ELSE NULL END,
            UTI_ADULTO_EXIST = CASE WHEN TRY_CAST(UTI_ADULTO_EXIST AS INT) IS NOT NULL THEN UTI_ADULTO_EXIST ELSE NULL END,
            UTI_ADULTO_SUS = CASE WHEN TRY_CAST(UTI_ADULTO_SUS AS INT) IS NOT NULL THEN UTI_ADULTO_SUS ELSE NULL END,
            UTI_PEDIATRICO_EXIST = CASE WHEN TRY_CAST(UTI_PEDIATRICO_EXIST AS INT) IS NOT NULL THEN UTI_PEDIATRICO_EXIST ELSE NULL END,
            UTI_PEDIATRICO_SUS = CASE WHEN TRY_CAST(UTI_PEDIATRICO_SUS AS INT) IS NOT NULL THEN UTI_PEDIATRICO_SUS ELSE NULL END,
            UTI_NEONATAL_EXIST = CASE WHEN TRY_CAST(UTI_NEONATAL_EXIST AS INT) IS NOT NULL THEN UTI_NEONATAL_EXIST ELSE NULL END,
            UTI_NEONATAL_SUS = CASE WHEN TRY_CAST(UTI_NEONATAL_SUS AS INT) IS NOT NULL THEN UTI_NEONATAL_SUS ELSE NULL END,
            UTI_QUEIMADO_EXIST = CASE WHEN TRY_CAST(UTI_QUEIMADO_EXIST AS INT) IS NOT NULL THEN UTI_QUEIMADO_EXIST ELSE NULL END,
            UTI_QUEIMADO_SUS = CASE WHEN TRY_CAST(UTI_QUEIMADO_SUS AS INT) IS NOT NULL THEN UTI_QUEIMADO_SUS ELSE NULL END,
            UTI_CORONARIANA_EXIST = CASE WHEN TRY_CAST(UTI_CORONARIANA_EXIST AS INT) IS NOT NULL THEN UTI_CORONARIANA_EXIST ELSE NULL END,
            UTI_CORONARIANA_SUS = CASE WHEN TRY_CAST(UTI_CORONARIANA_SUS AS INT) IS NOT NULL THEN UTI_CORONARIANA_SUS ELSE NULL END;
        
        -- =============================================
        -- TRATAMENTO DE EMAILS
        -- =============================================
 
        IF COL_LENGTH('Staging_Leitos_Hospitais', 'EMAIL_INVALIDO') IS NULL
        BEGIN
            ALTER TABLE Staging_Leitos_Hospitais
            ADD EMAIL_INVALIDO BIT DEFAULT 0;
        END
        
        UPDATE Staging_Leitos_Hospitais
        SET NO_EMAIL = LOWER(TRIM(NO_EMAIL));
        
        UPDATE Staging_Leitos_Hospitais
        SET NO_EMAIL = CASE 
            WHEN NO_EMAIL LIKE '%@gmailcom' THEN REPLACE(NO_EMAIL, '@gmailcom', '@gmail.com')
            WHEN NO_EMAIL LIKE '%@hotmail%' AND NO_EMAIL NOT LIKE '%.com%' THEN NO_EMAIL + '.com'
            WHEN NO_EMAIL LIKE '%@yahoo%' AND NO_EMAIL NOT LIKE '%.com.br%' AND NO_EMAIL NOT LIKE '%.com%' THEN NO_EMAIL + '.com.br'
            WHEN NO_EMAIL LIKE '%@%' AND NO_EMAIL NOT LIKE '%.%' THEN NO_EMAIL + '.com.br'
            ELSE NO_EMAIL
        END
        WHERE NO_EMAIL IS NOT NULL;
        
        UPDATE Staging_Leitos_Hospitais
        SET 
            EMAIL_INVALIDO = CASE 
                WHEN NO_EMAIL IS NULL OR NO_EMAIL NOT LIKE '%_@_%._%' OR NO_EMAIL LIKE '% %' THEN 1
                ELSE 0
            END,
            NO_EMAIL = CASE 
                WHEN NO_EMAIL IS NULL OR NO_EMAIL NOT LIKE '%_@_%._%' OR NO_EMAIL LIKE '% %' THEN NULL
                ELSE NO_EMAIL
            END;
        
        -- =============================================
        -- TRATAMENTO DE TELEFONES
        -- =============================================
     
        IF COL_LENGTH('Staging_Leitos_Hospitais', 'TELEFONE_INVALIDO') IS NULL
        BEGIN
            ALTER TABLE Staging_Leitos_Hospitais
            ADD TELEFONE_INVALIDO BIT DEFAULT 0;
        END
        
        UPDATE Staging_Leitos_Hospitais
        SET NU_TELEFONE = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
            REPLACE(NU_TELEFONE, '(', ''), ')', ''), '-', ''), '/', ''), ' ', ''), '.', '');
        
        UPDATE Staging_Leitos_Hospitais
        SET NU_TELEFONE = CASE 
            WHEN CHARINDEX('/', NU_TELEFONE) > 0 
            THEN LEFT(NU_TELEFONE, CHARINDEX('/', NU_TELEFONE) - 1)
            ELSE NU_TELEFONE
        END;
        
        UPDATE Staging_Leitos_Hospitais
        SET 
            TELEFONE_INVALIDO = CASE 
                WHEN NU_TELEFONE IS NULL OR LEN(NU_TELEFONE) NOT IN (10, 11) OR NU_TELEFONE LIKE '%[^0-9]%' THEN 1
                ELSE 0
            END,
            NU_TELEFONE = CASE 
                WHEN NU_TELEFONE IS NULL OR LEN(NU_TELEFONE) NOT IN (10, 11) OR NU_TELEFONE LIKE '%[^0-9]%' THEN NULL
                ELSE NU_TELEFONE
            END;
        
        -- =============================================
        --  CORREÇÃO DE NATUREZA JURÍDICA
        -- =============================================
        PRINT 'Iniciando correção de natureza jurídica...';
        UPDATE Staging_Leitos_Hospitais
        SET DESC_NATUREZA_JURIDICA = REPLACE(DESC_NATUREZA_JURIDICA, '+', 'U')
        WHERE DESC_NATUREZA_JURIDICA LIKE '%+%';
        
        PRINT 'Transformação de leitos FINALIZADA.';
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Erro na transformação de leitos: %s', 16, 1, @ErrorMessage);
        RETURN -1;
    END CATCH
    
    RETURN 0;
END;
GO


--===================================
-- LOAD
--===============================

CREATE OR ALTER PROCEDURE sp_ETL_Load_Leitos
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
-- =============================================
-- Carregar Regiões
-- =============================================
        INSERT INTO Regiao (Nome)
        SELECT DISTINCT S.REGIAO
        FROM Staging_Leitos_Hospitais S
        WHERE S.REGIAO IS NOT NULL
          AND S.REGIAO NOT IN (SELECT Nome FROM Regiao);
        PRINT 'Regiões carregadas: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';
        
-- =============================================
-- Carregar UF
-- =============================================
        INSERT INTO UF (Id_Regiao, Sigla, Nome)
        SELECT DISTINCT R.Id_Regiao, S.UF, S.UF
        FROM Staging_Leitos_Hospitais S
        INNER JOIN Regiao R ON R.Nome = S.REGIAO
        WHERE S.UF IS NOT NULL
          AND S.UF NOT IN (SELECT Sigla FROM UF);
        PRINT 'UFs carregadas: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';
        
-- =============================================
 -- Carregar Municípios
-- =============================================
        INSERT INTO Municipio (Id_Uf, Nome, Populacao_Estimada)
        SELECT DISTINCT U.Id_Uf, S.MUNICIPIO, NULL
        FROM Staging_Leitos_Hospitais S
        INNER JOIN UF U ON U.Sigla = S.UF
        WHERE S.MUNICIPIO IS NOT NULL
          AND S.MUNICIPIO NOT IN (SELECT Nome FROM Municipio);
        PRINT 'Municípios carregados: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';
        
-- =============================================
 -- Carregar Natureza Jurídica
-- =============================================
        INSERT INTO Natureza_Juridica (Descricao)
        SELECT DISTINCT DESC_NATUREZA_JURIDICA
        FROM Staging_Leitos_Hospitais
        WHERE DESC_NATUREZA_JURIDICA IS NOT NULL
          AND DESC_NATUREZA_JURIDICA NOT IN (SELECT Descricao FROM Natureza_Juridica);
        PRINT 'Naturezas jurídicas carregadas: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';
        
-- =============================================
--  Carregar Endereço Hospital
-- =============================================
        INSERT INTO Endereco_Hospital
        (No_Logradouro, Nu_Endereco, No_Complemento, No_Bairro, Co_Cep, Nu_Telefone, No_Email)
        SELECT DISTINCT
            ISNULL(NO_LOGRADOURO,'Endereço Não Informado'),
            ISNULL(NU_ENDERECO,''),
            ISNULL(NO_COMPLEMENTO,'Não Informado'),
            ISNULL(NO_BAIRRO,'Bairro Não Informado'),
            ISNULL(CO_CEP,'00000000'),
            ISNULL(NU_TELEFONE,''),
            ISNULL(NO_EMAIL,'sememail@hospital.com')
        FROM Staging_Leitos_Hospitais
        WHERE NO_LOGRADOURO IS NOT NULL
          AND NOT EXISTS (
              SELECT 1 FROM Endereco_Hospital e
              WHERE ISNULL(e.No_Logradouro,'') = ISNULL(Staging_Leitos_Hospitais.NO_LOGRADOURO,'')
                AND ISNULL(e.Nu_Endereco,'') = ISNULL(Staging_Leitos_Hospitais.NU_ENDERECO,'')
                AND ISNULL(e.No_Bairro,'') = ISNULL(Staging_Leitos_Hospitais.NO_BAIRRO,'')
          );
        PRINT 'Endereços carregados: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';

-- =============================================
 -- Carregar Hospital
-- =============================================
        INSERT INTO Hospital
        (
            CNES, 
            Id_Municipio, 
            Id_Natureza_Juridica, 
            Id_Uf, 
            Id_Endereco, 
            Nome_Hospital, 
            Tipo_Gestao, 
            Razao_Social
        )
        SELECT
            LEFT(ISNULL(S.CNES,''), 7),
            M.Id_Municipio,
            N.Id_Natureza_Juridica,
            U.Id_Uf,
            E.Id_Endereco,
            ISNULL(NULLIF(LTRIM(RTRIM(S.NOME_ESTABELECIMENTO)),''), 'Hospital Não Informado'),
            ISNULL(NULLIF(LTRIM(RTRIM(S.TP_GESTAO)),''), 'Não Informado'),
            ISNULL(NULLIF(LTRIM(RTRIM(S.RAZAO_SOCIAL)),''), 'Não Informado')
        FROM Staging_Leitos_Hospitais S
        INNER JOIN Municipio M ON M.Nome = S.MUNICIPIO
        INNER JOIN Natureza_Juridica N ON N.Descricao = S.DESC_NATUREZA_JURIDICA
        INNER JOIN UF U ON U.Sigla = S.UF
        INNER JOIN Endereco_Hospital E ON
            E.No_Logradouro = S.NO_LOGRADOURO AND
            ISNULL(E.Nu_Endereco,'') = ISNULL(S.NU_ENDERECO,'') AND
            ISNULL(E.No_Bairro,'') = ISNULL(S.NO_BAIRRO,'')
        WHERE LEFT(ISNULL(S.CNES,''),7) <> ''
          AND NOT EXISTS (
              SELECT 1 FROM Hospital h WHERE h.CNES = LEFT(ISNULL(S.CNES,''),7)
          );
        PRINT 'Hospitais carregados: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';
        
 -- ============================================
-- Carregar Tipo de Unidade
 -- =============================================
        IF COL_LENGTH('Tipo_Unidade', 'Co_Tipo_Unidade') IS NULL
        BEGIN
            ALTER TABLE Tipo_Unidade ADD Co_Tipo_Unidade VARCHAR(200);
        END
        
        INSERT INTO Tipo_Unidade(Ds_Tipo_Unidade, Co_Tipo_Unidade)
        SELECT DISTINCT DS_TIPO_UNIDADE, CO_TIPO_UNIDADE
        FROM Staging_Leitos_Hospitais S
        WHERE DS_TIPO_UNIDADE IS NOT NULL
          AND CO_TIPO_UNIDADE IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM Tipo_Unidade t WHERE t.Co_Tipo_Unidade = S.CO_TIPO_UNIDADE);
        PRINT 'Tipo de unidade carregado: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';
        
-- =============================================
 -- Carregar Leito_UTI_Detalhe
 -- =============================================
        INSERT INTO Leito_UTI_Detalhe (
            Id_Hospital,
            UTI_TOTAL_EXIST,
            UTI_TOTAL_SUS,
            UTI_ADULTO_EXIST,
            UTI_ADULTO_SUS,
            UTI_PEDIATRICO_EXIST,
            UTI_PEDIATRICO_SUS,
            UTI_NEONATAL_EXIST,
            UTI_NEONATAL_SUS,
            UTI_QUEIMADO_EXIST,
            UTI_QUEIMADO_SUS,
            UTI_CORONARIANA_EXIST,
            UTI_CORONARIANA_SUS
        )
        SELECT
            h.Id_Hospital,
            TRY_CAST(NULLIF(LTRIM(RTRIM(s.UTI_TOTAL_EXIST)), '') AS INT),
            TRY_CAST(NULLIF(LTRIM(RTRIM(s.UTI_TOTAL_SUS)), '') AS INT),
            TRY_CAST(NULLIF(LTRIM(RTRIM(s.UTI_ADULTO_EXIST)), '') AS INT),
            TRY_CAST(NULLIF(LTRIM(RTRIM(s.UTI_ADULTO_SUS)), '') AS INT),
            TRY_CAST(NULLIF(LTRIM(RTRIM(s.UTI_PEDIATRICO_EXIST)), '') AS INT),
            TRY_CAST(NULLIF(LTRIM(RTRIM(s.UTI_PEDIATRICO_SUS)), '') AS INT),
            TRY_CAST(NULLIF(LTRIM(RTRIM(s.UTI_NEONATAL_EXIST)), '') AS INT),
            TRY_CAST(NULLIF(LTRIM(RTRIM(s.UTI_NEONATAL_SUS)), '') AS INT),
            TRY_CAST(NULLIF(LTRIM(RTRIM(s.UTI_QUEIMADO_EXIST)), '') AS INT),
            TRY_CAST(NULLIF(LTRIM(RTRIM(s.UTI_QUEIMADO_SUS)), '') AS INT),
            TRY_CAST(NULLIF(LTRIM(RTRIM(s.UTI_CORONARIANA_EXIST)), '') AS INT),
            TRY_CAST(NULLIF(LTRIM(RTRIM(s.UTI_CORONARIANA_SUS)), '') AS INT)
        FROM dbo.Staging_Leitos_Hospitais s
        INNER JOIN Hospital h ON h.CNES = LEFT(ISNULL(s.CNES,''), 7)
        WHERE LEFT(ISNULL(s.CNES,''),7) <> '';
        PRINT 'Leito_UTI_Detalhe carregado: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';

-- =============================================
 --  Carregar Tipo_Leito 
-- =============================================
        IF NOT EXISTS (SELECT 1 FROM Tipo_Leito WHERE Descricao = 'Leito Geral')
        BEGIN
            INSERT INTO Tipo_Leito (Descricao, Categoria)
            VALUES 
                ('Leito Geral', 'Leito Comum'),
                ('UTI Total', 'UTI'),
                ('UTI Adulto', 'UTI'),
                ('UTI Pediátrico', 'UTI'),
                ('UTI Neonatal', 'UTI'),
                ('UTI Queimado', 'UTI'),
                ('UTI Coronária', 'UTI');
            PRINT 'Tipos de leito carregados: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';
        END

 -- =============================================
 -- Carregar Leito
 -- =============================================
        INSERT INTO Leito (Id_Hospital, Id_Tipo_Leito, Quantidade_Existentes, Quantidade_Sus, Leitos_Existentes, Leitos_SUS)
        SELECT
            h.Id_Hospital,
            t.Id_Tipo_Leito,
            TRY_CAST(REPLACE(s.LEITOS_EXISTENTES, ',', '') AS INT),
            TRY_CAST(REPLACE(s.LEITOS_SUS, ',', '') AS INT),
            TRY_CAST(REPLACE(s.LEITOS_EXISTENTES, ',', '') AS NUMERIC(6,0)),
            TRY_CAST(REPLACE(s.LEITOS_SUS, ',', '') AS NUMERIC(6,0))
        FROM Staging_Leitos_Hospitais s
        JOIN Hospital h ON h.CNES = s.CNES
        JOIN Tipo_Leito t ON t.Descricao = 'Leito Geral'
        WHERE NOT EXISTS (
            SELECT 1 FROM Leito l 
            WHERE l.Id_Hospital = h.Id_Hospital AND l.Id_Tipo_Leito = t.Id_Tipo_Leito
        );
        PRINT 'Leitos carregados: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';
        
        COMMIT TRANSACTION;
        PRINT 'Leitos Funcionou!';
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Erro carga de leitos: %s', 16, 1, @ErrorMessage);
        RETURN -1;
    END CATCH
    
    RETURN 0;
END;
GO

--===================================
-- COMPLETA
--===============================
CREATE OR ALTER PROCEDURE sp_ETL_Completo_Leitos
    @CaminhoArquivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ResultadoExtracao INT;
    DECLARE @ResultadoTransformacao INT;
    DECLARE @ResultadoLoad INT;
    
    BEGIN TRY
        PRINT 'Iniciando processo ETL completo para leitos hospitalares...';
        
        -- Executar Extração
        EXEC @ResultadoExtracao = sp_ETL_Extracao_Leitos @CaminhoArquivo;
        IF @ResultadoExtracao <> 0
        BEGIN
            RAISERROR('Falha na etapa de Extração.', 16, 1);
            RETURN -1;
        END
        
        -- Executar Transformação
        EXEC @ResultadoTransformacao = sp_ETL_Transformacao_Leitos;
        IF @ResultadoTransformacao <> 0
        BEGIN
            RAISERROR('Falha na etapa de Transformação.', 16, 1);
            RETURN -1;
        END
        
        -- Executar Load
        EXEC @ResultadoLoad = sp_ETL_Load_Leitos;
        IF @ResultadoLoad <> 0
        BEGIN
            RAISERROR('Falha na etapa de Carga.', 16, 1);
            RETURN -1;
        END
        
        PRINT 'Processo ETL de leitos hospitalares concluído com sucesso!';
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT 'Erro no processo ETL de leitos: ' + @ErrorMessage;
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END;
GO


--===================================
-- EXECUTAR PASSO A PASSO 
--===============================

-- Apenas extração
EXEC sp_ETL_Extracao_Leitos 'C:\Users\Lyvia\OneDrive\Desktop\temp\Leitos_2024.csv';


-- PRECISA CRIAR ANTES DA TRANSFORMAÇÃO SE NÃO DA ERRO-------
            ALTER TABLE Staging_Leitos_Hospitais
            ADD TELEFONE_INVALIDO BIT DEFAULT 0;

            ALTER TABLE Staging_Leitos_Hospitais
            ADD EMAIL_INVALIDO BIT DEFAULT 0;

			ALTER TABLE Tipo_Unidade 
			ADD Co_Tipo_Unidade VARCHAR(200);

----------------------------------------------------------------

-- Apenas transformação  
EXEC sp_ETL_Transformacao_Leitos;

-- Apenas carga
EXEC sp_ETL_Load_Leitos;




--=====================================
-- EXECUTAR TUDO 
--=====================================
EXEC sp_ETL_Completo_Leitos 'C:\Users\Lyvia\OneDrive\Desktop\temp\Leitos_2024.csv';