/*
NIVEL 2: LIMPIEZA Y TRANSFORMACIÓN
*/


/*
Exercici 1: Neteja de Productes
*/

CREATE OR REPLACE TABLE
`sprint3-analytics-derian-palma.sprint3_silver.products_clean` AS

SELECT
    id AS product_id,
    product_name AS name,
    SAFE_CAST(REPLACE(warehouse_id, 'WH-', '') AS INT64) AS warehouse_id,
    SAFE_CAST(price AS FLOAT64) AS price,
    colour AS color,
    weight
FROM `sprint3-analytics-derian-palma.sprint3_bronze.products_raw`;

### REPLACE elimina explícitamente el prefijo WH-
### SUBSTR(warehouse_id, 4) también habría sido posible



/*
Exercici 2: Creació de Transaccions Netes
*/

CREATE OR REPLACE TABLE
`sprint3-analytics-derian-palma.sprint3_silver.transactions_clean` AS

SELECT
    id AS transaction_id,
    card_id,
    business_id,
    timestamp,
    IFNULL(SAFE_CAST(amount AS FLOAT64), 0) AS amount,
    declined,
    ARRAY(
        SELECT SAFE_CAST(TRIM(product_id) AS INT64)
        FROM UNNEST(SPLIT(product_ids, ',')) AS product_id
    ) AS product_ids,
    user_id,
    SAFE_CAST(lat AS FLOAT64) AS lat,
    SAFE_CAST(longitude AS FLOAT64) AS longitude
FROM `sprint3-analytics-derian-palma.sprint3_bronze.transactions_raw_native`;

### Se parte de la tabla nativa creada en el Nivel 1
### declined se conserva para decidir posteriormente qué métricas requieren ventas aceptadas



/*
Exercici 3: Unificació d'Usuaris
*/

CREATE OR REPLACE TABLE
`sprint3-analytics-derian-palma.sprint3_silver.users_combined` AS

SELECT
    id AS user_id,
    * EXCEPT(id),
    'US' AS origin
FROM `sprint3-analytics-derian-palma.sprint3_bronze.american_users_raw`

UNION ALL

SELECT
    id AS user_id,
    * EXCEPT(id),
    'EU' AS origin
FROM `sprint3-analytics-derian-palma.sprint3_bronze.european_users_raw`;

### UNION ALL mantiene todos los usuarios y origin identifica su procedencia



/*
Exercici 4: Materialització de Companyies i Targetes de Crèdit
*/

CREATE OR REPLACE TABLE
`sprint3-analytics-derian-palma.sprint3_silver.companies_clean` AS

SELECT *
FROM `sprint3-analytics-derian-palma.sprint3_bronze.companies_raw`;


CREATE OR REPLACE TABLE
`sprint3-analytics-derian-palma.sprint3_silver.credit_cards_clean` AS

SELECT
    id AS card_id,
    * EXCEPT(id)
FROM `sprint3-analytics-derian-palma.sprint3_bronze.credit_cards_raw`;

### Las tablas externas quedan materializadas como tablas nativas en Silver