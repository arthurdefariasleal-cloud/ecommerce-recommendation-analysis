# Recomendações de Produtos em um E-Commmerce

# Contexto
Este projeto tem como objetivo gerar um sistema de recomendação de produtos para um e-commerce a partir do histórico de compras dos clientes. Utilizei técnicas de análise de dados exploratória, consultas SQL avançadas para modelagem de co-ocorrência de compras e visualização de resultados em dashboard com Power BI. O resultado esperado é uma lista rankeada de produtos recomendados para cada ítem, facilitando estratégias de cross-sell e aumentando a efetividade de campanhas de marketing.

# Entendimento do Negócio
No contexto de e-commerce, entender o comportamento de compra dos clientes é essencial para elevar receita a partir da sua própria base ativa. Estratégias de cross-sell e recomendação de produtos são amplamente utilizadas para melhorar a experiência do cliente e elevar ticket médio. 

Neste cenário, o problema de negócio consiste em transformar os dados transacionais em uma base de recomendações que indique, para cada produto, quais outros itens apresentam maior chance de compra conjunta. 

**Análises Realizadas:**
* Análise Exploratória (EDA) para compreender volume, frequência e distribuição de compras
* Análise de co-ocorrência de produtos para identificar produtos comprados juntos
* Análise de afinidade entre produtos para apoiar recomendações de cross-sell

**Principais KPIs:**
* Probabilidade de compra associdada entre produtos
* Frequência de co-ocorrência de produtos no mesmo pedido
* Potencial de cros-sell por produto

# Análise do Modelo Atual

As recomendações de produtos atuais deste e-commerce seguem critérios simples como "itens mais vendidos" ou "escolhas manuais" e não se baseiam em uma análise estruturada dos dados de compras. Como limitação, esse modelo não é capaz de capturar padrões de compras e nem a força de associação entre produtos. 

A análise visa otimizar este processo usando dados transacionais para identificar afinidades entre itens e gerar recomendações baseadas em probabilidade de compra conjunta.

# Descrição dos Dados
Este projeto utiliza quatro tabelas relacionais:

### Tabela Fato
* **base_compras**: registra o evento de compra do produto. Contém registros de identificador do usuário, produto adquirido e informações de dia da semana e hora da compra.

### Tabelas Dimensão
* **base_produtos**: fornece informações descritivas dos produtos (nome, departamento e tipo de produto).
* **base_departamentos**: classifica os produtos por departamentos.
* **base_tipo_de_produto**: categorização mais granular dos itens.

# Preparação dos Dados
Antes de iniciar as análises, foi realizado um Sanity Check com SQL para validar a consistência, integridade e qualidade das bases.

**Considerações Importantes:**
1. As tabelas foram avaliadas quanto a volume, unicidade, nulos, chaves de referência, intervalos de valores e outiliers.
2. Duplicidades em compras podem representar comportamento esperado (ex.: usuário comprar mais de um produto no mesmo dia/horário).

**Etapas da Preparação no Pipeline:**
1. Checagem do volume de dados nas quatro tabelas (fato e dimensões).
2. Verificação de unicidade das chaves primárias (product_id, department_id, aisle_id).
3. Verificação de valores nulos (campos-chave em compras e cadastro de produtos).
4. Verificação de referências (integridade): compras sem produto cadastrado e produtos sem departamento/tipo.
5. Checagem de outliers (ex.: clientes com volume de itens comprados muito acima do esperado).
6. União de tabelas (JOIN) para garantir que o modelo fato-dimensão se conecte corretamente.

# Análise Exploratória (EDA)
A EDA teve como objetivo entender o comportamento de compra dos usuários a partir de três relações fato-dimensão.

### Distribuição de Vendas por Departamento
Analisa quais departamentos concentram maior volume de produtos vendidos, ajudando a entender onde está a maior demanda.

Código SQL:

Resultados apresentados e discutidos em: [Avaliação dos Resultados](#avaliação-dos-resultados)

### Distribuição de Vendas por Dia da Semana
Avaliar como o volume de compras se comporta ao longo da semana, identificando possíveis picos de demanda.

Código SQL:

Resultados apresentados e discutidos em: [Avaliação dos Resultados](#avaliação-dos-resultados)

### Distribuição por Hora do Dia
Mostra em quais horários as compras se concentram

Código SQL:

Resultados apresentados e discutidos em: [Avaliação dos Resultados](#avaliação-dos-resultados)

### TOP 5 Produtos Mais Vendidos por Departamento
Ranking dos produtos líderes em cada departamento, incluindo frequência relativa e acumulada.

Código SQL:

Resultados apresentados e discutidos em: [Avaliação dos Resultados](#avaliação-dos-resultados)

### Concentração de Tipos de Produtos por Hora do Dia
Analisa quais tipos de produtos (ailes) dominam as vendas em cada hora do dia.

Código SQL:

Resultados apresentados e discutidos em: [Avaliação dos Resultados](#avaliação-dos-resultados)


# Avaliação dos Resultados

