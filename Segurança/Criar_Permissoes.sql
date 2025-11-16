USE Sistema_Informacoes_Hospitalares;
GO

-- CRIACAO DAS ROLES

CREATE ROLE ProfileVisualizadorViews AUTHORIZATION dbo;
CREATE ROLE ProfileAnalistaAvancado AUTHORIZATION dbo;
CREATE ROLE ProfileDesenvolvedorFullAccess AUTHORIZATION dbo;
GO

-- VISUALIZADOR (Somente SELECT nas views)

GRANT SELECT ON dbo.vw_Hospitais_Completo TO ProfileVisualizadorViews;
GRANT SELECT ON dbo.vw_Capacidade_Leitos TO ProfileVisualizadorViews;
GRANT SELECT ON dbo.vw_Ocupacao_UTI TO ProfileVisualizadorViews;
GRANT SELECT ON dbo.vw_Profissionais_Especialidade TO ProfileVisualizadorViews;
GRANT SELECT ON dbo.vw_Estatisticas_Mortalidade TO ProfileVisualizadorViews;
GRANT SELECT ON dbo.vw_Recursos_Hospitalares TO ProfileVisualizadorViews;
GRANT SELECT ON dbo.vw_Analise_Demanda TO ProfileVisualizadorViews;
GRANT SELECT ON dbo.vw_Procedimentos_Valores TO ProfileVisualizadorViews;
GRANT SELECT ON dbo.vw_Dashboard_Executivo TO ProfileVisualizadorViews;
GO

-- ANALISTA (SELECT NAS VIEWS + EXECUTE EM PROCEDURES)

GRANT SELECT ON dbo.vw_Hospitais_Completo TO ProfileAnalistaAvancado;
GRANT SELECT ON dbo.vw_Capacidade_Leitos TO ProfileAnalistaAvancado;
GRANT SELECT ON dbo.vw_Ocupacao_UTI TO ProfileAnalistaAvancado;
GRANT SELECT ON dbo.vw_Profissionais_Especialidade TO ProfileAnalistaAvancado;
GRANT SELECT ON dbo.vw_Estatisticas_Mortalidade TO ProfileAnalistaAvancado;
GRANT SELECT ON dbo.vw_Recursos_Hospitalares TO ProfileAnalistaAvancado;
GRANT SELECT ON dbo.vw_Analise_Demanda TO ProfileAnalistaAvancado;
GRANT SELECT ON dbo.vw_Procedimentos_Valores TO ProfileAnalistaAvancado;
GRANT SELECT ON dbo.vw_Dashboard_Executivo TO ProfileAnalistaAvancado;
GO

GRANT EXECUTE ON OBJECT::dbo.sp_ETL_Extracao_Brasil_UFs TO ProfileAnalistaAvancado;
GRANT EXECUTE ON OBJECT::dbo.sp_ETL_Transformacao_Brasil_UFs TO ProfileAnalistaAvancado;
GRANT EXECUTE ON OBJECT::dbo.sp_ETL_Load_Brasil_UFs TO ProfileAnalistaAvancado;

GRANT EXECUTE ON OBJECT::dbo.sp_ETL_Extracao_Leitos TO ProfileAnalistaAvancado;
GRANT EXECUTE ON OBJECT::dbo.sp_ETL_Transformacao_Leitos TO ProfileAnalistaAvancado;
GRANT EXECUTE ON OBJECT::dbo.sp_ETL_Load_Leitos TO ProfileAnalistaAvancado;

GRANT EXECUTE ON OBJECT::dbo.sp_ETL_Extracao_Municipios TO ProfileAnalistaAvancado;
GRANT EXECUTE ON OBJECT::dbo.sp_ETL_Transformacao_Municipios TO ProfileAnalistaAvancado;
GRANT EXECUTE ON OBJECT::dbo.sp_ETL_Load_Municipios TO ProfileAnalistaAvancado;
GO

-- DESENVOLVEDOR (Acesso a total do banco)

ALTER ROLE db_owner ADD MEMBER ProfileDesenvolvedorFullAccess;
GO

-- VISUALIZADOR
CREATE USER User_Visualizador FOR LOGIN Login_Visualizador;
ALTER ROLE ProfileVisualizadorViews ADD MEMBER User_Visualizador;

-- ANALISTA
CREATE USER User_Analista FOR LOGIN Login_Analista;
ALTER ROLE ProfileAnalistaAvancado ADD MEMBER User_Analista;

-- DESENVOLVEDOR
CREATE USER User_Desenvolvedor FOR LOGIN Login_Desenvolvedor;
ALTER ROLE ProfileDesenvolvedorFullAccess ADD MEMBER User_Desenvolvedor;
GO
