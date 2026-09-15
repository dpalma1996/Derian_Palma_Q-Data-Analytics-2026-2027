/*
SPRINT 04
NIVEL 2
*/

/*
EJERCICIO 1
*/

-- ### Resumir las compras aceptadas de usuarios con gasto superior a 500.
WITH VIP_Stats AS (
    SELECT
        user_id,
        COUNT(*) AS num_compres,
        ROUND(AVG(amount), 2) AS tiquet_mig,
        ROUND(MAX(amount), 2) AS max_compra,
        ROUND(SUM(amount), 2) AS total_gastat
    FROM `sprint3-analytics-derian-palma.sprint3_silver.transactions_clean`
    WHERE declined = 0
    GROUP BY user_id
    HAVING SUM(amount) > 500
)
SELECT
    v.user_id,
    CONCAT(u.name, ' ', u.surname) AS nom_complet,
    u.email,
    v.num_compres,
    v.tiquet_mig,
    v.max_compra,
    v.total_gastat
FROM VIP_Stats AS v
JOIN `sprint3-analytics-derian-palma.sprint3_silver.users_combined` AS u
    ON v.user_id = u.user_id
ORDER BY v.total_gastat DESC;


/*
EJERCICIO 2
*/

-- ### Recuperar las ventas del día anterior y calcular la variación porcentual.
WITH Comparativa_Diaria AS (
    SELECT
        fecha,
        ventas_totales AS Vendes_Avui,
        LAG(ventas_totales) OVER (ORDER BY fecha) AS Vendes_Ahir
    FROM `sprint3-analytics-derian-palma.sprint3_gold.mv_daily_sales`
)
SELECT
    fecha AS Data,
    ROUND(Vendes_Avui, 2) AS Vendes_Avui,
    ROUND(Vendes_Ahir, 2) AS Vendes_Ahir,
    ROUND(
        SAFE_DIVIDE(
            Vendes_Avui - Vendes_Ahir,
            Vendes_Ahir
        ) * 100,
        2
    ) AS Diff_Percentual
FROM Comparativa_Diaria
ORDER BY Data;


/*
EJERCICIO 3
*/

-- ### Acumular las ventas disponibles hasta cada fecha, reiniciando por año.
SELECT
    fecha AS Data,
    ROUND(ventas_totales, 2) AS Vendes_Dia,
    ROUND(
        SUM(ventas_totales) OVER (
            PARTITION BY EXTRACT(YEAR FROM fecha)
            ORDER BY fecha
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ),
        2
    ) AS Vendes_Acumulades_YTD
FROM `sprint3-analytics-derian-palma.sprint3_gold.mv_daily_sales`
ORDER BY Data;


/*
EJERCICIO 4
*/

-- ### Numerar las compras aceptadas y conservar las tres primeras por usuario.
WITH Primeres_Compres AS (
    SELECT
        user_id,
        timestamp,
        amount,
        ROW_NUMBER() OVER (
            PARTITION BY user_id
            ORDER BY timestamp, transaction_id
        ) AS ordre_compra
    FROM `sprint3-analytics-derian-palma.sprint3_silver.transactions_clean`
    WHERE declined = 0
    QUALIFY ordre_compra <= 3
),
Resum_Compres AS (
    SELECT
        user_id,
        MAX(IF(ordre_compra = 3, timestamp, NULL)) AS data_tercera_compra,
        MAX(IF(ordre_compra = 3, amount, NULL)) AS import_tercera_compra,
        ROUND(AVG(amount), 2) AS mitjana_3_primeres
    FROM Primeres_Compres
    GROUP BY user_id
    HAVING COUNT(*) = 3
)
SELECT
    r.user_id,
    CONCAT(u.name, ' ', u.surname) AS nom_complet,
    u.email,
    r.data_tercera_compra,
    r.import_tercera_compra,
    r.mitjana_3_primeres
FROM Resum_Compres AS r
JOIN `sprint3-analytics-derian-palma.sprint3_silver.users_combined` AS u
    ON r.user_id = u.user_id
ORDER BY r.user_id;