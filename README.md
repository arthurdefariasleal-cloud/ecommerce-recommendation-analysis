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

### - Distribuição de Vendas por Departamento
Analisa quais departamentos concentram maior volume de produtos vendidos, ajudando a entender onde está a maior demanda.

🔗 Código SQL:  [02_eda.sql](./sql/02_eda.sql)  
➡️ Resultados apresentados e discutidos em: [Avaliação dos Resultados](#avaliação-dos-resultados)

### - Distribuição de Vendas por Dia da Semana
Avaliar como o volume de compras se comporta ao longo da semana, identificando possíveis picos de demanda.

🔗 Código SQL:  [02_eda.sql](./sql/02_eda.sql)  
➡️ Resultados apresentados e discutidos em: [Avaliação dos Resultados](#avaliação-dos-resultados)

### - Distribuição por Hora do Dia
Mostra em quais horários as compras se concentram

🔗 Código SQL:  [02_eda.sql](./sql/02_eda.sql)  
➡️ Resultados apresentados e discutidos em: [Avaliação dos Resultados](#avaliação-dos-resultados)

### - TOP 5 Produtos Mais Vendidos por Departamento
Ranking dos produtos líderes em cada departamento, incluindo frequência relativa e acumulada.

🔗 Código SQL:  [02_eda.sql](./sql/02_eda.sql)  
➡️ Resultados apresentados e discutidos em: [Avaliação dos Resultados](#avaliação-dos-resultados)

### - Concentração de Tipos de Produtos por Hora do Dia
Analisa quais tipos de produtos (ailes) dominam as vendas em cada hora do dia.

🔗 Código SQL:  [02_eda.sql](./sql/02_eda.sql)  
➡️ Resultados apresentados e discutidos em: [Avaliação dos Resultados](#avaliação-dos-resultados)

# Modelagem
Como a base de dados possui um volume elevado, a análise de co-ocorrência completa resultaria em um alto número de combinações com baixa relevância. Por isso, optei por focar em recomendações mais úteis, avaliando compras conjuntas apenas para produtos relevantes, definidos pelo número de clientes distintos que compram cada item. A modelagem foi implementada com SQL(PostegreSQL) e os scripts estão organizados na paste /sql.

## Objetivo da Modelagem
* Calcular co-ocorrências entre pares de produtos dentro do mesmo pedido;
* Quantificar a força de associação entre produtos;
* Gerar uma base que, para cada produto, retorne os itens mais frequentemente comprados em conjunto, com métricas que possibilitem ranqueamento e filtragem.

## Etapas da Modelagem

### 1) Definição de Produto Relevante
Aqui o primeiro o passo foi medir a popularidade de cada produto. Para isso, calculei quantos clientes distintos compraram cada um deles. 

Em seguida, analisei a distribuição desses valores para diferentes pontos de corte (50, 100, 200, 500) e escolho o critério que melhor equilibra abragência e representatividade.

No projeto, defini como produto relevante aquele comprado por pelo menos 500 clientes (ponto de corte) distintos, mantendo uma cobertura de ~ 95% dos clientes.

🔗 Código SQL:  [02_modelo.sql](./sql/03_modelo.sql)  
➡️ Resultados e discutidos em: [Avaliação dos Resultados](#avaliação-dos-resultados)

### 2) Base Analítica para Recomendação
Definido produto relevante, construí uma base intermediária relacionando clientes x produtos relevantes. Essa tabela é a base para o cálculo de co-ocorrências.

🔗 Código SQL:  [02_modelo.sql](./sql/03_modelo.sql)  
➡️ Resultados e discutidos em: [Avaliação dos Resultados](#avaliação-dos-resultados)

### 3) Análise de Co-ocorrência
A co-ocorrência foi calculada considerando apenas pares de produtos comprados pelo mesmo usuário, aplicando um limite mínimo de ocorrências (no meu caso, 50 ocorrências) para evitar associações fracas.

🔗 Código SQL:  [02_modelo.sql](./sql/03_modelo.sql)  
➡️ Resultados e discutidos em: [Avaliação dos Resultados](#avaliação-dos-resultados)

### 4) Probabilidade de Compra
A partir dos pares com co-ocorrência, calculei a probabilidade condicional de compra. Para isso, transformei os pares em relações direcionais (A -> B e B -> A) e calculei: 

**probabilidade_compra = (clientes_ab) / clientes_base**

🔗 Código SQL:  [02_modelo.sql](./sql/03_modelo.sql)  
➡️ Resultados e discutidos em: [Avaliação dos Resultados](#avaliação-dos-resultados)

### 5) Ranqueamento das Recomendações
Por fim, realizei o ranqueamento destas recomendações para manter a base final objetiva e fácil de utilizar.

**Critérios de ordenação:**
1. Maior probabilidade de compra condicional
2. Maior número de clientes em comum (clientes_ab) como critério de desempate

Depois, selecionei apenas o TOP 3 recomendações por produto, gerando a base final que soluciona o modelo.

🔗 Código SQL:  [02_modelo.sql](./sql/03_modelo.sql)  
➡️ Resultados e discutidos em: [Avaliação dos Resultados](#avaliação-dos-resultados)

# Avaliação dos Resultados
Aqui o objetivo é gerar insights a partir dos padrões de consumo e verificar se as associações identificadas possuem valor prático para estratégias de recomendações.

### Distribuição de Vendas por Departamento
<img width="344" height="446" alt="image" src="https://github.com/user-attachments/assets/343309cc-f8f2-4296-aa57-8adbf535ae09" />

A análise mostrou forte concentração de vendas em poucos departamentos, com destaque para:
* Snacks (~866 mil)
* Beverages (~809 mil)
* Frozen (~670 mil)
* Pantry (~562 mil)
  
Departamentos como Bakery, Canned Goods e Dry Good Pasta apresentam volume relevante, porém menor. Já departamentos como Pets, Missing, Other e Bulk têm baixa participação.

**Insight principal:**
Snack e Beverages são estruturais para o negócio e devem ser priorizados em qualquer estratégia de recomendação. Estes dois departamentos concentram tráfego, recorrência e oportunidades de cross-sell.

### Distribuição de Vendas por Dia da Semana
<img width="454" height="325" alt="image" src="https://github.com/user-attachments/assets/aafeffc5-d827-42c6-ac9c-8fa6425d0e76" />

Aqui temos um padrão claro de concentração no início e no final da semana:
* Domingo apresenta o maior volume (~970 mil);
* Segunda também é elevada (~907 mil);
* Queda entre terça e quinta;
* O volume volta a crescer na sexta e no sábado.
  
Este comportamento sugere compras de reposição no início da semana e compras de consumo imediato próxima ao fim de semana.

**Insight principal:**
Estratégias de recomendação devem variar conforme o dia.
* Domingo/segunda focar em recomendações mais amplas (produtos de despensa/estoque)
* Sexta/sabádo focar em recomendações de produtos de consumo rápido (snacks e bebidas, por exemplo)

### Distribuião de Vendas por Hora do Dia
<img width="998" height="266" alt="image" src="https://github.com/user-attachments/assets/c2ee1355-95bf-46d5-b463-734e657bc089" />

Padrão de consumo bem definido:
* Baixo volume na madrugada (0h-5h);
* Crescimento a partir das 6h;
* Pico entre 10h-15h (horário comercial);
* Queda gradual após 16h.

**Insight principal:**
Os valores de pico indicam que o usuário está mais propenso a aceitar recomendações em horário comercial (10h-15h).

### TOP 5 Produtos por Departamento
<img width="492" height="363" alt="image" src="https://github.com/user-attachments/assets/039f103b-3d8f-45ab-ac06-55b67c015ce1" />

**Obs.:** a tabela completa com os resultados está disponível em [dashboard.pbix](./reports/dashboard.pbix)

Padrões observados:
* Beverages: predominância de águas e bebidas leves;
* Deli: forte concentração em poucos itens (ex.: hummus);
* Frozen: liderança de frutas e vegetais congelados;
* Meat & Seafood: proteínas magras dominam;
* Canned Goods: itens base de preparo (grãos, tomates)








