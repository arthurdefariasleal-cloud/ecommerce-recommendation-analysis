-- quantos clientes compraram cada produto

DROP TABLE IF EXISTS tmp_produto_clientes;

CREATE TEMP TABLE tmp_produto_clientes as
SELECT
  bc.product_id,
  COUNT(DISTINCT bc.user_id) as clientes
FROM pao_de_mel.base_compras bc
GROUP BY bc.product_id
ORDER BY clientes desc;

CREATE INDEX ON tmp_produto_clientes (clientes DESC);
CREATE INDEX ON tmp_produto_clientes (product_id);
ANALYZE tmp_produto_clientes;

SELECT *
FROM tmp_produto_clientes;

-- entender a distribuição (escolher um corte)

SELECT
  SUM(CASE WHEN clientes >= 50  THEN 1 ELSE 0 END) as produtos_ge_50,
  SUM(CASE WHEN clientes >= 100 THEN 1 ELSE 0 END) as produtos_ge_100,
  SUM(CASE WHEN clientes >= 200 THEN 1 ELSE 0 END) as produtos_ge_200,
  SUM(CASE WHEN clientes >= 500 THEN 1 ELSE 0 END) as produtos_ge_500
FROM tmp_produto_clientes;


-- calcular cobertura de clientes para corte

WITH produtos_relevantes as(
  SELECT product_id
  FROM tmp_produto_clientes
  WHERE clientes >= 500
),
total as(
  SELECT COUNT(DISTINCT user_id) as total_clientes
  FROM pao_de_mel.base_compras
),
cobertura as(
  SELECT COUNT(DISTINCT bc.user_id) as clientes_cobertos
  FROM pao_de_mel.base_compras bc
  JOIN produtos_relevantes pr ON pr.product_id = bc.product_id
)
SELECT
  clientes_cobertos, total_clientes,
  ROUND(clientes_cobertos::numeric / total_clientes, 4) as cobertura_pct
FROM cobertura, total;


-- cria base clientes x Produtos apenas com produtos relevantes

DROP TABLE IF EXISTS tmp_produto_clientes;

CREATE TEMP TABLE tmp_produto_clientes AS
SELECT
  bc.product_id,
  COUNT(DISTINCT bc.user_id) AS clientes
FROM pao_de_mel.base_compras bc
GROUP BY bc.product_id;


DROP TABLE IF EXISTS tmp_produtos_relevantes;
CREATE TEMP TABLE tmp_produtos_relevantes as
SELECT
  product_id,
  clientes
FROM tmp_produto_clientes
WHERE clientes >= 500;


DROP TABLE IF EXISTS tmp_user_product_relevante;

CREATE TEMP TABLE tmp_user_product_relevante AS
SELECT DISTINCT
  bc.user_id,
  bc.product_id
FROM pao_de_mel.base_compras bc
JOIN tmp_produtos_relevantes pr
  ON pr.product_id = bc.product_id;

CREATE INDEX ON tmp_user_product_relevante (user_id, product_id);
CREATE INDEX ON tmp_user_product_relevante (product_id, user_id);

ANALYZE tmp_user_product_relevante;



-- coocorrência
DROP TABLE IF EXISTS tmp_pairs_half;

CREATE TEMP TABLE tmp_pairs_half AS
SELECT
  up1.product_id AS produto_a,
  up2.product_id AS produto_b,
  COUNT(*) AS clientes_ab
FROM tmp_user_product_relevante up1
JOIN tmp_user_product_relevante up2
  ON up1.user_id = up2.user_id
 AND up1.product_id < up2.product_id
GROUP BY 1, 2
HAVING COUNT(*) >= 50;  -- coocorrência mínima


SELECT COUNT(*) AS qtd_pares
FROM tmp_pairs_half;


-- cálculo da probabilidade de compra
DROP TABLE IF EXISTS tmp_recomendacoes;

CREATE TEMP TABLE tmp_recomendacoes AS
WITH pares_direcionais AS (
    -- produto A → produto B
    SELECT
        produto_a AS produto_base,
        produto_b AS produto_recomendado,
        clientes_ab
    FROM tmp_pairs_half

    UNION ALL

    -- produto B -> produto A
    SELECT
        produto_b AS produto_base,
        produto_a AS produto_recomendado,
        clientes_ab
    FROM tmp_pairs_half
)
SELECT
    pd.produto_base,
    pd.produto_recomendado,
    pd.clientes_ab,
    pr.clientes AS clientes_base,
    ROUND(pd.clientes_ab::numeric / pr.clientes, 4) AS probabilidade_compra
FROM pares_direcionais pd
JOIN tmp_produtos_relevantes pr
  ON pr.product_id = pd.produto_base;

CREATE INDEX ON tmp_recomendacoes (produto_base);
ANALYZE tmp_recomendacoes;

-- checagem
SELECT *
FROM tmp_recomendacoes
ORDER BY probabilidade_compra DESC
LIMIT 10;



-- resultado final 
WITH ranked AS (
    SELECT
        r.*,
        ROW_NUMBER() OVER (
            PARTITION BY r.produto_base
            ORDER BY r.probabilidade_compra DESC, r.clientes_ab DESC
        ) AS ranking
    FROM tmp_recomendacoes r
)
SELECT
    pb.product_name AS produto_base,
    pr.product_name AS produto_recomendado,
    dpt.department AS departamento,
    r.probabilidade_compra
FROM ranked r
JOIN pao_de_mel.base_produtos pb
  ON pb.product_id = r.produto_base
JOIN pao_de_mel.base_produtos pr
  ON pr.product_id = r.produto_recomendado
JOIN pao_de_mel.base_departamentos dpt
  ON dpt.department_id = pr.department_id
WHERE r.ranking <= 3
ORDER BY r.probabilidade_compra DESC, produto_base
LIMIT 10; -- apenas para visualização

