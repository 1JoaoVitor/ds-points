WITH tb_transactions AS (

        SELECT *
        FROM transactions 
        WHERE dtTransaction < '{date}'
        AND dtTransaction >= DATE('{date}', '-21 day')
),

tb_freq AS (

    SELECT 
        idCustomer,
        COUNT(DISTINCT DATE(dtTransaction)) AS qtdDiasD21,
        COUNT(DISTINCT CASE WHEN dtTransaction > DATE('{date}', '-14 day') THEN DATE(dtTransaction) END) AS qtdDiasD14,
        COUNT(DISTINCT CASE WHEN dtTransaction > DATE('{date}', '-7 day') THEN DATE(dtTransaction) END) AS qtdDiasD7

    FROM tb_transactions

    GROUP BY idCustomer
),

tb_liveMinutes AS (

    SELECT 
        idCustomer,
        DATE(DATETIME(dtTransaction, '-3 hour')) AS dtTransactionDate,
        MIN(DATETIME(dtTransaction, '-3 hour')) AS dtInicio,
        MAX(DATETIME(dtTransaction, '-3 hour')) AS dtFim,
        (julianday(max(datetime(dtTransaction, '-3 hour'))) -
        julianday(min(datetime(dtTransaction, '-3 hour')))) * 24 * 60 AS liveMinutes
        
    FROM tb_transactions

    GROUP BY 1,2 
),

tb_hours AS (

    SELECT idCustomer,
        AVG(liveMinutes) AS avgLiveMinutes,
        SUM(liveMinutes) AS sumLiveMinutes,
        MIN(liveMinutes) AS minLiveMinutes,
        MAX(liveMinutes) AS maxLiveMinutes

    FROM tb_liveMinutes

    GROUP BY idCustomer
),

tb_vida AS (

    SELECT 
        idCustomer,
        COUNT(DISTINCT idTransaction) AS qtdTransacaoVida,
        COUNT(DISTINCT idTransaction)/ (MAX(julianday('{date}') - julianday(dtTransaction))) AS avgTransacaoPorDia
    FROM transactions
    WHERE dtTransaction < '{date}'
    GROUP BY idCustomer
),

tb_join AS (

SELECT
        t1.*,
        t2.avgLiveMinutes,
        t2.sumLiveMinutes,
        t2.minLiveMinutes,
        t2.maxLiveMinutes,
        t3.avgTransacaoPorDia
    FROM tb_freq AS t1
    LEFT JOIN tb_hours AS t2
    ON t1.idCustomer = t2.idCustomer
    LEFT JOIN tb_vida AS t3
    ON t3.idCustomer = t1.idCustomer
)

SELECT 
    '{date}' AS dtRef,
    *
FROM tb_join