-- =============================================
-- TRIGGERS - SISTEMA DE INFORMAÇÕES HOSPITALARES
-- =============================================

USE Sistema_Informacoes_Hospitalares;
GO

-- =============================================
--	TRIGGER: Validar data de saída da internação
--  Paciente não pode sair antes de entrar no hospital
-- =============================================
CREATE OR ALTER TRIGGER trg_Validar_Data_Saida
ON Internacao
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (
        SELECT 1 
        FROM inserted 
        WHERE Data_Saida IS NOT NULL 
        AND Data_Saida < Data_Internacao
    )
    BEGIN
        RAISERROR('Opa! A data de saída não pode ser antes da data de internação. Verifique as datas.', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- =============================================
-- TRIGGER: Calcular ano e mês de internação
-- Preenche automaticamente campos de controle temporal
-- =============================================
CREATE OR ALTER TRIGGER trg_Preencher_Periodo_Internacao
ON Internacao
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE i
    SET Ano_Internacao = YEAR(ins.Data_Internacao),
        Mes_Internacao = MONTH(ins.Data_Internacao)
    FROM Internacao i
    INNER JOIN inserted ins ON i.Id_Internacao = ins.Id_Internacao
    WHERE ins.Data_Internacao IS NOT NULL;
END;
GO

-- =============================================
-- TRIGGER: Validar disponibilidade de leitos
-- Impede internações se não houver leitos disponíveis
-- =============================================
CREATE OR ALTER TRIGGER trg_Validar_Disponibilidade_Leitos
ON Internacao
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    DECLARE @Id_Hospital INT;
    DECLARE @Total_Leitos INT;
    DECLARE @Internacoes_Ativas INT;
    
    SELECT @Id_Hospital = Id_Hospital FROM inserted;
    
    -- Total de leitos disponíveis
    SELECT @Total_Leitos = ISNULL(SUM(Leitos_Existentes), 0)
    FROM Leito
    WHERE Id_Hospital = @Id_Hospital;
    
    -- Internações ativas (sem data de saída)
    SELECT @Internacoes_Ativas = COUNT(*)
    FROM Internacao
    WHERE Id_Hospital = @Id_Hospital
    AND Data_Saida IS NULL;
    
    IF @Internacoes_Ativas > @Total_Leitos
    BEGIN
        RAISERROR('Não há leitos disponíveis neste hospital', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- =============================================
-- TRIGGER: Atualizar total de usuários atendidos
-- Incrementa contador de atendimentos no hospital
-- =============================================
CREATE OR ALTER TRIGGER trg_Atualizar_Total_Atendimentos
ON Atendimento
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    -- Atualiza o registro que acabou de ser inserido
    UPDATE a
    SET Total_Usuarios_Atendidos = (
        SELECT COUNT(*) 
        FROM Atendimento 
        WHERE Id_Hospital = i.Id_Hospital
    )
    FROM Atendimento a
    JOIN inserted i ON a.Id_Atendimento = i.Id_Atendimento;
END;
GO 

-- =============================================
-- TRIGGER: Validar CNES (formato)
-- Garante que CNES tenha exatamente 7 caracteres numéricos
-- =============================================
CREATE OR ALTER TRIGGER trg_Validar_CNES
ON Hospital
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (
        SELECT 1 
        FROM inserted 
        WHERE CNES IS NOT NULL 
        AND (LEN(CNES) != 7 OR CNES NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
    )
    BEGIN
        RAISERROR('CNES deve conter exatamente 7 dígitos numéricos', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO
-- =============================================
-- RIGGER: Calcular permanência hospitalar
-- Atualiza automaticamente dias de permanência
-- =============================================
CREATE OR ALTER TRIGGER trg_Calcular_Permanencia
ON Detalhe_Internacao
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE d
    SET Permanencia_Hospital = DATEDIFF(DAY, i.Data_Internacao, ISNULL(i.Data_Saida, GETDATE()))
    FROM Detalhe_Internacao d
    INNER JOIN inserted ins ON d.Id_Detalhe_Internacao = ins.Id_Detalhe_Internacao
    INNER JOIN Internacao i ON d.Id_Internacao = i.Id_Internacao
    WHERE i.Data_Internacao IS NOT NULL;
END;
GO


-- =============================================
-- TRIGGER: Validar CEP
-- Garante formato correto de CEP (8 dígitos)
-- =============================================
CREATE OR ALTER TRIGGER trg_Validar_CEP
ON Endereco_Hospital
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (
        SELECT 1 
        FROM inserted 
        WHERE Co_Cep IS NOT NULL 
        AND (LEN(Co_Cep) != 8 OR Co_Cep NOT LIKE '[0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]')
    )
    BEGIN
        RAISERROR('CEP deve conter exatamente 8 dígitos numéricos', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO


CREATE OR ALTER TRIGGER trg_Validar_Profissional_Saude
ON Profissional_Saude
AFTER INSERT, UPDATE
AS
BEGIN
    SET NOCOUNT ON;
    
    IF EXISTS (
        SELECT 1 
        FROM inserted 
        WHERE Nome IS NULL OR LTRIM(RTRIM(Nome)) = ''
    )
    BEGIN
        RAISERROR('O nome do profissional de saúde é obrigatório!', 16, 1);
        ROLLBACK TRANSACTION;
    END
END;
GO

-- =============================================
-- TRIGGER: Registrar data/hora de atendimento automaticamente
-- Preenche timestamp quando não informado
-- =============================================
CREATE OR ALTER TRIGGER trg_Registrar_DataHora_Atendimento
ON Atendimento
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE a
    SET Data_Hora = GETDATE()
    FROM Atendimento a
    INNER JOIN inserted i ON a.Id_Atendimento = i.Id_Atendimento
    WHERE i.Data_Hora IS NULL;
END;
GO
select * from Financeiro_AIH

-- =============================================
-- TRIGGER: Atualizar sequência de internação
-- Numera internações do paciente sequencialmente
-- =============================================
CREATE OR ALTER TRIGGER trg_Atualizar_Sequencia_Internacao
ON Internacao
AFTER INSERT
AS
BEGIN
    SET NOCOUNT ON;
    
    UPDATE i
    SET Sequencia_Internacao = (
        SELECT COUNT(*) 
        FROM Internacao 
        WHERE Id_Paciente = ins.Id_Paciente 
        AND Id_Internacao <= ins.Id_Internacao
    )
    FROM Internacao i
    INNER JOIN inserted ins ON i.Id_Internacao = ins.Id_Internacao;
END;
GO


PRINT 'Todas as triggers foram criadas!';
GO