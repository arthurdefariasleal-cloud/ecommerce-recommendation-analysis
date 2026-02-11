-- ANÁLISE EXPLORATÓRIA DOS DADOS

-- união das tabelas
SELECT
    bc.user_id, bc.product_id, bp.product_name, dpt.department, a.aisle, bc.order_dow, bc.order_hour_of_day
FROM pao_de_mel.base_compras as bc
JOIN pao_de_mel.base_produtos bp
  ON bp.product_id = bc.product_id
JOIN pao_de_mel.base_departamentos as dpt
  ON dpt.department_id = bp.department_id
JOIN pao_de_mel.base_tipo_de_produto as a
  ON a.aisle_id = bp.aisle_id;


-- distribuição de vendas

-- i. por departamento
SELECT
    dpt.department,
    COUNT(*) AS total_itens_vendidos
FROM pao_de_mel.base_compras bc
JOIN pao_de_mel.base_produtos bp
  ON bp.product_id = bc.product_id
JOIN pao_de_mel.base_departamentos dpt
  ON dpt.department_id = bp.department_id
GROUP BY 1
ORDER BY 2 DESC;

-- ii. por dia da semana
SELECT
    bc.order_dow,
    CASE bc.order_dow
        WHEN 0 THEN 'Domingo'
        WHEN 1 THEN 'Segunda'
        WHEN 2 THEN 'Terça'
        WHEN 3 THEN 'Quarta'
        WHEN 4 THEN 'Quinta'
        WHEN 5 THEN 'Sexta'
        WHEN 6 THEN 'Sábado'
    END as dia_semana,
    COUNT(*) as total_itens_vendidos
FROM pao_de_mel.base_compras bc
GROUP BY 1
ORDER BY 1;

-- iii. por hora do dia
SELECT
    bc.order_hour_of_day as hora,
    COUNT(*) AS total_itens_vendidos
FROM pao_de_mel.base_compras bc
GROUP BY 1
ORDER BY 1;


-- TOP 5 produtos mais vendidos por departamento (frequência relativa e acumulada)

WITH vendas_produto as(
    SELECT
        dpt.department, bp.product_id, bp.product_name,
        COUNT(*) AS total_vendas
    FROM pao_de_mel.base_compras bc
    JOIN pao_de_mel.base_produtos bp
      ON bp.product_id = bc.product_id
    JOIN pao_de_mel.base_departamentos dpt
      ON dpt.department_id = bp.department_id
    GROUP BY 1, 2, 3),
frequencias as(
    SELECT
        department, product_id, product_name, total_vendas,
		
        -- freq. relativa
        ROUND(
            total_vendas::numeric / SUM(total_vendas) OVER (PARTITION BY department), 3
        ) as freq_relativa,

        -- freq. acumulada
        ROUND(
            SUM(total_vendas) OVER (
                PARTITION BY department
                ORDER BY total_vendas DESC, product_id
                ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
            )::numeric / SUM(total_vendas) OVER (PARTITION BY department), 3
        ) as freq_acumulada,

        -- ranking do produto
        DENSE_RANK() OVER (
            PARTITION BY department
            ORDER BY total_vendas DESC, product_id
        ) as ranking
    FROM vendas_produto
)
SELECT
    department, product_id, product_name, total_vendas, freq_relativa, freq_acumulada
FROM frequencias
WHERE ranking <= 5
ORDER BY department, total_vendas DESC;


-- Existe alguma concentração de tipo de produto por hora do dia em que é vendido? 

WITH vendas_hour_aisle as(
    SELECT
        bc.order_hour_of_day as hora, 
		a.aisle,
        COUNT(*) as total_vendas
    FROM pao_de_mel.base_compras bc
    JOIN pao_de_mel.base_produtos bp
        ON bp.product_id = bc.product_id
    JOIN pao_de_mel.base_tipo_de_produto a
        ON a.aisle_id = bp.aisle_id
    GROUP BY bc.order_hour_of_day, a.aisle
),
participacao as(
    SELECT 
		hora, aisle, total_vendas,
        total_vendas::numeric / SUM(total_vendas) OVER (PARTITION BY hora) as participacao_por_hora,
        DENSE_RANK() OVER (
            PARTITION BY hora
            ORDER BY total_vendas DESC
        ) as top3
    FROM vendas_hour_aisle
)
SELECT
    hora, aisle, total_vendas,
    ROUND(participacao_por_hora, 3) as participacao_por_hora
FROM participacao
WHERE top3 <= 3
ORDER BY hora, top3;

