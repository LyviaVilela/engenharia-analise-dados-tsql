# 🗄️ Projeto Final: Engenharia e Análise de Dados com T-SQL | Sistema de Informações Hospitalares – SUS


###  Visão Geral e Objetivos

Este projeto foi desenvolvido para simular um ciclo completo de engenharia e análise de dados, utilizando exclusivamente T-SQL no SQL Server. O foco é trabalhar com um dataset público massivo de hospitais e leitos do SUS e transformá-lo em insights de negócio acionáveis sobre o sistema de saúde brasileiro.

### Tema: Saúde Pública – Sistema de Informações Hospitalares do SUS

**Objetivo:**  Transformar dados históricos de hospitais, leitos e atendimentos do SUS em insights acionáveis sobre a capacidade hospitalar, distribuição geográfica e padrões de atendimento no Brasil.

**Principais categorias analisadas:**
- 🏥 Hospitais – quantidade, tipo e localização
- 🛏️ Leitos – disponibilidade por tipo (clínicos, cirúrgicos, UTI etc.)
- 📊 Atendimentos – volumes de internações e procedimentos
- 🌎 Distribuição geográfica – análise por estado, região e município

###  **📊 Organização & Ferramentas**
- Versionamento: Git para código e histórico de alterações
- Organização: Quadro Kanban para tarefas e progresso
- Planejamento: Perguntas de negócio definidas para guiar análises
- visualização (opcional): Dashboards no Power BI ou Tableau

---
## 🔎 Plano de Análise

## 🌎Capacidade e Distribuição Geográfica

- Quantos leitos de UTI (total, adulto, pediátrico, neonatal) existem por região/estado?
- Como a disponibilidade de leitos de UTI coronariana se distribui entre as regiões do país em relação à população total?
- Onde faltam leitos de UTI em relação à população?
- Estados com maior deficiência de UTI SUS
- Regiões com maior carência de leitos especializados

## 📊Eficiência e Ocupação

- Quais hospitais têm maior ociosidade de UTI?
- Os leitos estão concentrados em poucos hospitais?
- Top 10 municípios com melhor e pior taxa de leitos por habitante

## 📈Especialização e Diversidade

- Como a natureza jurídica influencia na oferta de leitos?
- Quais hospitais são referência em leitos pediátricos/neonatais?
- Qual a diversidade de oferta de leitos por região?

## 👤 SUS vs. Privado

- Qual a proporção de leitos SUS vs. particulares por tipo de UTI?
- Qual tipo de gestão tem mais leitos de UTI?
- Onde há capacidade ociosa que poderia ser convertida para SUS?

--------

[backup do banco de dados](https://drive.google.com/file/d/1PK0-OjWw7Xm1BRYNa3cJSd7iBVR0jCZV/view?usp=drivesdk)

---
## Dataset

- **Dataset:**  [Hospital e Leitos](https://dados.gov.br/dados/conjuntos-dados/hospitais-e-leitos?utm_source=chatgpt.com)
  - **Descrição:** Relação de hospitais, quantidade e tipo de leitos (UTI, clínico, cirúrgico, etc.), esfera administrativa (federal, estadual, municipal, privado), localização (município, estado). 
  - **Formatos:** Arquivos CSV disponibilizados para download  
- **Dicionário de Dados:** [Link para o Dicionário](https://s3.sa-east-1.amazonaws.com/ckan.saude.gov.br/Leitos_SUS/Dicion%C3%A1rio_Leito_hospitalar.pdf) 
- **Dataset Usado:** [Leitos 2024](https://educadventista-my.sharepoint.com/:x:/r/personal/lyvia_vilela_educadventista_org/Documents/Leitos_2024%20(1).xlsx?d=wea1f64dd5af64c148f5d0ded7948c194&e=4%3a422a7541aff74b689022d01e78574bc1&sharingv2=true&fromShare=true&at=9)

## Datasets de Apoio
- **Dataset:** [Estimativas da População](https://www.ibge.gov.br/estatisticas/sociais/populacao/9103-estimativas-de-populacao.html?=&t=downloads)
  - **Descrição:** Estimativas da população residente para os anos recentes, por município e estado. Será a base para o cálculo de métricas per capita.
  - **Formatos:** Arquivos XLS, PDF e ODS disponibilizados para download
- **Dataset Usado:** [Estimativa de 2024](https://educadventista-my.sharepoint.com/:x:/r/personal/lyvia_vilela_educadventista_org/Documents/estimativa_dou_2024.xlsx?d=w54d4ae4754514e30801b6887affc6552&e=4%3afe359c008696438d917c6e8ef570e3ee&sharingv2=true&fromShare=true&at=9)

- **Dataset:** [SIH/SUS - Hospital Admissions Municipalities](https://www.kaggle.com/datasets/andersonfranca/sistema-de-informaes-hospitalares-sus)
  - **Descrição:** Dados de internações e procedimentos hospitalares financiados pelo SUS (quantidade, valor, tempo de permanência). Permitirá analisar a utilização e eficiência.
  - **Formatos:** Arquivos CSV disponibilizados para download
- **Dataset Usado:** [RD202401](https://educadventista-my.sharepoint.com/:x:/r/personal/lyvia_vilela_educadventista_org/Documents/RD202401.xlsx?d=w3dc9f8220c8e4ed0bfc1fade12374585&e=4%3a3444863d26bb447699e9a2e70d7fb70a&sharingv2=true&fromShare=true&at=9)

---
## Gestão e Acompanhamento

- **Kanban/Quadro de Gestão:** [Quadro de Gestão](https://trello.com/invite/b/68a5f12cadae6b74df85dc57/ATTI45e35eb915bc39df23a920147c3799c1637B7881/analise-de-dados)
- **Dashboard de BI:** (Em Desenvolvimento)
  
---
## 📅 Cronograma de Entregas

### ** Fase 1: Concepção, Análise de Dados e Modelagem** *(Semanas 1-3)*

| Semana | Entrega | Foco | 
|--------|---------|------|
| **Semana 1** | **Kick-off e Análise Exploratória** | Definição do tema, encontrar e analisar o dataset bruto. Criação do repositório/Kanban. 
| **Semana 2** | **Requisitos e Plano de Análise** | Com base na análise, criar o Modelo Lógico e o documento do Plano de Análise, definindo as perguntas de negócio. 
| **Semana 3** | **Modelagem Física** | Finalizar o Modelo Físico com tipos de dados e constraints do SQL Server. 

### ** Fase 2: Estruturação, ETL e Carga** *(Semanas 4-6)*

| Semana | Entrega | Foco |
|--------|---------|------|
| **Semana 4** | **Construção do Banco (DDL)** | Criar todos os scripts DDL e executar a estrutura do banco. 
| **Semana 5** | **Desenvolvimento do Processo de ETL em T-SQL** | Codificar as Stored Procedures de ETL. Testar a extração e transformação com uma amostra dos dados. 
| **Semana 6** | **Execução do ETL e Consultas Exploratórias** | Executar o ETL completo. Criar consultas DQL para validar a carga e explorar os dados. 

### ** Fase 3: Otimização e Análise** *(Semanas 7-10)*

| Semana | Entrega | Foco |
|--------|---------|------|
| **Semana 7** | **Views e Índices** | Criar views para simplificar a análise e índices para otimizar as futuras consultas analíticas. 
| **Semana 8** | **Stored Procedures Analíticas** | Implementar as Stored Procedures que respondem às perguntas do Plano de Análise, gerando métricas e relatórios. 
| **Semana 9** | **Triggers e Transações (DTL)** | Criar triggers para auditoria/validação e controlar transações. 
| **Semana 10** | **Segurança (DCL)** | Implementar a estratégia de segurança com logins, usuários e perfis. 

### ** Fase 4: Finalização e Entrega** *(Semanas 11-13)*

| Semana | Entrega | Foco |
|--------|---------|------|
| **Semana 11** | **Documentação e (Opcional) Dashboard** | Finalizar a documentação. Iniciar a criação do dashboard de BI (opcional). 
| **Semana 12** | **Preparação da Entrega Final** | Gravar o vídeo de demonstração e preparar a apresentação final. 
| **Semana 13** | **Apresentação Final** | Defesa do projeto, demonstrando o processo de ETL e os insights gerados pelas análises. 

---

## 👥 Equipe do Projeto

| Nome | Papel | GitHub |
|------|-------|--------|
|**Guilherme Silviano**| Analista de dados | [@guisilviano](https://github.com/guisilviano) |
| **Lyvia** | Engenheira de dados | [@LyviaVilela](https://github.com/LyviaVilela) |
| **Nicole** | Analista de dados | [@niiukiyo](https://github.com/niiukiyo) |
| **Paulo** | Arquiteto de dados | [@paulok767](https://github.com/paulok767) |
| **Sergio** | Arquiteto de dados | [@SergioJunior20](https://github.com/SergioJunior20) |
| **Tiago** | Engenheiro de dados |[@TiagoCosta777](https://github.com/TiagoCosta777) |


<div align="center">

**Disciplina:** Gerenciamento de Banco de Dados  
**Instituição:** Unasp 

**Período:** 2025.2


