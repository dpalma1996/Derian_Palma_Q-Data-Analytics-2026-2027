/*
NIVEL 1: ENTORNO E INGESTA HÍBRIDA
*/


/*
Exercici 1: Arquitectura de Dades
*/

CREATE SCHEMA IF NOT EXISTS
`sprint3-analytics-derian-palma.sprint3_silver`
OPTIONS (
    location = 'EU'
);

### sprint3_bronze se creó mediante UI
### sprint3_gold se creó mediante Cloud Shell:
### bq mk --dataset --location=EU sprint3-analytics-derian-palma:sprint3_gold



/*
Exercici 2: Ingesta en Capa Bronze
*/

CREATE EXTERNAL TABLE IF NOT EXISTS
`sprint3-analytics-derian-palma.sprint3_bronze.transactions_raw`
OPTIONS (
    format = 'CSV',
    uris = ['gs://bootcamp-data-analytics-public/ERP/transactions.csv'],
    field_delimiter = ';'
);

CREATE EXTERNAL TABLE IF NOT EXISTS
`sprint3-analytics-derian-palma.sprint3_bronze.companies_raw`
(
    company_id STRING,
    company_name STRING,
    phone STRING,
    email STRING,
    country STRING,
    website STRING
)
OPTIONS (
    format = 'CSV',
    uris = ['gs://bootcamp-data-analytics-public/ERP/companies.csv'],
    skip_leading_rows = 1
);

CREATE EXTERNAL TABLE IF NOT EXISTS
`sprint3-analytics-derian-palma.sprint3_bronze.american_users_raw`
OPTIONS (
    format = 'CSV',
    uris = ['gs://bootcamp-data-analytics-public/CRM/american_users.csv']
);

CREATE EXTERNAL TABLE IF NOT EXISTS
`sprint3-analytics-derian-palma.sprint3_bronze.european_users_raw`
OPTIONS (
    format = 'CSV',
    uris = ['gs://bootcamp-data-analytics-public/CRM/european_users.csv']
);

CREATE EXTERNAL TABLE IF NOT EXISTS
`sprint3-analytics-derian-palma.sprint3_bronze.credit_cards_raw`
OPTIONS (
    format = 'CSV',
    uris = ['gs://bootcamp-data-analytics-public/CRM/credit_cards.csv']
);

### companies.csv requirió esquema manual y omitir la fila de cabecera



/*
Exercici 3: Càrrega de Dades Locals
*/

### products.csv se cargó manualmente mediante Upload como products_raw



/*
Exercici 4: Arquitectura i Rendiment
*/

CREATE OR REPLACE TABLE
`sprint3-analytics-derian-palma.sprint3_bronze.transactions_raw_native` AS

SELECT *
FROM `sprint3-analytics-derian-palma.sprint3_bronze.transactions_raw`;


/* Comparación de costes */

SELECT id
FROM `sprint3-analytics-derian-palma.sprint3_bronze.transactions_raw`;

SELECT id
FROM `sprint3-analytics-derian-palma.sprint3_bronze.transactions_raw_native`;

### Externa: 12.61 MB procesados / 13 MB facturados
### Nativa: 3.62 MB procesados / 10 MB facturados
### Para consultas repetidas conviene continuar trabajando con la tabla nativa


/* Prueba con LIMIT */

SELECT id
FROM `sprint3-analytics-derian-palma.sprint3_bronze.transactions_raw`
LIMIT 10;

SELECT id
FROM `sprint3-analytics-derian-palma.sprint3_bronze.transactions_raw_native`
LIMIT 10;

### En la nativa LIMIT no reduce los bytes leídos
### En la externa el comportamiento observado fue diferente por tratarse de un CSV



/*
Exercici 5: Adaptació de Sintaxi
*/

SELECT
    DATE(timestamp) AS transaction_date,
    ROUND(SUM(amount), 2) AS total_income
FROM `sprint3-analytics-derian-palma.sprint3_bronze.transactions_raw_native`
WHERE EXTRACT(YEAR FROM timestamp) = 2021
GROUP BY transaction_date
ORDER BY total_income DESC
LIMIT 5;

### timestamp ya era TIMESTAMP, por lo que no fue necesario CAST, PARSE_TIMESTAMP ni SUBSTR
### No se filtra declined porque el ejercicio solicita las transacciones registradas en 2021



/*
Exercici 6: Consultes Complexes
*/

SELECT
    c.company_name,
    c.country,
    DATE(t.timestamp) AS transaction_date
FROM `sprint3-analytics-derian-palma.sprint3_bronze.transactions_raw_native` AS t
JOIN `sprint3-analytics-derian-palma.sprint3_bronze.companies_raw` AS c
    ON t.business_id = c.company_id
WHERE t.amount BETWEEN 100 AND 200
AND DATE(t.timestamp) IN (
    DATE '2015-04-29',
    DATE '2018-07-20',
    DATE '2024-03-13'
);

### Aquí tampoco se filtra declined porque el enunciado pide operaciones/transacciones