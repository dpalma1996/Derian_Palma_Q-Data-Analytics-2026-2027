/*
NIVEL 3: PRESENTACIÓN DE DATOS Y CREACIÓN DE VISTAS
*/


/*
Exercici 1: La Vista de Màrqueting
*/

CREATE OR REPLACE VIEW
`sprint3-analytics-derian-palma.sprint3_gold.v_marketing_kpis` AS

SELECT
    c.company_name,
    c.phone,
    c.country,
    ROUND(AVG(t.amount), 2) AS avg_purchase,
    CASE
        WHEN AVG(t.amount) > 260 THEN 'Premium'
        ELSE 'Standard'
    END AS client_tier
FROM `sprint3-analytics-derian-palma.sprint3_silver.companies_clean` AS c
JOIN `sprint3-analytics-derian-palma.sprint3_silver.transactions_clean` AS t
    ON c.company_id = t.business_id
WHERE t.declined = 0
GROUP BY
    c.company_id,
    c.company_name,
    c.phone,
    c.country;


SELECT *
FROM `sprint3-analytics-derian-palma.sprint3_gold.v_marketing_kpis`
ORDER BY
    CASE
        WHEN client_tier = 'Premium' THEN 0
        ELSE 1
    END,
    avg_purchase DESC;

### Solo se consideran compras aceptadas
### company_id se incluye en GROUP BY para mantener cada empresa como entidad independiente



/*
Exercici 2: Rànquing de Productes
*/

CREATE OR REPLACE TABLE
`sprint3-analytics-derian-palma.sprint3_gold.product_sales_ranking` AS

WITH sales AS (
    SELECT
        product_id,
        COUNT(*) AS total_sold
    FROM `sprint3-analytics-derian-palma.sprint3_silver.transactions_clean` AS t,
    UNNEST(t.product_ids) AS product_id
    WHERE t.declined = 0
    GROUP BY product_id
)

SELECT
    p.product_id,
    p.name,
    ROUND(p.price, 2) AS price,
    p.color,
    IFNULL(s.total_sold, 0) AS total_sold
FROM `sprint3-analytics-derian-palma.sprint3_silver.products_clean` AS p
LEFT JOIN sales AS s
    ON p.product_id = s.product_id;


SELECT *
FROM `sprint3-analytics-derian-palma.sprint3_gold.product_sales_ranking`
ORDER BY total_sold DESC;

### UNNEST convierte cada ARRAY de product_ids en filas individuales
### LEFT JOIN conserva también los productos sin ventas
### declined = 0 evita contar como venta una transacción rechazada



/*
Exercici 3: Exportació de Resultats
*/

SELECT *
FROM `sprint3-analytics-derian-palma.sprint3_gold.product_sales_ranking`
ORDER BY total_sold DESC;

### Resultado exportado a CSV y abierto posteriormente en Excel