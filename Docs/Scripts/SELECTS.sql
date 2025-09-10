-- VALIDAÇÃO DA ESTRUTURA DO BANCO - Sistema_Informações_Hospitalares
-- Data: 10/09/2024



USE Sistema_Informações_Hospitalares;
GO


-- 1. Regiao
SELECT * FROM Regiao;

-- 2. Nivel_de_Escolaridade  
SELECT * FROM Nivel_de_Escolaridade;

-- 3. Tipo_Unidade
SELECT * FROM Tipo_Unidade;

-- 4. Tipo_Atendimento
SELECT * FROM Tipo_Atendimento;

-- 5. Tipo_Leito
SELECT * FROM Tipo_Leito;

-- 6. CID10
SELECT * FROM CID10;

-- 7. Especialidade_Medica
SELECT * FROM Especialidade_Medica;

-- 8. Classificacao_Risco
SELECT * FROM Classificacao_Risco;

-- 9. Tipo_Recurso
SELECT * FROM Tipo_Recurso;

-- 10. Tipo_Demanda
SELECT * FROM Tipo_Demanda;

-- 11. Faixa_Etaria
SELECT * FROM Faixa_Etaria;

-- 12. RACA_COR
SELECT * FROM RACA_COR;

-- 13. Natureza_Juridica
SELECT * FROM Natureza_Juridica;

-- 14. UF
SELECT * FROM UF;

-- 15. Municipio
SELECT * FROM Municipio;

-- 16. Endereco_Hospital
SELECT * FROM Endereco_Hospital;

-- 17. Hospital
SELECT * FROM Hospital;

-- 18. Leito
SELECT * FROM Leito;

-- 19. Profissional_Saude
SELECT * FROM Profissional_Saude;

-- 20. Recurso_Hospitalar
SELECT * FROM Recurso_Hospitalar;

-- 21. Demanda_Hospitalar
SELECT * FROM Demanda_Hospitalar;

-- 22. Indicador_Qualidade
SELECT * FROM Indicador_Qualidade;

-- 23. Servico_Saude
SELECT * FROM Servico_Saude;

-- 24. Paciente
SELECT * FROM Paciente;

-- 25. Atendimento
SELECT * FROM Atendimento;

-- 26. Procedimento_Medico
SELECT * FROM Procedimento_Medico;

-- 27. Internacao
SELECT * FROM Internacao;

-- 28. Procedimento_Internacao
SELECT * FROM Procedimento_Internacao;

-- 29. Detalhe_Internacao
SELECT * FROM Detalhe_Internacao;

-- 30. UTI
SELECT * FROM UTI;

-- 31. Saude_Reprodutiva
SELECT * FROM Saude_Reprodutiva;

-- 32. Condicoes_Saude
SELECT * FROM Condicoes_Saude;

-- 33. Financeiro
SELECT * FROM Financeiro;

-- 34. Gestor
SELECT * FROM Gestor;
GO

-- 1. Regiao
SELECT 'Regiao' AS Tabela, COUNT(*) AS Registros FROM Regiao;

-- 2. Nivel_de_Escolaridade  
SELECT 'Nivel_de_Escolaridade' AS Tabela, COUNT(*) AS Registros FROM Nivel_de_Escolaridade;

-- 3. Tipo_Unidade
SELECT 'Tipo_Unidade' AS Tabela, COUNT(*) AS Registros FROM Tipo_Unidade;

-- 4. Tipo_Atendimento
SELECT 'Tipo_Atendimento' AS Tabela, COUNT(*) AS Registros FROM Tipo_Atendimento;

-- 5. Tipo_Leito
SELECT 'Tipo_Leito' AS Tabela, COUNT(*) AS Registros FROM Tipo_Leito;

-- 6. CID10
SELECT 'CID10' AS Tabela, COUNT(*) AS Registros FROM CID10;

-- 7. Especialidade_Medica
SELECT 'Especialidade_Medica' AS Tabela, COUNT(*) AS Registros FROM Especialidade_Medica;

-- 8. Classificacao_Risco
SELECT 'Classificacao_Risco' AS Tabela, COUNT(*) AS Registros FROM Classificacao_Risco;

-- 9. Tipo_Recurso
SELECT 'Tipo_Recurso' AS Tabela, COUNT(*) AS Registros FROM Tipo_Recurso;

-- 10. Tipo_Demanda
SELECT 'Tipo_Demanda' AS Tabela, COUNT(*) AS Registros FROM Tipo_Demanda;

-- 11. Faixa_Etaria
SELECT 'Faixa_Etaria' AS Tabela, COUNT(*) AS Registros FROM Faixa_Etaria;

-- 12. RACA_COR
SELECT 'RACA_COR' AS Tabela, COUNT(*) AS Registros FROM RACA_COR;

-- 13. Natureza_Juridica
SELECT 'Natureza_Juridica' AS Tabela, COUNT(*) AS Registros FROM Natureza_Juridica;

-- 14. UF
SELECT 'UF' AS Tabela, COUNT(*) AS Registros FROM UF;

-- 15. Municipio
SELECT 'Municipio' AS Tabela, COUNT(*) AS Registros FROM Municipio;

-- 16. Endereco_Hospital
SELECT 'Endereco_Hospital' AS Tabela, COUNT(*) AS Registros FROM Endereco_Hospital;

-- 17. Hospital
SELECT 'Hospital' AS Tabela, COUNT(*) AS Registros FROM Hospital;

-- 18. Leito
SELECT 'Leito' AS Tabela, COUNT(*) AS Registros FROM Leito;

-- 19. Profissional_Saude
SELECT 'Profissional_Saude' AS Tabela, COUNT(*) AS Registros FROM Profissional_Saude;

-- 20. Recurso_Hospitalar
SELECT 'Recurso_Hospitalar' AS Tabela, COUNT(*) AS Registros FROM Recurso_Hospitalar;

-- 21. Demanda_Hospitalar
SELECT 'Demanda_Hospitalar' AS Tabela, COUNT(*) AS Registros FROM Demanda_Hospitalar;

-- 22. Indicador_Qualidade
SELECT 'Indicador_Qualidade' AS Tabela, COUNT(*) AS Registros FROM Indicador_Qualidade;

-- 23. Servico_Saude
SELECT 'Servico_Saude' AS Tabela, COUNT(*) AS Registros FROM Servico_Saude;

-- 24. Paciente
SELECT 'Paciente' AS Tabela, COUNT(*) AS Registros FROM Paciente;

-- 25. Atendimento
SELECT 'Atendimento' AS Tabela, COUNT(*) AS Registros FROM Atendimento;

-- 26. Procedimento_Medico
SELECT 'Procedimento_Medico' AS Tabela, COUNT(*) AS Registros FROM Procedimento_Medico;

-- 27. Internacao
SELECT 'Internacao' AS Tabela, COUNT(*) AS Registros FROM Internacao;

-- 28. Procedimento_Internacao
SELECT 'Procedimento_Internacao' AS Tabela, COUNT(*) AS Registros FROM Procedimento_Internacao;

-- 29. Detalhe_Internacao
SELECT 'Detalhe_Internacao' AS Tabela, COUNT(*) AS Registros FROM Detalhe_Internacao;

-- 30. UTI
SELECT 'UTI' AS Tabela, COUNT(*) AS Registros FROM UTI;

-- 31. Saude_Reprodutiva
SELECT 'Saude_Reprodutiva' AS Tabela, COUNT(*) AS Registros FROM Saude_Reprodutiva;

-- 32. Condicoes_Saude
SELECT 'Condicoes_Saude' AS Tabela, COUNT(*) AS Registros FROM Condicoes_Saude;

-- 33. Financeiro
SELECT 'Financeiro' AS Tabela, COUNT(*) AS Registros FROM Financeiro;

-- 34. Gestor
SELECT 'Gestor' AS Tabela, COUNT(*) AS Registros FROM Gestor;
GO