--==============================================================
-- EXTRAÇÃO
--==============================================================
CREATE OR ALTER PROCEDURE sp_ETL_Extracao_AIH
    @CaminhoArquivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
   
        -- Drop da tabela staging se existir
        IF OBJECT_ID('Staging_AIH_Hospitalar', 'U') IS NOT NULL
            DROP TABLE Staging_AIH_Hospitalar;

        -- Criação da tabela staging
        CREATE TABLE Staging_AIH_Hospitalar (
            UF_ZI VARCHAR(100),
            ANO_CMPT VARCHAR(100),
            MES_CMPT VARCHAR(100),
            ESPEC VARCHAR(100),
            CGC_HOSP VARCHAR(200),
            N_AIH VARCHAR(200),
            IDENT VARCHAR(200),
            CEP VARCHAR(200),
            MUNIC_RES VARCHAR(100),
            NASC VARCHAR(200),
            SEXO VARCHAR(100),
            UTI_MES_IN VARCHAR(100),
            UTI_MES_AN VARCHAR(100),
            UTI_MES_AL VARCHAR(100),
            UTI_MES_TO VARCHAR(100),
            MARCA_UTI VARCHAR(200),
            UTI_INT_IN VARCHAR(100),
            UTI_INT_AN VARCHAR(100),
            UTI_INT_AL VARCHAR(100),
            UTI_INT_TO VARCHAR(100),
            DIAR_ACOM VARCHAR(100),
            QT_DIARIAS VARCHAR(100),
            PROC_SOLIC VARCHAR(200),
            PROC_REA VARCHAR(200),
            VAL_SH VARCHAR(200),
            VAL_SP VARCHAR(200),
            VAL_SADT VARCHAR(200),
            VAL_RN VARCHAR(200),
            VAL_ACOMP VARCHAR(200),
            VAL_ORTP VARCHAR(200),
            VAL_SANGUE VARCHAR(200),
            VAL_SADTSR VARCHAR(200),
            VAL_TRANSP VARCHAR(200),
            VAL_OBSANG VARCHAR(200),
            VAL_PED1AC VARCHAR(200),
            VAL_TOT VARCHAR(200),
            VAL_UTI VARCHAR(200),
            US_TOT VARCHAR(200),
            DT_INTER VARCHAR(200),
            DT_SAIDA VARCHAR(200),
            DIAG_PRINC VARCHAR(200),
            DIAG_SECUN VARCHAR(200),
            COBRANCA VARCHAR(200),
            NATUREZA VARCHAR(200),
            NAT_JUR VARCHAR(200),
            GESTAO VARCHAR(200),
            RUBRICA VARCHAR(200),
            IND_VDRL VARCHAR(100),
            MUNIC_MOV VARCHAR(100),
            COD_IDADE VARCHAR(100),
            IDADE VARCHAR(100),
            DIAS_PERM VARCHAR(100),
            MORTE VARCHAR(100),
            NACIONAL VARCHAR(50),
            NUM_PROC VARCHAR(50),
            CAR_INT VARCHAR(100),
            TOT_PT_SP VARCHAR(20),
            CPF_AUT VARCHAR(50),
            HOMONIMO VARCHAR(10),
            NUM_FILHOS VARCHAR(10),
            INSTRU VARCHAR(50),
            CID_NOTIF VARCHAR(50),
            CONTRACEP1 VARCHAR(50),
            CONTRACEP2 VARCHAR(50),
            GESTRISCO VARCHAR(10),
            INSC_PN VARCHAR(50),
            SEQ_AIH5 VARCHAR(50),
            CBOR VARCHAR(50),
            CNAER VARCHAR(50),
            VINCPREV VARCHAR(50),
            GESTOR_COD VARCHAR(50),
            GESTOR_TP VARCHAR(50),
            GESTOR_CPF VARCHAR(50),
            GESTOR_DT VARCHAR(20),
            CNES VARCHAR(50),
            CNPJ_MANT VARCHAR(50),
            INFEHOSP VARCHAR(10),
            CID_ASSO VARCHAR(50),
            CID_MORTE VARCHAR(50),
            COMPLEX VARCHAR(50),
            FINANC VARCHAR(50),
            FAEC_TP VARCHAR(50),
            REGCT VARCHAR(50),
            RACA_COR VARCHAR(50),
            ETNIA VARCHAR(50),
            SEQUENCIA VARCHAR(50),
            REMESSA VARCHAR(50),
            AUD_JUST VARCHAR(100),
            SIS_JUST VARCHAR(100),
            VAL_SH_FED VARCHAR(20),
            VAL_SP_FED VARCHAR(20),
            VAL_SH_GES VARCHAR(20),
            VAL_SP_GES VARCHAR(20),
            VAL_UCI VARCHAR(20),
            MARCA_UCI VARCHAR(10),
            DIAGSEC1 VARCHAR(50),
            DIAGSEC2 VARCHAR(50),
            DIAGSEC3 VARCHAR(50),
            DIAGSEC4 VARCHAR(50),
            DIAGSEC5 VARCHAR(50),
            DIAGSEC6 VARCHAR(50),
            DIAGSEC7 VARCHAR(50),
            DIAGSEC8 VARCHAR(50),
            DIAGSEC9 VARCHAR(50),
            TPDISEC1 VARCHAR(50),
            TPDISEC2 VARCHAR(50),
            TPDISEC3 VARCHAR(50),
            TPDISEC4 VARCHAR(50),
            TPDISEC5 VARCHAR(50),
            TPDISEC6 VARCHAR(50),
            TPDISEC7 VARCHAR(50),
            TPDISEC8 VARCHAR(50),
            TPDISEC9 VARCHAR(50),
        );
        
        -- Bulk Insert
        DECLARE @SqlQuery NVARCHAR(MAX);
        SET @SqlQuery = '
        BULK INSERT Staging_AIH_Hospitalar
        FROM ''' + @CaminhoArquivo + '''
        WITH (
            FIRSTROW = 2,
            FIELDTERMINATOR = '';'',
            ROWTERMINATOR = ''0x0a'',
            MAXERRORS = 1000
        )';
        EXEC sp_executesql @SqlQuery;
        
        DECLARE @LinhasCarregadas INT;
        SELECT @LinhasCarregadas = COUNT(*) FROM Staging_AIH_Hospitalar;
        PRINT 'Dados carregados! Total de ' + CAST(@LinhasCarregadas AS VARCHAR) + ' registros.';
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Erro na extração de AIH: %s', 16, 1, @ErrorMessage);
        RETURN -1;
    END CATCH
    
    RETURN 0;
END;
GO


--==============================================================
-- TRANFORMAÇÃO
--==============================================================

CREATE OR ALTER PROCEDURE sp_ETL_Transformacao_AIH
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        PRINT 'Iniciando transformação de AIH hospitalar...';
        
        -- Atualizar os valores do sexo
        UPDATE Staging_AIH_Hospitalar 
        SET SEXO = CASE 
            WHEN SEXO = '1' THEN 'M'
            WHEN SEXO = '2' THEN 'F' 
            WHEN SEXO = '3' THEN 'F'
            ELSE 'N/I' 
        END;

        PRINT 'Sexo atualizado: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';

        -- Atualizar unidade de medida da idade
        UPDATE Staging_AIH_Hospitalar 
        SET COD_IDADE = CASE 
            WHEN COD_IDADE = '2' THEN 'DIAS'
            WHEN COD_IDADE = '3' THEN 'MESES' 
            WHEN COD_IDADE = '4' THEN 'ANOS'
            ELSE 'N/I' 
        END;

        PRINT 'Código idade atualizado: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';

        -- Atualizar ESPECIALIDADE DO LEITO(ESPEC)
        UPDATE dbo.Staging_AIH_Hospitalar
        SET ESPEC =
          CASE TRY_CAST(ESPEC AS INT)
            WHEN 1 THEN 'CIRURGIA'
            WHEN 2 THEN 'OBSTETRICIA' 
            WHEN 3 THEN 'CLINICA MEDICA' 
            WHEN 4 THEN 'CRONICOS' 
            WHEN 5 THEN 'PSIQUIATRIA'  
            WHEN 6 THEN 'PNEUMOLOGIA SANITARIA'  
            WHEN 7 THEN 'PEDIATRIA ' 
            WHEN 8 THEN 'REABILITACAO' 
            WHEN 9 THEN 'HOSPITAL DIA(CIRURGICOS)'  
            WHEN 10 THEN 'HOSPITAL DIA(AIDS)'
            WHEN 11 THEN 'HOSPITAL DIA(FIBROSE CISTICA)' 
            WHEN 12 THEN 'HOSPITAL DIA(INTERCORRENCIA PÓS TRANSPLANTES)' 
            WHEN 13 THEN 'HOSPITAL DIA(GERIATRIA)' 
            WHEN 14 THEN ' HOSPITAL DIA(SAUDE MENTAL)'
            ELSE 'NA'
          END;

        PRINT 'Especialidade atualizada: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';

        -- Atualiza CARACTER DA INTERNACAO
        UPDATE Staging_AIH_Hospitalar 
        SET CAR_INT = CASE TRY_CAST(CAR_INT AS INT)
            WHEN 1 THEN 'ELETIVO'
            WHEN 2 THEN 'URGENCIA' 
            WHEN 3 THEN 'ACIDENTE NO TRABALHO'
            WHEN 4 THEN 'ACIDENTE A CAMINHO DO TRABALHO'
            WHEN 5 THEN 'OUTROS TIPOS DE ACIDENTE'
            WHEN 6 THEN 'OUTRAS LESÕES E ENVENENAMENTO POR AGENTE QUIM'
           ELSE 'N/I' 
        END
        WHERE CAR_INT IS NOT NULL
          AND TRY_CAST(CAR_INT AS INT) IS NOT NULL;

        PRINT 'Característica internação atualizada: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';

        -- Atualiza o tipo de internação
        UPDATE Staging_AIH_Hospitalar
        SET IDENT = CASE TRY_CAST(IDENT AS INT)
            WHEN 1 THEN 'PRINCIPAL'
            WHEN 3 THEN 'CONTINUACAO'
            WHEN 5 THEN 'LONGA PERMANENCIA'
            ELSE 'N/I'
        END
        WHERE TRY_CAST(IDENT AS INT) IS NOT NULL;

        PRINT 'Identificação internação atualizada: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';

        -- Atualiza a raça/cor do paciente
        UPDATE Staging_AIH_Hospitalar
        SET RACA_COR = CASE TRY_CAST(RACA_COR AS INT)
            WHEN 1 THEN 'BRANCA' 
            WHEN 2 THEN 'PRETA' 
            WHEN 3 THEN 'PARDA'
            WHEN 4 THEN 'AMARELA'
            WHEN 5 THEN 'INDÍGENA'
            ELSE 'N/I'
        END
        WHERE RACA_COR IS NOT NULL
          AND TRY_CAST(RACA_COR AS INT) IS NOT NULL;

        PRINT 'Raça/cor atualizada: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';

        -- Atualiza escolaridade
        UPDATE Staging_AIH_Hospitalar
        SET INSTRU = CASE TRY_CAST(INSTRU AS INT)
            WHEN 1 THEN 'Analfabeto'
            WHEN 2 THEN '1º grau'
            WHEN 3 THEN '2º grau'
            WHEN 4 THEN '3º grau'
            ELSE 'N/I'
        END
        WHERE TRY_CAST(INSTRU AS INT) IS NOT NULL;

        PRINT 'Escolaridade atualizada: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';

        -- Atualiza contraceptivo 1
        UPDATE Staging_AIH_Hospitalar
        SET CONTRACEP1 = CASE TRY_CAST(CONTRACEP1 AS INT)
            WHEN 1 THEN 'LAM'
            WHEN 2 THEN 'Ogino-Knaus'
            WHEN 3 THEN 'Temperatura basal'
            WHEN 4 THEN 'Billings'
            WHEN 5 THEN 'Cinto térmico'
            WHEN 6 THEN 'DIU'
            WHEN 7 THEN 'Diafragma'
            WHEN 8 THEN 'Preservativo'
            WHEN 9 THEN 'Espermicida'
            WHEN 10 THEN 'Hormônio oral'
            WHEN 11 THEN 'Hormônio injetável'
            WHEN 12 THEN 'Coito interrompido'
            ELSE 'N/I'
        END
        WHERE CONTRACEP1 IS NOT NULL
          AND TRY_CAST(CONTRACEP1 AS INT) IS NOT NULL;

        PRINT 'Contraceptivo 1 atualizado: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';

        -- Atualiza cobrança
        UPDATE Staging_AIH_Hospitalar
        SET COBRANCA = CASE TRY_CAST(COBRANCA AS INT)
            WHEN 11 THEN 'Alta curado'
            WHEN 12 THEN 'Alta melhorado'
            WHEN 14 THEN 'Alta a pedido'
            WHEN 15 THEN 'Alta com previsão de retorno'
            WHEN 16 THEN 'Alta por evasão'
            WHEN 17 THEN 'Alta da mãe/puérpera e permanência RN'
            WHEN 18 THEN 'Alta por outros motivos'
            WHEN 19 THEN 'Alta de paciente agudo em psiquiatria'
            WHEN 21 THEN 'Permanência por características da doença'
            WHEN 22 THEN 'Permanência por intercorrência'
            WHEN 23 THEN 'Permanência por impossibilidade sócio-familiar'
            WHEN 24 THEN 'Permanência p/ doação (doador vivo)'
            WHEN 25 THEN 'Permanência p/ doação (doador morto)'
            WHEN 26 THEN 'Permanência por mudança de procedimento'
            WHEN 27 THEN 'Permanência por reoperação'
            WHEN 28 THEN 'Permanência por outros motivos'
            WHEN 29 THEN 'Transferência p/ internação domiciliar'
            WHEN 31 THEN 'Transferência p/ outro estabelecimento'
            WHEN 32 THEN 'Transferência p/ internação domiciliar'
            WHEN 41 THEN 'Óbito com DO pelo médico assistente'
            WHEN 42 THEN 'Óbito com DO pelo IML'
            WHEN 43 THEN 'Óbito com DO pelo SVO'
            WHEN 51 THEN 'Encerramento administrativo'
            WHEN 61 THEN 'Alta da mãe/puérpera e do RN'
            WHEN 62 THEN 'Alta da mãe/puérpera e permanência RN'
            WHEN 63 THEN 'Alta da mãe/puérpera e óbito RN'
            WHEN 64 THEN 'Alta da mãe/puérpera com óbito fetal'
            WHEN 65 THEN 'Óbito da gestante e do concepto'
            WHEN 66 THEN 'Óbito da mãe/puérpera e alta RN'
            WHEN 67 THEN 'Óbito da mãe/puérpera e permanência RN'
            ELSE 'N/I'
        END
        WHERE COBRANCA IS NOT NULL
          AND TRY_CAST(COBRANCA AS INT) IS NOT NULL;

        PRINT 'Cobrança atualizada: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';

        -- Atualiza marca UTI
        UPDATE Staging_AIH_Hospitalar
        SET MARCA_UTI = CASE TRY_CAST(MARCA_UTI AS INT)
            WHEN 0 THEN 'Não utilizou UTI'
            WHEN 1 THEN 'Utilizou mais de um tipo de UTI'
            WHEN 74 THEN 'UTI adulto - tipo I'
            WHEN 75 THEN 'UTI adulto - tipo II'
            WHEN 76 THEN 'UTI adulto - tipo III'
            WHEN 77 THEN 'UTI infantil - tipo I'
            WHEN 78 THEN 'UTI infantil - tipo II'
            WHEN 79 THEN 'UTI infantil - tipo III'
            WHEN 80 THEN 'UTI neonatal - tipo I'
            WHEN 81 THEN 'UTI neonatal - tipo II'
            WHEN 82 THEN 'UTI neonatal - tipo III'
            WHEN 83 THEN 'UTI de queimados'
            WHEN 85 THEN 'UTI coronariana - tipo II (UCO II)'
            WHEN 86 THEN 'UTI coronariana - tipo III (UCO III)'
            WHEN 99 THEN 'UTI doador'
            ELSE 'N/I'
        END
        WHERE MARCA_UTI IS NOT NULL
          AND TRY_CAST(MARCA_UTI AS INT) IS NOT NULL;

        PRINT 'Marca UTI atualizada: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';

		IF COL_LENGTH('dbo.Staging_AIH_Hospitalar', 'DIAS_PERMANENCIA') IS NULL
			BEGIN
		EXEC sp_executesql N'ALTER TABLE dbo.Staging_AIH_Hospitalar ADD DIAS_PERMANENCIA INT NULL;';
	END;

		UPDATE dbo.Staging_AIH_Hospitalar
		SET DIAS_PERMANENCIA =
		CASE
		 WHEN TRY_CONVERT(date, DT_INTER) IS NOT NULL
			 AND TRY_CONVERT(date, DT_SAIDA) IS NOT NULL
        THEN DATEDIFF(day,
                      TRY_CONVERT(date, DT_INTER),
                      TRY_CONVERT(date, DT_SAIDA))
        ELSE NULL
    END;

        PRINT 'Dias de permanência calculados: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';

        PRINT 'Transformação de AIH concluída com sucesso.';

       
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Erro na transformação de AIH: %s', 16, 1, @ErrorMessage);
        RETURN -1;
    END CATCH
    
    RETURN 0;
END;
GO


--==============================================================
-- LOAD
--==============================================================
CREATE OR ALTER PROCEDURE sp_ETL_Load_AIH
AS
BEGIN
    SET NOCOUNT ON;
    
    BEGIN TRY
        BEGIN TRANSACTION;
        
        PRINT 'Iniciando carga de AIH hospitalar...';
        
        -- =============================================
        -- Inserir dados básicos de tabelas de referência 
        -- =============================================
        -- Inserir classificação de risco
        INSERT INTO Classificacao_Risco (Descricao)
        SELECT DISTINCT CAR_INT
        FROM Staging_AIH_Hospitalar
        WHERE CAR_INT IS NOT NULL
          AND CAR_INT NOT IN (SELECT Descricao FROM Classificacao_Risco);
        PRINT 'Classificação de risco carregada: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';

        -- Inserir raça/cor
        INSERT INTO RACA_COR (Descricao)
        SELECT DISTINCT RACA_COR
        FROM Staging_AIH_Hospitalar
        WHERE RACA_COR IS NOT NULL
          AND RACA_COR NOT IN (SELECT Descricao FROM RACA_COR);
        PRINT 'Raça/cor carregada: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';

		SELECT * FROM Nivel_de_Escolaridade
        -- Inserir especialidade médica ---  PRECISA MUDAR A COLUNA NOME PARA NULL||  ALTER TABLE Especialidade_Medica ALTER COLUMN Nome VARCHAR(200) NULL
        INSERT INTO Especialidade_Medica (Descricao)
        SELECT DISTINCT ESPEC
        FROM Staging_AIH_Hospitalar
        WHERE ESPEC IS NOT NULL
          AND ESPEC NOT IN (SELECT Descricao FROM Especialidade_Medica);
        PRINT 'Especialidade médica carregada: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';

        -- Inserir nível de escolaridade
        INSERT INTO Nivel_de_Escolaridade (Descricao_Escolaridade)
        SELECT DISTINCT INSTRU
        FROM Staging_AIH_Hospitalar
        WHERE INSTRU IS NOT NULL
          AND INSTRU NOT IN (SELECT Descricao_Escolaridade FROM Nivel_de_Escolaridade);
        PRINT 'Escolaridade carregada: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';

        -- Inserir tipo de atendimento
        INSERT INTO Tipo_Atendimento (Descricao)
        SELECT DISTINCT CAR_INT
        FROM Staging_AIH_Hospitalar
        WHERE CAR_INT IS NOT NULL
          AND CAR_INT NOT IN (SELECT Descricao FROM Tipo_Atendimento);
        PRINT 'Tipo de atendimento carregado: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';

        -- =============================================
        -- Inserir pacientes 
        -- =============================================
        INSERT INTO Paciente (
            N_AIH,
            Id_Hospital,
            Sexo,
            Idade,
            Diagnostico_Principal,
            Diagnosticos_Secundarios,
            Internacao,
            Saida,
            Mortalidade,
            Num_Filhos,
            Contraceptivo_1,
            Contraceptivo_2,
            Ind_VDRL
        )
        SELECT
            N_AIH,
            NULL as Id_Hospital,
            CASE 
                WHEN SEXO IN ('1', 'M', 'Masculino') THEN 'Masculino'
                WHEN SEXO IN ('2', 'F', 'Feminino') THEN 'Feminino'
                ELSE 'Não Informado'
            END as Sexo,
            CASE 
                WHEN TRY_CAST(IDADE AS INT) BETWEEN 0 AND 150 THEN TRY_CAST(IDADE AS INT)
                ELSE NULL 
            END as Idade,
            NULLIF(TRIM(DIAG_PRINC), '') as Diagnostico_Principal,
            CONCAT_WS('; ',
                NULLIF(TRIM(DIAG_SECUN), ''),
                NULLIF(TRIM(DIAGSEC1), ''),
                NULLIF(TRIM(DIAGSEC2), ''),
                NULLIF(TRIM(DIAGSEC3), ''),
                NULLIF(TRIM(DIAGSEC4), ''),
                NULLIF(TRIM(DIAGSEC5), ''),
                NULLIF(TRIM(DIAGSEC6), ''),
                NULLIF(TRIM(DIAGSEC7), ''),
                NULLIF(TRIM(DIAGSEC8), ''),
                NULLIF(TRIM(DIAGSEC9), '')
            ) as Diagnosticos_Secundarios,
            CASE 
                WHEN TRY_CAST(DT_INTER AS DATE) IS NOT NULL THEN TRY_CAST(DT_INTER AS DATE)
                ELSE NULL 
            END as Internacao,
            CASE 
                WHEN TRY_CAST(DT_SAIDA AS DATE) IS NOT NULL THEN TRY_CAST(DT_SAIDA AS DATE)
                ELSE NULL 
            END as Saida,
            CASE 
                WHEN MORTE IN ('1','S','Sim','TRUE') THEN 1 
                ELSE 0 
            END as Mortalidade,
            CASE 
                WHEN TRY_CAST(NUM_FILHOS AS INT) BETWEEN 0 AND 50 THEN TRY_CAST(NUM_FILHOS AS INT)
                ELSE 0 
            END as Num_Filhos,
            NULLIF(TRIM(CONTRACEP1), '') as Contraceptivo_1,
            NULLIF(TRIM(CONTRACEP2), '') as Contraceptivo_2,
            CASE 
                WHEN IND_VDRL IN ('1','S','Sim','TRUE') THEN 1 
                ELSE 0 
            END as Ind_VDRL
        FROM Staging_AIH_Hospitalar
        WHERE N_AIH IS NOT NULL
          AND N_AIH NOT IN (SELECT N_AIH FROM Paciente);
        PRINT 'Pacientes carregados: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';

  
        -- =============================================
        -- Inserir internações  
        -- =============================================
		
      --  ALTER TABLE Internacao ALTER COLUMN Especialidade_Leito VARCHAR(50);
		-- Problema de truncate pois na tabela internação está com o varchar menor
		-- ERROS 
		-- Ocorreu um erro por
		-- ' Não é possível inserir o valor NULL na coluna 'Id_Hospital','
		-- ALTEREI PARA NULL || 		ALTER TABLE Internacao  		ALTER COLUMN Id_Hospital INT NULL
 
        INSERT INTO Internacao (
            Id_Paciente,
            Id_Hospital,
            Sequencia_Internacao,
            Data_Internacao,
            Data_Saida,
            Morte,
            Identificacao_internacao,
            Especialidade_Leito,
            Cobranca,
            Gestao_De_Risco,
            Procedimento_Solicitado,
            Diaria_Acompanhante,
            Ano_Internacao,
            Mes_Internacao
        ) 
        SELECT
            p.Id_Paciente,
            NULL as Id_Hospital,
            1 AS Sequencia_Internacao,
            CASE 
                WHEN TRY_CAST(s.DT_INTER AS DATE) IS NOT NULL THEN TRY_CAST(s.DT_INTER AS DATE)
                ELSE NULL 
            END AS Data_Internacao,
            CASE 
                WHEN TRY_CAST(s.DT_SAIDA AS DATE) IS NOT NULL THEN TRY_CAST(s.DT_SAIDA AS DATE)
                ELSE NULL 
            END AS Data_Saida,
            CASE 
                WHEN s.MORTE IN ('1','S','Sim','TRUE') THEN 1 
                ELSE 0 
            END AS Morte,
            NULL AS Identificacao_internacao,
            NULLIF(TRIM(s.ESPEC), '') AS Especialidade_Leito,
            NULLIF(TRIM(s.COBRANCA), '') AS Cobranca,
            CASE 
                WHEN s.GESTRISCO IN ('1','S','Sim','TRUE') THEN 1 
                ELSE 0 
            END AS Gestao_De_Risco,
            NULLIF(TRIM(s.PROC_SOLIC), '') AS Procedimento_Solicitado,
            CASE 
                WHEN TRY_CAST(s.DIAR_ACOM AS INT) BETWEEN 0 AND 1000 THEN TRY_CAST(s.DIAR_ACOM AS INT)
                ELSE 0 
            END AS Diaria_Acompanhante,
            CASE 
                WHEN TRY_CAST(s.ANO_CMPT AS INT) BETWEEN 1900 AND YEAR(GETDATE()) THEN TRY_CAST(s.ANO_CMPT AS INT)
                ELSE NULL 
            END AS Ano_Internacao,
            CASE 
                WHEN TRY_CAST(s.MES_CMPT AS INT) BETWEEN 1 AND 12 THEN TRY_CAST(s.MES_CMPT AS INT)
                ELSE NULL 
            END AS Mes_Internacao
        FROM Staging_AIH_Hospitalar s
        INNER JOIN Paciente p ON s.N_AIH = p.N_AIH
        WHERE NOT EXISTS (
            SELECT 1 FROM Internacao i 
            WHERE i.Id_Paciente = p.Id_Paciente 
            AND i.Data_Internacao = CASE WHEN TRY_CAST(s.DT_INTER AS DATE) IS NOT NULL THEN TRY_CAST(s.DT_INTER AS DATE) ELSE NULL END
        );
        PRINT 'Internações carregadas: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';

        -- =============================================
        -- Inserir dados financeiros 
        -- =============================================
        INSERT INTO Financeiro_AIH (
            N_AIH, CGC_HOSP, Ano, Mes,
            Valor_SH, Valor_SP, Valor_SADT, Valor_RN, Valor_Acompanhante,
            Valor_Ortese_Protese, Valor_Sangue, Valor_SADT_Simplificado,
            Valor_Transporte, Valor_Obs_Sangue, Valor_Pediatria, Valor_UTI, Valor_UCI,
            Valor_Total, Usuario_Total
        )
        SELECT
            N_AIH,
            CGC_HOSP,
            CAST(ANO_CMPT AS INT),
            CAST(MES_CMPT AS INT),
            CAST(VAL_SH AS DECIMAL(18,2)),
            CAST(VAL_SP AS DECIMAL(18,2)),
            CAST(VAL_SADT AS DECIMAL(18,2)),
            CAST(VAL_RN AS DECIMAL(18,2)),
            CAST(VAL_ACOMP AS DECIMAL(18,2)),
            CAST(VAL_ORTP AS DECIMAL(18,2)),
            CAST(VAL_SANGUE AS DECIMAL(18,2)),
            CAST(VAL_SADTSR AS DECIMAL(18,2)),
            CAST(VAL_TRANSP AS DECIMAL(18,2)),
            CAST(VAL_OBSANG AS DECIMAL(18,2)),
            CAST(VAL_PED1AC AS DECIMAL(18,2)),
            CAST(VAL_UTI AS DECIMAL(18,2)),
            CAST(VAL_UCI AS DECIMAL(18,2)),
            CAST(VAL_TOT AS DECIMAL(18,2)),
            US_TOT
        FROM Staging_AIH_Hospitalar
        WHERE CGC_HOSP IS NOT NULL
          AND N_AIH NOT IN (SELECT N_AIH FROM Financeiro_AIH);
        PRINT 'Dados financeiros carregados: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';

        -- =============================================
        -- Inserir procedimentos médicos 
        -- =============================================
        INSERT INTO Procedimento_Medico (Descricao, Val_Sh, Val_Sp, Val_Sadt, Val_Tot)
        SELECT DISTINCT
          NULLIF(LTRIM(RTRIM(COALESCE(PROC_REA, PROC_SOLIC))), '') AS Descricao,
          TRY_CAST(REPLACE(NULLIF(VAL_SH,''), ',', '.') AS DECIMAL(15,2)) AS Val_Sh,
          TRY_CAST(REPLACE(NULLIF(VAL_SP,''), ',', '.') AS DECIMAL(15,2)) AS Val_Sp,
          TRY_CAST(REPLACE(NULLIF(VAL_SADT,''), ',', '.') AS DECIMAL(15,2)) AS Val_Sadt,
          TRY_CAST(REPLACE(NULLIF(VAL_TOT,''), ',', '.') AS DECIMAL(15,2)) AS Val_Tot
        FROM Staging_AIH_Hospitalar
        WHERE COALESCE(PROC_REA, PROC_SOLIC) IS NOT NULL
          AND LTRIM(RTRIM(COALESCE(PROC_REA, PROC_SOLIC))) <> ''
          AND NOT EXISTS (
              SELECT 1 FROM Procedimento_Medico pm 
              WHERE pm.Descricao = NULLIF(LTRIM(RTRIM(COALESCE(PROC_REA, PROC_SOLIC))), '')
          );
        PRINT 'Procedimentos médicos carregados: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';

        -- =============================================
        -- Inserir dados de UTI -- PRECISA DA TABELA INTERNAÇÃO POPULADA
        -- =============================================
        
        INSERT INTO UTI_Atendimento (
            Id_Internacao,
            UTI_MES_IN, UTI_MES_AN, UTI_MES_AL, UTI_MES_TO,
            Marca_UTI,
            UTI_INT_IN, UTI_INT_AN, UTI_INT_AL, UTI_INT_TO,
            Val_UTI,
            Marca_UCI
        )
        SELECT
            i.Id_Internacao,
            TRY_CAST(s.UTI_MES_IN AS INT),
            TRY_CAST(s.UTI_MES_AN AS INT),
            TRY_CAST(s.UTI_MES_AL AS INT),
            TRY_CAST(s.UTI_MES_TO AS INT),
            s.MARCA_UTI,
            TRY_CAST(s.UTI_INT_IN AS INT),
            TRY_CAST(s.UTI_INT_AN AS INT),
            TRY_CAST(s.UTI_INT_AL AS INT),
            TRY_CAST(s.UTI_INT_TO AS INT),
            TRY_CAST(s.VAL_UTI AS DECIMAL(15,2)),
            s.MARCA_UCI
        FROM Staging_AIH_Hospitalar s
        INNER JOIN Paciente p ON s.N_AIH = p.N_AIH
        INNER JOIN Internacao i ON p.Id_Paciente = i.Id_Paciente
        WHERE NOT EXISTS (
            SELECT 1 FROM UTI_Atendimento u 
            WHERE u.Id_Internacao = i.Id_Internacao
        );
        PRINT 'Dados UTI carregados: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';

        -- =============================================
        -- Inserir saúde reprodutiva -- ANTES PRECISA DA TABELA INTERNAÇÃO POPULADA
        -- =============================================
        INSERT INTO Saude_Reprodutiva (
            Id_Internacao,
            Exame_Vdrl,
            Contraceptivo_1,
            Contraceptivo_2,
            Num_Filhos
        )
        SELECT
            i.Id_Internacao,
            CASE 
                WHEN UPPER(LTRIM(RTRIM(s.IND_VDRL))) IN ('S', 'SIM', '1', 'TRUE') THEN 1
                WHEN UPPER(LTRIM(RTRIM(s.IND_VDRL))) IN ('N', 'NAO', '0', 'FALSE') THEN 0
                ELSE NULL
            END AS Exame_Vdrl,
            LTRIM(RTRIM(s.CONTRACEP1)) AS Contraceptivo_1,
            LTRIM(RTRIM(s.CONTRACEP2)) AS Contraceptivo_2,
            CASE 
                WHEN TRY_CAST(s.NUM_FILHOS AS INT) BETWEEN 0 AND 20 THEN TRY_CAST(s.NUM_FILHOS AS INT)
                ELSE NULL 
            END AS Num_Filhos
        FROM Staging_AIH_Hospitalar s
        INNER JOIN Paciente p ON s.N_AIH = p.N_AIH
        INNER JOIN Internacao i ON p.Id_Paciente = i.Id_Paciente
        WHERE NOT EXISTS (
            SELECT 1 FROM Saude_Reprodutiva sr 
            WHERE sr.Id_Internacao = i.Id_Internacao
        );
        PRINT 'Saúde reprodutiva carregada: ' + CAST(@@ROWCOUNT AS VARCHAR) + ' registros.';

        COMMIT TRANSACTION;
        PRINT 'Carga de AIH concluída com sucesso!';
        
    END TRY
    BEGIN CATCH
        IF @@TRANCOUNT > 0
            ROLLBACK TRANSACTION;
            
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        RAISERROR('Erro na carga de AIH: %s', 16, 1, @ErrorMessage);
        RETURN -1;
    END CATCH
    
    RETURN 0;
END;
GO



--==============================================================
-- COMPLETA
--==============================================================

CREATE OR ALTER PROCEDURE sp_ETL_Completo_AIH
    @CaminhoArquivo NVARCHAR(500)
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @ResultadoExtracao INT;
    DECLARE @ResultadoTransformacao INT;
    DECLARE @ResultadoLoad INT;
    
    BEGIN TRY
        PRINT 'Iniciando processo ETL completo para AIH hospitalar...';
        
        -- Executar Extração
        EXEC @ResultadoExtracao = sp_ETL_Extracao_AIH @CaminhoArquivo;
        IF @ResultadoExtracao <> 0
        BEGIN
            RAISERROR('Falha na etapa de Extração.', 16, 1);
            RETURN -1;
        END
        
        -- Executar Transformação
        EXEC @ResultadoTransformacao = sp_ETL_Transformacao_AIH;
        IF @ResultadoTransformacao <> 0
        BEGIN
            RAISERROR('Falha na etapa de Transformação.', 16, 1);
            RETURN -1;
        END
        
        -- Executar Load
        EXEC @ResultadoLoad = sp_ETL_Load_AIH;
        IF @ResultadoLoad <> 0
        BEGIN
            RAISERROR('Falha na etapa de Carga.', 16, 1);
            RETURN -1;
        END
        
        PRINT 'Processo ETL de AIH hospitalar concluído com sucesso!';
        RETURN 0;
        
    END TRY
    BEGIN CATCH
        DECLARE @ErrorMessage NVARCHAR(4000) = ERROR_MESSAGE();
        PRINT 'Erro no processo ETL de AIH: ' + @ErrorMessage;
        RAISERROR(@ErrorMessage, 16, 1);
        RETURN -1;
    END CATCH
END;
GO


--====================================================
--EXECUÇÃO 
--==========================================================

--1. primeiro: EXTRAÇÃO -- precisa ir fazendo a alterção do csv 'RD2024xx'
EXEC  sp_ETL_Extracao_AIH 'C:\Users\Lyvia\OneDrive\Desktop\tem\RD202401.csv';
EXEC sp_ETL_Extracao_AIH 'C:\Users\Lyvia\OneDrive\Desktop\tem\RD202402.csv';


-- ANTES DA TRANSFORMAÇÃO PRECISA CRIAR A TABELA  --------------------------------------------------


ALTER TABLE Staging_AIH_Hospitalar ADD DIAS_PERMANENCIA INT;

        UPDATE Staging_AIH_Hospitalar -- USAR SÓ CASO DER ERRO NA HORA DA TRANSFORMAÇÃO
        SET DIAS_PERMANENCIA = 
            CASE 
                WHEN TRY_CAST(DT_INTER AS DATE) IS NOT NULL AND TRY_CAST(DT_SAIDA AS DATE) IS NOT NULL
                THEN DATEDIFF(DAY, TRY_CAST(DT_INTER AS DATE), TRY_CAST(DT_SAIDA AS DATE))
                ELSE NULL
            END;
-----------------------------------------------------------------------------------------------


-- 2. Segundo: TRANSFORMAÇÃO
EXEC sp_ETL_Transformacao_AIH;

-- 3. Terceiro: CARGA
EXEC sp_ETL_Load_AIH;



--=========================
-- EXECUÇÃO DO ETL COMPLETO 
--==========================

-- Executar para cada arquivo individualmente
EXEC sp_ETL_Completo_AIH 'C:\Users\Lyvia\OneDrive\Desktop\tem\RD202401.csv';
EXEC sp_ETL_Completo_AIH 'C:\Users\Lyvia\OneDrive\Desktop\tem\RD202402.csv';
EXEC sp_ETL_Completo_AIH 'C:\Users\Lyvia\OneDrive\Desktop\tem\RD202403.csv';
EXEC sp_ETL_Completo_AIH 'C:\Users\Lyvia\OneDrive\Desktop\tem\RD202404.csv';
EXEC sp_ETL_Completo_AIH 'C:\Users\Lyvia\OneDrive\Desktop\tem\RD202405.csv';
EXEC sp_ETL_Completo_AIH 'C:\Users\Lyvia\OneDrive\Desktop\tem\RD202406.csv';
EXEC sp_ETL_Completo_AIH 'C:\Users\Lyvia\OneDrive\Desktop\tem\RD202407.csv';
EXEC sp_ETL_Completo_AIH 'C:\Users\Lyvia\OneDrive\Desktop\tem\RD202408.csv';
EXEC sp_ETL_Completo_AIH 'C:\Users\Lyvia\OneDrive\Desktop\tem\RD202409.csv';
EXEC sp_ETL_Completo_AIH 'C:\Users\Lyvia\OneDrive\Desktop\tem\RD202410.csv';
EXEC sp_ETL_Completo_AIH 'C:\Users\Lyvia\OneDrive\Desktop\tem\RD202411.csv';
EXEC sp_ETL_Completo_AIH 'C:\Users\Lyvia\OneDrive\Desktop\tem\RD202412.csv';
