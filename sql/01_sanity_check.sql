-- SANITY CHECK 

-- volume de dados das bases

SELECT 
	'base_compras' as tabela, 
	COUNT(*) as qtd_registros
FROM pao_de_mel.base_compras
UNION ALL
SELECT 
	'base_produtos', 
	COUNT(*)
FROM pao_de_mel.base_produtos
UNION ALL
SELECT 
	'base_departamentos', 
	COUNT(*)
FROM pao_de_mel.base_departamentos
UNION ALL
SELECT 
	'base_tipo_de_produto', 
	COUNT(*)
FROM pao_de_mel.base_tipo_de_produto;


-- 2. verificação de chaves primárias e duplicidade (product_id, department_id e aisle_id)

SELECT
    COUNT(*) AS total_linhas,
    COUNT(DISTINCT product_id) as produtos_distintos
FROM pao_de_mel.base_produtos;


SELECT
    COUNT(*) AS total_linhas,
    COUNT(DISTINCT department_id) as departamentos_distintos
FROM pao_de_mel.base_departamentos;


SELECT
    COUNT(*) AS total_linhas,
    COUNT(DISTINCT aisle_id) as aisles_distintos
FROM pao_de_mel.base_tipo_de_produto;


-- 3. veficação de valores nulos

SELECT
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) as product_id_nulo,
    SUM(CASE WHEN user_id IS NULL THEN 1 ELSE 0 END) as user_id_nulo,
    SUM(CASE WHEN order_dow IS NULL THEN 1 ELSE 0 END) as order_dow_nulo,
    SUM(CASE WHEN order_hour_of_day IS NULL THEN 1 ELSE 0 END) as hour_nulo
FROM pao_de_mel.base_compras;

SELECT
    SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) as product_name_nulo,
    SUM(CASE WHEN department_id IS NULL THEN 1 ELSE 0 END) as department_id_nulo,
    SUM(CASE WHEN aisle_id IS NULL THEN 1 ELSE 0 END) as aisle_id_nulo
FROM pao_de_mel.base_produtos;


-- 4. verificação de referências

-- compras em que o produto não está cadastrado
SELECT 
	COUNT(*) as compras_sem_produto
FROM pao_de_mel.base_compras bc
LEFT JOIN pao_de_mel.base_produtos bp
  ON bp.product_id = bc.product_id
WHERE bp.product_id IS NULL;

-- produtos sem cadastro em departamento
SELECT 
	COUNT(*) as produtos_sem_departamento
FROM pao_de_mel.base_produtos bp
LEFT JOIN pao_de_mel.base_departamentos dpt
  ON dpt.department_id = bp.department_id
WHERE dpt.department_id IS NULL;

-- produtos sem cadastro em "aisle"
SELECT COUNT(*) as produtos_sem_aisle
FROM pao_de_mel.base_produtos bp
LEFT JOIN pao_de_mel.base_tipo_de_produto a
  ON a.aisle_id = bp.aisle_id
WHERE a.aisle_id IS NULL;


-- 5. verificação de intervalos de valores

-- order_dow (0 a 6)
SELECT
    MIN(order_dow) AS min_dow,
    MAX(order_dow) AS max_dow
FROM pao_de_mel.base_compras;

-- order_hour_of_day (0 a 23)
SELECT
    MIN(order_hour_of_day) AS min_hour,
    MAX(order_hour_of_day) AS max_hour
FROM pao_de_mel.base_compras;


-- 6. verificação de outliers

SELECT
    user_id,
    COUNT(*) AS total_itens_comprados
FROM pao_de_mel.base_compras
GROUP BY 1
ORDER BY 2 DESC
LIMIT 10;


-- 7. verificação de duplicidade
SELECT
    user_id, product_id, order_dow, order_hour_of_day,
    COUNT(*) AS qtd
FROM pao_de_mel.base_compras
GROUP BY 1, 2, 3, 4
HAVING COUNT(*) > 1
ORDER BY qtd DESC;

/* esta verificação indicou que há algumas duplicidades na base, contudo não representa um erro,
afinal é factível que alguns usuários comprem mais de um produto num determinado horário e dia
da semana. */
