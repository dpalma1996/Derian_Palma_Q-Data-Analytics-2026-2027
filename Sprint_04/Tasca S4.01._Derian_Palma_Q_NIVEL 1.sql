/*
SPRINT 04
NIVEL 1
*/

/*
EJERCICIO 1
*/

-- ### Consulta utilizada para revisar la estimación de bytes procesados.
SELECT
    t.transaction_id,
    t.timestamp,
    t.amount,
    c.company_name,
    c.country
FROM `sprint3-analytics-derian-palma.sprint3_silver.transactions_clean` AS t
JOIN `sprint3-analytics-derian-palma.sprint3_silver.companies_clean` AS c
    ON t.business_id = c.company_id
WHERE DATE(t.timestamp) = DATE '2022-03-12'
    AND c.country = 'Germany';


/*
EJERCICIO 2
*/

-- ### Crear una copia con fechas aleatorias entre hoy y hace 49 días.
CREATE OR REPLACE TABLE
    `sprint3-analytics-derian-palma.sprint3_silver.transactions_recent` AS
SELECT
    * EXCEPT(timestamp),
    TIMESTAMP_SUB(
        CURRENT_TIMESTAMP(),
        INTERVAL CAST(FLOOR(RAND() * 50) AS INT64) DAY
    ) AS timestamp
FROM `sprint3-analytics-derian-palma.sprint3_silver.transactions_clean`;

-- ### Particionar por día y aplicar clustering por empresa.
CREATE OR REPLACE TABLE
    `sprint3-analytics-derian-palma.sprint3_gold.fact_transactions_optimized`
PARTITION BY DATE(timestamp)
CLUSTER BY business_id
AS-- ### Crear la tabla Gold conservando los datos y las fechas originales.
CREATE OR REPLACE TABLE
  `sprint3-analytics-derian-palma.sprint3_gold.fact_transactions_optimized`
PARTITION BY DATE(timestamp)
CLUSTER BY business_id
AS
SELECT *
FROM `sprint3-analytics-derian-palma.sprint3_silver.transactions_clean`;


-- ### Eliminar la caducidad de las particiones para conservar el histórico.
ALTER TABLE
  `sprint3-analytics-derian-palma.sprint3_gold.fact_transactions_optimized`
SET OPTIONS (
  partition_expiration_days = NULL
);


/*
EJERCICIO 3
*/

-- ### Consultar los últimos 30 días en la tabla sin particionar.
SELECT *
FROM `sprint3-analytics-derian-palma.sprint3_silver.transactions_recent`
WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY);

-- ### Aplicar el mismo filtro en la tabla optimizada.
SELECT *
FROM `sprint3-analytics-derian-palma.sprint3_gold.fact_transactions_optimized`
WHERE timestamp >= TIMESTAMP_SUB(CURRENT_TIMESTAMP(), INTERVAL 30 DAY);


/*
EJERCICIO 4
*/

-- ### IF NOT EXISTS permite repetir el bloque si la vista ya existe.
CREATE MATERIALIZED VIEW IF NOT EXISTS
    `sprint3-analytics-derian-palma.sprint3_gold.mv_daily_sales`
AS
SELECT
    DATE(timestamp) AS fecha,
    SUM(amount) AS ventas_totales
FROM `sprint3-analytics-derian-palma.sprint3_gold.fact_transactions_optimized`
WHERE declined = 0
GROUP BY fecha;

-- ### Comprobar las ventas diarias y los bytes procesados.
SELECT
    fecha,
    ventas_totales
FROM `sprint3-analytics-derian-palma.sprint3_gold.mv_daily_sales`
ORDER BY fecha;