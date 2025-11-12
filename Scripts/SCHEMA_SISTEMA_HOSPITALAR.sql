-- =============================================
-- SISTEMA DE INFORMAÇÕES HOSPITALARES - SCHEMA
-- Modelo de dados para gestão hospitalar integral
-- =============================================

CREATE DATABASE Sistema_Informacoes_Hospitalares;
GO

USE Sistema_Informacoes_Hospitalares;
GO

-- Tabela de Regiões do país
CREATE TABLE Regiao(
    Id_Regiao INT PRIMARY KEY IDENTITY(1,1),
    Nome VARCHAR(200) NOT NULL 
	
);
GO

-- Níveis de escolaridade dos pacientes
CREATE TABLE Nivel_de_Escolaridade(
    Id_Escolaridade INT PRIMARY KEY IDENTITY(1,1),
    Descricao_Escolaridade VARCHAR(250) 
);
GO

-- Tipologia das unidades de saúde
CREATE TABLE Tipo_Unidade(
    Id_Tipo_Unidade INT PRIMARY KEY IDENTITY(1,1),
    Ds_Tipo_Unidade VARCHAR(200) NULL
);
GO

-- Modalidades de atendimento médico
CREATE TABLE Tipo_Atendimento(
    Id_tipo_Atendimento INT PRIMARY KEY IDENTITY(1,1),
    Descricao VARCHAR(250) NULL  
);
GO

-- Classificação dos leitos hospitalares
CREATE TABLE Tipo_Leito(
    Id_Tipo_Leito INT PRIMARY KEY IDENTITY(1,1),
    Descricao VARCHAR(250) NULL,
    Categoria VARCHAR(50) NULL  
);
GO

-- CID-10
CREATE TABLE CID10(
    Id_CID10 INT PRIMARY KEY IDENTITY(1,1),
    Descricao VARCHAR(250) NULL,
    Notificacao_Compulsoria INT NULL,
    Capitulo VARCHAR(100) NULL
);
GO

-- Especialidades médicas
CREATE TABLE Especialidade_Medica(
    Id_Especialidade INT PRIMARY KEY IDENTITY(1,1),
    Nome VARCHAR(200) NULL,
    Descricao VARCHAR(250) NULL
);
GO

-- Classificação de risco
CREATE TABLE Classificacao_Risco(
    Id_Class_Risco INT PRIMARY KEY IDENTITY(1,1),
    Descricao VARCHAR(250) NULL
);
GO

-- Tipos de recursos hospitalares
CREATE TABLE Tipo_Recurso(
    Id_Tipo_Recurso INT PRIMARY KEY NOT NULL,
    Descricao VARCHAR(250)
);
GO

-- Tipos de demanda assistencial
CREATE TABLE Tipo_Demanda(
    Id_Tipo_Demanda INT PRIMARY KEY IDENTITY(1,1),
    Descricao VARCHAR(250) NULL
);
GO

-- Faixas etárias
CREATE TABLE Faixa_Etaria(
    Id_Faixa_Etaria INT PRIMARY KEY IDENTITY(1,1),
    Descricao VARCHAR(50) NULL,
    Min_Idade INT NULL,
    Max_Idade INT NULL
);
GO

-- Classificação étnico-racial
CREATE TABLE RACA_COR(
    Id_raca INT PRIMARY KEY IDENTITY(1,1),
    Descricao VARCHAR(20) NULL
);
GO

-- Natureza jurídica
CREATE TABLE Natureza_Juridica(
    Id_Natureza_Juridica INT PRIMARY KEY IDENTITY(1,1),
    Tipo INT NULL,
    Justificativas_AUD VARCHAR(250) NULL,
    Justificativas_SIS VARCHAR(250) NULL,
    Descricao VARCHAR(250) NULL
);
GO

-- Unidades Federativas
CREATE TABLE UF(
    Id_Uf INT PRIMARY KEY IDENTITY(1,1),
    Id_Regiao INT NOT NULL,
    Sigla CHAR(2) NOT NULL,
    Nome VARCHAR(100) NOT NULL,
    FOREIGN KEY(Id_Regiao) REFERENCES Regiao(Id_Regiao) ON DELETE CASCADE
);
GO

-- Municípios
CREATE TABLE Municipio(
    Id_Municipio INT PRIMARY KEY IDENTITY(1,1),
    Id_Uf INT NOT NULL,
    Nome VARCHAR(100) NOT NULL,
	Populacao_Estimada BIGINT NULL,
    FOREIGN KEY(Id_Uf) REFERENCES UF(Id_Uf) ON DELETE CASCADE
);
GO

-- Endereços
CREATE TABLE Endereco_Hospital(
    Id_Endereco INT PRIMARY KEY IDENTITY(1,1),
    No_Logradouro VARCHAR(250) NOT NULL,
    Nu_Endereco VARCHAR(20) NULL,
    No_Complemento VARCHAR(100) NOT NULL,
    No_Bairro VARCHAR(100) NOT NULL,
    Co_Cep CHAR(8) NULL,
    Nu_Telefone VARCHAR(20) NULL,
    No_Email VARCHAR(255) NOT NULL
);
GO

-- Tabela Hospital com ID único
CREATE TABLE Hospital(
    Id_Hospital INT PRIMARY KEY IDENTITY(1,1),
    CNES CHAR(7) NULL,
    Id_Municipio INT NOT NULL,
    Id_Natureza_Juridica INT NOT NULL,
    Id_Uf INT NOT NULL,
    Id_Endereco INT NOT NULL,
    Nome_Hospital VARCHAR(200) NOT NULL,
    Tipo_Gestao VARCHAR(100) NULL,
    Razao_Social VARCHAR(200) NOT NULL,
    FOREIGN KEY (Id_Municipio) REFERENCES Municipio(Id_Municipio),
    FOREIGN KEY (Id_Natureza_Juridica) REFERENCES Natureza_Juridica(Id_Natureza_Juridica),
    FOREIGN KEY (Id_Uf) REFERENCES UF(Id_Uf),
    FOREIGN KEY (Id_Endereco) REFERENCES Endereco_Hospital(Id_Endereco)
);
GO

-- Inventário de leitos hospitalares
CREATE TABLE Leito(
    Id_Leito INT PRIMARY KEY IDENTITY(1,1),
    Id_Hospital INT NOT NULL,
    Id_Tipo_Leito INT NOT NULL,
    Quantidade_Existentes INT NULL,
    Quantidade_Sus INT NULL,
    Leitos_SUS NUMERIC(6,0) NULL,
    Leitos_Existentes NUMERIC(6,0) NULL,
    FOREIGN KEY(Id_Hospital) REFERENCES Hospital(Id_Hospital) ON DELETE CASCADE,
    FOREIGN KEY(Id_Tipo_Leito) REFERENCES Tipo_Leito(Id_Tipo_Leito) ON DELETE CASCADE
);
GO

-- Corpo clínico
CREATE TABLE Profissional_Saude(
    Id_Profissional_Saude INT PRIMARY KEY IDENTITY(1,1),
    Id_Hospital INT NOT NULL,
    Id_Especialidade INT NOT NULL,
    Nome VARCHAR(100) NOT NULL,
    Cargo_Funcao VARCHAR(100) NULL,
    FOREIGN KEY(Id_Hospital) REFERENCES Hospital(Id_Hospital) ON DELETE CASCADE,
    FOREIGN KEY(Id_Especialidade) REFERENCES Especialidade_Medica(Id_Especialidade) ON DELETE CASCADE
);
GO

-- Recursos hospitalares
CREATE TABLE Recurso_Hospitalar(
    Id_Recurso_Hospitalar INT PRIMARY KEY IDENTITY(1,1),
    Id_Hospital INT NOT NULL,
    Id_Tipo_Recurso INT NOT NULL,
    Nome VARCHAR(100) NOT NULL,
    Descricao VARCHAR(250) NULL,
    Quantidade INT NULL,
    Valor_Alocado DECIMAL(10,2) NULL,
    Data_Validade DATE NULL,
    Orgao_Responsavel CHAR(2) NULL,
    Versao SMALLINT NULL,
    Periodo_Vigencia DATE NULL,
    Estado_Conservacao VARCHAR(100) NULL,
    Fornecedor VARCHAR(100) NULL,
    FOREIGN KEY(Id_Hospital) REFERENCES Hospital(Id_Hospital) ON DELETE CASCADE,
    FOREIGN KEY(Id_Tipo_Recurso) REFERENCES Tipo_Recurso(Id_Tipo_Recurso) ON DELETE CASCADE
);
GO

-- Demanda assistencial
CREATE TABLE Demanda_Hospitalar(
    Id_Demanda INT PRIMARY KEY IDENTITY(1,1),
    Id_Hospital INT NOT NULL,
    Id_Tipo_Demanda INT NOT NULL,
    Data DATE NULL,
    Qt_Solicitacao INT NULL,
    Tempo_Medio_Espera TIME NULL,
    FOREIGN KEY(Id_Hospital) REFERENCES Hospital(Id_Hospital) ON DELETE CASCADE,
    FOREIGN KEY(Id_Tipo_Demanda) REFERENCES Tipo_Demanda(Id_Tipo_Demanda) ON DELETE CASCADE
);
GO

-- Indicadores de qualidade
CREATE TABLE Indicador_Qualidade(
    Id_Indicador_Qualidade INT PRIMARY KEY IDENTITY(1,1),
    Id_Hospital INT NOT NULL,
    Metodo_Calculo VARCHAR(250) NULL,
    Meta DECIMAL(10,2) NULL,
    Descricao VARCHAR(250) NULL,
    FOREIGN KEY(Id_Hospital) REFERENCES Hospital(Id_Hospital) ON DELETE CASCADE
);
GO

-- Serviços
CREATE TABLE Servico_Saude(
    Id_Servico_Saude INT PRIMARY KEY IDENTITY(1,1),
    Id_Hospital INT NOT NULL,
    Nome VARCHAR(100) NOT NULL,
    Descricao VARCHAR(250) NULL,
    FOREIGN KEY(Id_Hospital) REFERENCES Hospital(Id_Hospital) ON DELETE CASCADE
);
GO

-- Pacientes
CREATE TABLE Paciente (
    Id_Paciente INT PRIMARY KEY IDENTITY(1,1),
    N_AIH VARCHAR(50),
    Id_Hospital INT,
    Sexo VARCHAR(10),
    Idade INT,
    Diagnostico_Principal VARCHAR(50),
    Diagnosticos_Secundarios VARCHAR(500),
    Internacao DATE,
    Saida DATE,
    Mortalidade BIT,
    Num_Filhos INT,
    Contraceptivo_1 VARCHAR(50),
    Contraceptivo_2 VARCHAR(50),
    Ind_VDRL BIT,
    FOREIGN KEY (Id_Hospital) REFERENCES Hospital(Id_Hospital)
);


-- Atendimentos
CREATE TABLE Atendimento(
    Id_Atendimento INT PRIMARY KEY IDENTITY(1,1),
    Id_Paciente INT NOT NULL,
    Id_Hospital INT NOT NULL,
    Id_Class_Risco INT NOT NULL,
    Id_Tipo_Atendimento INT NOT NULL,
    Data_Hora DATETIME NULL,
    Inscricao_Paciente VARCHAR(250) NULL,
    Total_Usuarios_Atendidos INT NULL DEFAULT 0,
    FOREIGN KEY(Id_Paciente) REFERENCES Paciente(Id_Paciente) ON DELETE CASCADE,
    FOREIGN KEY(Id_Hospital) REFERENCES Hospital(Id_Hospital) ON DELETE CASCADE,
    FOREIGN KEY(Id_Class_Risco) REFERENCES Classificacao_Risco(Id_Class_Risco) ON DELETE CASCADE,
    FOREIGN KEY(Id_Tipo_Atendimento) REFERENCES Tipo_Atendimento(Id_Tipo_Atendimento) ON DELETE CASCADE
);
GO

-- Internações
CREATE TABLE Internacao(
    Id_Internacao INT PRIMARY KEY IDENTITY(1,1),
    Id_Paciente INT NOT NULL,
    Id_Hospital INT NULL,
    Sequencia_Internacao INT NULL,
    Data_Internacao DATE NULL,
    Data_Saida DATE NULL,
    Morte BIT NOT NULL DEFAULT 0,
    Identificacao_internacao INT NULL,
    Especialidade_Leito CHAR(100) NULL,
    Cobranca VARCHAR(100) NULL,
    Gestao_De_Risco BIT NULL,
    Procedimento_Solicitado INT NULL,
    Diaria_Acompanhante INT NULL,
    Ano_Internacao INT NULL,
    Mes_Internacao TINYINT NULL,
    FOREIGN KEY(Id_Paciente) REFERENCES Paciente(Id_Paciente) ON DELETE CASCADE,
    FOREIGN KEY(Id_Hospital) REFERENCES Hospital(Id_Hospital) ON DELETE CASCADE
);
GO

-- Procedimentos médicos
CREATE TABLE Procedimento_Medico(
    Id_Procedimento_Medico INT PRIMARY KEY IDENTITY(1,1),
    Descricao VARCHAR(250) NULL,
    Val_Sh DECIMAL(15,2) NULL,
    Val_Sp DECIMAL(15,2) NULL,
    Val_Sadt DECIMAL(15,2) NULL,
    Val_Tot DECIMAL(15,2) NULL
);
GO

-- Procedimentos de internação
CREATE TABLE Procedimento_Internacao(
    Id_Procedimento_internacao INT PRIMARY KEY IDENTITY(1,1),
    Id_Internacao INT NOT NULL,
    Id_Procedimento_Medico INT NOT NULL,
    Val_Sh_Fed DECIMAL(15,2) NULL,
    Val_Sp_Fed DECIMAL(15,2) NULL,
    Val_Sp_Ges DECIMAL(15,2) NULL,
    Val_Uci DECIMAL(15,2) NULL,
    Val_Sh_Ges DECIMAL(15,2) NULL,
    Procedimento_Realizado INT NULL,
    FOREIGN KEY(Id_Internacao) REFERENCES Internacao(Id_Internacao) ON DELETE CASCADE,
    FOREIGN KEY(Id_Procedimento_Medico) REFERENCES Procedimento_Medico(Id_Procedimento_Medico) ON DELETE CASCADE
);
GO

-- Detalhes de internação
CREATE TABLE Detalhe_Internacao(
    Id_Detalhe_Internacao INT PRIMARY KEY IDENTITY(1,1),
    Id_Internacao INT NOT NULL,
    Tipo_Diag_Secun INT NULL,
    Diag_Adicionais INT NULL,
    Permanencia_Hospital INT NULL,
    Cobranca VARCHAR(100) NULL,
    Complexidade VARCHAR(50) NULL,
    FOREIGN KEY(Id_Internacao) REFERENCES Internacao(Id_Internacao) ON DELETE CASCADE
);
GO

-- UTI
CREATE TABLE UTI(
    Id_UTI INT PRIMARY KEY IDENTITY(1,1),
    Id_Internacao INT NOT NULL,
    Tipo_UTI INT NULL,
    Qtd_Internacoes_Uti_Mes INT NULL,
    Qtd_Internacoes_Uti_Total INT NULL,
    Qtd_Internacoes_Periodo INT NULL,
    Qtd_Internacoes_Ate_Alta INT NULL,
    Qtd_Internacoes_Ano INT NULL,
    Total_Internacao INT NULL,
    FOREIGN KEY(Id_Internacao) REFERENCES Internacao(Id_Internacao) ON DELETE CASCADE
);
GO

-- Saúde reprodutiva
CREATE TABLE Saude_Reprodutiva(
    Id_Saude_Reprodutiva INT PRIMARY KEY IDENTITY(1,1),
    Id_Internacao INT NOT NULL,
    Exame_Vdrl BIT NULL,
    Contraceptivo_1 VARCHAR(100) NULL,
    Contraceptivo_2 VARCHAR(100) NULL,
    Num_Filhos INT NULL,
    FOREIGN KEY(Id_Internacao) REFERENCES Internacao(Id_Internacao) ON DELETE CASCADE
);
GO

-- Condições de saúde
CREATE TABLE Condicoes_Saude(
    Id_Condicoes_Saude INT PRIMARY KEY IDENTITY(1,1),
    Id_Saude_Reprodutiva INT NOT NULL,
    Exame_Vdrl BIT NOT NULL DEFAULT 0,
    Gestacao_Risco BIT NOT NULL DEFAULT 0,
    Infeccao_Hospitalar BIT NOT NULL DEFAULT 0,
    FOREIGN KEY(Id_Saude_Reprodutiva) REFERENCES Saude_Reprodutiva(Id_Saude_Reprodutiva) ON DELETE CASCADE
);
GO

-- Financeiro
CREATE TABLE Financeiro_AIH (
    Id_Financeiro INT PRIMARY KEY IDENTITY(1,1),
    N_AIH VARCHAR(200) NOT NULL,        -- chave de ligação com a AIH
    CGC_HOSP VARCHAR(200) NULL,     -- hospital
    Ano INT,
    Mes INT,

    Valor_SH DECIMAL(18,2) NULL,
    Valor_SP DECIMAL(18,2) NULL,
    Valor_SADT DECIMAL(18,2) NULL,
    Valor_RN DECIMAL(18,2) NULL,
    Valor_Acompanhante DECIMAL(18,2) NULL,
    Valor_Ortese_Protese DECIMAL(18,2) NULL,
    Valor_Sangue DECIMAL(18,2) NULL,
    Valor_SADT_Simplificado DECIMAL(18,2) NULL,
    Valor_Transporte DECIMAL(18,2) NULL,
    Valor_Obs_Sangue DECIMAL(18,2) NULL,
    Valor_Pediatria DECIMAL(18,2) NULL,
    Valor_UTI DECIMAL(18,2) NULL,
    Valor_UCI DECIMAL(18,2) NULL,

    Valor_Total DECIMAL(18,2) NULL,
    Usuario_Total VARCHAR(200) NULL,
    Data_Processamento DATETIME DEFAULT GETDATE()
);
GO

-- Gestor
CREATE TABLE Gestor(
    Id_Gestor INT PRIMARY KEY IDENTITY(1,1),
    Id_Financeiro INT NOT NULL,
    Tipo_Gestor INT NULL,
    CPF_Gestor CHAR(14) NULL,
    Data_Gestao DATE NULL,
    Remessa_Arquivos VARCHAR(3) NULL,
    FOREIGN KEY(Id_Financeiro) REFERENCES Financeiro_AIH(Id_Financeiro) ON DELETE CASCADE
);
GO

CREATE TABLE Leito_UTI_Detalhe(
    Id_Leito_UTI INT PRIMARY KEY IDENTITY(1,1),
    Id_Hospital INT NOT NULL,
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
    UTI_CORONARIANA_SUS VARCHAR(100),
    FOREIGN KEY(Id_Hospital) REFERENCES Hospital(Id_Hospital) ON DELETE CASCADE
);
GO

CREATE TABLE UTI_Atendimento (
  Id_UTI INT IDENTITY(1,1) PRIMARY KEY,
  Id_Internacao INT,
  UTI_MES_IN INT, UTI_MES_AN INT, UTI_MES_AL INT, UTI_MES_TO INT,
  Marca_UTI VARCHAR(200),
  UTI_INT_IN INT, UTI_INT_AN INT, UTI_INT_AL INT, UTI_INT_TO INT,
  Val_UTI DECIMAL(15,2),
  Marca_UCI VARCHAR(10),
  FOREIGN KEY (Id_Internacao) REFERENCES Internacao(Id_Internacao)
);

-------------------------------------------------------------------------

ALTER DATABASE [Sistema_Informações_Hospitalares] SET MULTI_USER

