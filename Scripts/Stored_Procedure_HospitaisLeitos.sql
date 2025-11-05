USE Sistema_Informações_Hospitalares;
GO

CREATE OR ALTER PROCEDURE sp_ProcessarLeitosHospitais
    @CaminhoArquivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;

    PRINT 'Iniciando processo de ETL...';

    BEGIN TRY
        -- =============================================
        -- ETAPA 1: CARREGAMENTO DOS DADOS (EXTRACT)
        -- =============================================
        PRINT 'Iniciando carregamento dos dados...';
        
        -- ✅ CORREÇÃO: Usar tabela temporária GLOBAL para evitar conflitos
        IF OBJECT_ID('tempdb..##Staging_Leitos_Hospitais', 'U') IS NOT NULL
            DROP TABLE ##Staging_Leitos_Hospitais;
        
        CREATE TABLE ##Staging_Leitos_Hospitais (
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
        
        PRINT 'Tabela staging criada com sucesso!';
        
        DECLARE @SqlQuery NVARCHAR(MAX);
        SET @SqlQuery = '
        BULK INSERT ##Staging_Leitos_Hospitais
        FROM ''' + @CaminhoArquivo + '''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = '','',
            ROWTERMINATOR = ''0x0a'',
            MAXERRORS = 1000
        )';
        EXEC sp_executesql @SqlQuery;
        
        DECLARE @LinhasCarregadas INT;
        SELECT @LinhasCarregadas = COUNT(*) FROM ##Staging_Leitos_Hospitais;
        PRINT 'Dados carregados com sucesso! Total de ' + CAST(@LinhasCarregadas AS VARCHAR) + ' registros.';
        
        -- =============================================
        -- ETAPA 2: LIMPEZA INICIAL - REMOÇÃO DE ASPAS
        -- =============================================
        PRINT 'Iniciando remoção de aspas...';
        UPDATE ##Staging_Leitos_Hospitais
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
        
        DECLARE @RegistrosComAspas INT;
        SELECT @RegistrosComAspas = COUNT(*) 
        FROM ##Staging_Leitos_Hospitais
        WHERE UF LIKE '%"%' OR MUNICIPIO LIKE '%"%';
        
        PRINT 'Remoção de aspas concluída. Registros com aspas remanescentes: ' + CAST(@RegistrosComAspas AS VARCHAR) + '.';
        
        -- =============================================
        -- ETAPA 3: NORMALIZAÇÃO DE CAMPOS NUMÉRICOS
        -- =============================================
        PRINT 'Iniciando normalização de campos numéricos...';
        UPDATE ##Staging_Leitos_Hospitais
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
        
        DECLARE @TotalRegistros INT, @LeitosExistentesNulos INT, @LeitosSusNulos INT, @UtiTotalExistNulos INT, @UtiTotalSusNulos INT;
        SELECT 
            @TotalRegistros = COUNT(*),
            @LeitosExistentesNulos = SUM(CASE WHEN LEITOS_EXISTENTES IS NULL THEN 1 ELSE 0 END),
            @LeitosSusNulos = SUM(CASE WHEN LEITOS_SUS IS NULL THEN 1 ELSE 0 END),
            @UtiTotalExistNulos = SUM(CASE WHEN UTI_TOTAL_EXIST IS NULL THEN 1 ELSE 0 END),
            @UtiTotalSusNulos = SUM(CASE WHEN UTI_TOTAL_SUS IS NULL THEN 1 ELSE 0 END)
        FROM ##Staging_Leitos_Hospitais;
        
        PRINT 'Normalização numérica concluída. Diagnóstico: Total registros = ' + CAST(@TotalRegistros AS VARCHAR) + 
              ', Leitos Existentes nulos = ' + CAST(@LeitosExistentesNulos AS VARCHAR) + 
              ', Leitos SUS nulos = ' + CAST(@LeitosSusNulos AS VARCHAR) + 
              ', UTI Total Exist nulos = ' + CAST(@UtiTotalExistNulos AS VARCHAR) + 
              ', UTI Total SUS nulos = ' + CAST(@UtiTotalSusNulos AS VARCHAR) + '.';
        
        -- =============================================
        -- ETAPA 4: TRATAMENTO DE EMAILS
        -- =============================================
        PRINT 'Iniciando tratamento de emails...';
        IF COL_LENGTH('##Staging_Leitos_Hospitais', 'EMAIL_INVALIDO') IS NULL
        BEGIN
            ALTER TABLE ##Staging_Leitos_Hospitais
            ADD EMAIL_INVALIDO BIT DEFAULT 0;
        END
        
        UPDATE ##Staging_Leitos_Hospitais
        SET NO_EMAIL = LOWER(TRIM(NO_EMAIL));
        
        UPDATE ##Staging_Leitos_Hospitais
        SET NO_EMAIL = CASE 
            WHEN NO_EMAIL LIKE '%@gmailcom' THEN REPLACE(NO_EMAIL, '@gmailcom', '@gmail.com')
            WHEN NO_EMAIL LIKE '%@hotmail%' AND NO_EMAIL NOT LIKE '%.com%' THEN NO_EMAIL + '.com'
            WHEN NO_EMAIL LIKE '%@yahoo%' AND NO_EMAIL NOT LIKE '%.com.br%' AND NO_EMAIL NOT LIKE '%.com%' THEN NO_EMAIL + '.com.br'
            WHEN NO_EMAIL LIKE '%@%' AND NO_EMAIL NOT LIKE '%.%' THEN NO_EMAIL + '.com.br'
            ELSE NO_EMAIL
        END
        WHERE NO_EMAIL IS NOT NULL;
        
        UPDATE ##Staging_Leitos_Hospitais
        SET 
            EMAIL_INVALIDO = CASE 
                WHEN NO_EMAIL IS NULL OR NO_EMAIL NOT LIKE '%_@_%._%' OR NO_EMAIL LIKE '% %' THEN 1
                ELSE 0
            END,
            NO_EMAIL = CASE 
                WHEN NO_EMAIL IS NULL OR NO_EMAIL NOT LIKE '%_@_%._%' OR NO_EMAIL LIKE '% %' THEN NULL
                ELSE NO_EMAIL
            END;
        
        PRINT 'Tratamento de emails concluído.';
        
        -- =============================================
        -- ETAPA 5: TRATAMENTO DE TELEFONES
        -- =============================================
        PRINT 'Iniciando tratamento de telefones...';
        IF COL_LENGTH('##Staging_Leitos_Hospitais', 'TELEFONE_INVALIDO') IS NULL
        BEGIN
            ALTER TABLE ##Staging_Leitos_Hospitais
            ADD TELEFONE_INVALIDO BIT DEFAULT 0;
        END
        
        UPDATE ##Staging_Leitos_Hospitais
        SET NU_TELEFONE = REPLACE(REPLACE(REPLACE(REPLACE(REPLACE(
            REPLACE(NU_TELEFONE, '(', ''), ')', ''), '-', ''), '/', ''), ' ', ''), '.', '');
        
        UPDATE ##Staging_Leitos_Hospitais
        SET NU_TELEFONE = CASE 
            WHEN CHARINDEX('/', NU_TELEFONE) > 0 
            THEN LEFT(NU_TELEFONE, CHARINDEX('/', NU_TELEFONE) - 1)
            ELSE NU_TELEFONE
        END;
        
        UPDATE ##Staging_Leitos_Hospitais
        SET 
            TELEFONE_INVALIDO = CASE 
                WHEN NU_TELEFONE IS NULL OR LEN(NU_TELEFONE) NOT IN (10, 11) OR NU_TELEFONE LIKE '%[^0-9]%' THEN 1
                ELSE 0
            END,
            NU_TELEFONE = CASE 
                WHEN NU_TELEFONE IS NULL OR LEN(NU_TELEFONE) NOT IN (10, 11) OR NU_TELEFONE LIKE '%[^0-9]%' THEN NULL
                ELSE NU_TELEFONE
            END;
        
        PRINT 'Tratamento de telefones concluído.';
        
        -- =============================================
        -- ETAPA 6: CORREÇÃO DE NATUREZA JURÍDICA
        -- =============================================
        PRINT 'Iniciando correção de natureza jurídica...';
        UPDATE ##Staging_Leitos_Hospitais
        SET DESC_NATUREZA_JURIDICA = REPLACE(DESC_NATUREZA_JURIDICA, '+', 'U')
        WHERE DESC_NATUREZA_JURIDICA LIKE '%+%';
        PRINT 'Correção de natureza jurídica concluída.';
        
        -- =============================================
        -- ETAPA 7: LOAD 
        -- =============================================
        PRINT '=== INICIANDO ETAPA DE LOAD ===';
        
        -- =============================================
        -- 1️ Carregar Regiões
        -- =============================================
        INSERT INTO Regiao (Nome)
        SELECT DISTINCT S.REGIAO
        FROM ##Staging_Leitos_Hospitais S
        WHERE S.REGIAO IS NOT NULL
          AND S.REGIAO NOT IN (SELECT Nome FROM Regiao);
        PRINT 'Regiões carregadas.';
        
        -- =============================================
        -- 2️ Carregar UF
        -- =============================================
        INSERT INTO UF (Id_Regiao, Sigla, Nome)
        SELECT DISTINCT R.Id_Regiao, S.UF, S.UF
        FROM ##Staging_Leitos_Hospitais S
        INNER JOIN Regiao R ON R.Nome = S.REGIAO
        WHERE S.UF IS NOT NULL
          AND S.UF NOT IN (SELECT Sigla FROM UF);
        PRINT 'UFs carregadas.';
        
        -- =============================================
        -- 3️ Carregar Municípios
        -- =============================================
        INSERT INTO Municipio (Id_Uf, Nome, Populacao_Estimada)
        SELECT DISTINCT U.Id_Uf, S.MUNICIPIO, NULL
        FROM ##Staging_Leitos_Hospitais S
        INNER JOIN UF U ON U.Sigla = S.UF
        WHERE S.MUNICIPIO IS NOT NULL
          AND S.MUNICIPIO NOT IN (SELECT Nome FROM Municipio);
        PRINT 'Municípios carregados.';
        
        -- =============================================
        -- 4️ Carregar Natureza Jurídica
        -- =============================================
        INSERT INTO Natureza_Juridica (Descricao)
        SELECT DISTINCT DESC_NATUREZA_JURIDICA
        FROM ##Staging_Leitos_Hospitais
        WHERE DESC_NATUREZA_JURIDICA IS NOT NULL
          AND DESC_NATUREZA_JURIDICA NOT IN (SELECT Descricao FROM Natureza_Juridica);
        PRINT 'Naturezas jurídicas carregadas.';
        
        -- =============================================
        -- 5️ Carregar Endereço Hospital
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
        FROM ##Staging_Leitos_Hospitais
        WHERE NO_LOGRADOURO IS NOT NULL
          AND NOT EXISTS (
              SELECT 1 FROM Endereco_Hospital e
              WHERE ISNULL(e.No_Logradouro,'') = ISNULL(NO_LOGRADOURO,'')
                AND ISNULL(e.Nu_Endereco,'') = ISNULL(NU_ENDERECO,'')
                AND ISNULL(e.No_Bairro,'') = ISNULL(NO_BAIRRO,'')
          );
        PRINT 'Endereços carregados.';

        -- =============================================
        -- 6️ Carregar Hospital
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
        FROM ##Staging_Leitos_Hospitais S
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
        PRINT 'Hospitais carregados.';
        
        -- =============================================
        -- 7️ Carregar Tipo de Unidade
        -- =============================================
        IF COL_LENGTH('Tipo_Unidade', 'Co_Tipo_Unidade') IS NULL
        BEGIN
            BEGIN TRY
                ALTER TABLE Tipo_Unidade ADD Co_Tipo_Unidade VARCHAR(200);
            END TRY
            BEGIN CATCH
                -- ignora se já existir
            END CATCH
        END
        
        INSERT INTO Tipo_Unidade(Ds_Tipo_Unidade, Co_Tipo_Unidade)
        SELECT DISTINCT DS_TIPO_UNIDADE, CO_TIPO_UNIDADE
        FROM ##Staging_Leitos_Hospitais S
        WHERE DS_TIPO_UNIDADE IS NOT NULL
          AND CO_TIPO_UNIDADE IS NOT NULL
          AND NOT EXISTS (SELECT 1 FROM Tipo_Unidade t WHERE t.Co_Tipo_Unidade = S.CO_TIPO_UNIDADE);
        PRINT 'Tipo de unidade carregado.';

        -- =============================================
        -- 8 Carregar Leito_UTI_Detalhe
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
        FROM ##Staging_Leitos_Hospitais s
        INNER JOIN Hospital h
            ON h.CNES = LEFT(ISNULL(s.CNES,''), 7)
        WHERE LEFT(ISNULL(s.CNES,''),7) <> '';
        PRINT 'Leito_UTI_Detalhe carregado.';
  
        PRINT '=== ETAPA DE LOAD CONCLUÍDA ===';
        
        -- ✅ CORREÇÃO: Limpar a tabela temporária ao final
        DROP TABLE ##Staging_Leitos_Hospitais;
             
    END TRY
    BEGIN CATCH
        PRINT 'Erro: ' + ERROR_MESSAGE();
        -- ✅ CORREÇÃO: Limpar a tabela temporária em caso de erro também
        IF OBJECT_ID('tempdb..##Staging_Leitos_Hospitais', 'U') IS NOT NULL
            DROP TABLE ##Staging_Leitos_Hospitais;
    END CATCH
END;
GO


EXEC sp_ProcessarLeitosHospitais 'C:\Users\Lyvia\OneDrive\Desktop\temp\Leitos_2024.csv';


