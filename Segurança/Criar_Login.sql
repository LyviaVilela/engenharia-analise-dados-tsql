USE Sistema_Informacoes_Hospitalares;
GO

CREATE LOGIN Login_Visualizador 
WITH PASSWORD = 'Visualizador123!', CHECK_POLICY = ON;
GO

CREATE LOGIN Login_Analista 
WITH PASSWORD = 'Analista123!', CHECK_POLICY = ON;
GO

CREATE LOGIN Login_Desenvolvedor 
WITH PASSWORD = 'Desenvolvedor123!!', CHECK_POLICY = ON;
GO
