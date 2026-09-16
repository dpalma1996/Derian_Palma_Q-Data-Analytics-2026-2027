/*
SPRINT 04
NIVEL 3
*/

/*
EJERCICIO 1
*/

-- ### Generar una fila por elemento del array de productos de cada transacción.
CREATE OR REPLACE TABLE
    `sprint3-analytics-derian-palma.sprint3_gold.dim_transactions_flat` AS
SELECT
    t.transaction_id,
    t.timestamp,
    t.amount AS total_ticket,
    product_id AS product_sku,
    p.name AS product_name,
    p.price AS product_price
FROM `sprint3-analytics-derian-palma.sprint3_gold.fact_transactions_optimized` AS t
CROSS JOIN UNNEST(t.product_ids) AS product_id
JOIN `sprint3-analytics-derian-palma.sprint3_silver.products_clean` AS p
    ON product_id = p.product_id
WHERE t.declined = 0;

-- ### Comprobar el detalle; total_ticket se repite en las líneas de una transacción.
SELECT *
FROM `sprint3-analytics-derian-palma.sprint3_gold.dim_transactions_flat`
ORDER BY transaction_id, product_sku
LIMIT 30;


/*
EJERCICIO 2
*/

-- ### Contar las unidades por nombre de producto y mostrar los cinco primeros.
SELECT
    product_name,
    COUNT(*) AS unitats_venudes
FROM `sprint3-analytics-derian-palma.sprint3_gold.dim_transactions_flat`
GROUP BY product_name
ORDER BY unitats_venudes DESC, product_name ASC
LIMIT 5;


/*
EJERCICIO 3
*/

-- ### Aplicar un IVA del 21 % y redondear a dos decimales.
CREATE OR REPLACE FUNCTION
    `sprint3-analytics-derian-palma.sprint3_gold.calculate_tax`
    (amount FLOAT64)
RETURNS FLOAT64
AS (
    ROUND(amount * 1.21, 2)
);

-- ### Comprobar la función con los precios reales de los productos.
SELECT
    product_id,
    name AS product_name,
    price AS precio_sin_iva,
    `sprint3-analytics-derian-palma.sprint3_gold.calculate_tax`(price)
        AS precio_con_iva
FROM `sprint3-analytics-derian-palma.sprint3_silver.products_clean`
ORDER BY product_id;

-- ### Incorporar el precio con IVA a la tabla plana.
-- ### Esta consulta también se utilizó para preparar la actualización en Programa.
CREATE OR REPLACE TABLE
    `sprint3-analytics-derian-palma.sprint3_gold.dim_transactions_flat` AS
SELECT
    t.transaction_id,
    t.timestamp,
    t.amount AS total_ticket,
    product_id AS product_sku,
    p.name AS product_name,
    p.price AS product_price,
    `sprint3-analytics-derian-palma.sprint3_gold.calculate_tax`(p.price)
        AS product_price_tax_inc
FROM `sprint3-analytics-derian-palma.sprint3_silver.transactions_clean` AS t
CROSS JOIN UNNEST(t.product_ids) AS product_id
JOIN `sprint3-analytics-derian-palma.sprint3_silver.products_clean` AS p
    ON product_id = p.product_id
WHERE t.declined = 0;
