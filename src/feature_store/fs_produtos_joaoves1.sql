WITH tb_transaction_products AS (
    SELECT 
        t1.*,
        NameProduct,
        QuantityProduct
    FROM transactions AS t1
    
    LEFT JOIN transactions_product AS t2
    ON t1.idTransaction = t2.idTransaction

    WHERE t1.dtTransaction < '{date}'
    AND t1.dtTransaction >= DATE('{date}', '-21 day')
),

tb_share AS (

    SELECT 
        idCustomer,
        SUM(CASE WHEN NameProduct = 'ChatMessage' 
                    THEN QuantityProduct 
                ELSE 0 
            END) AS qtdChatMessage,
        SUM(CASE WHEN NameProduct = 'Lista de presença'
                    THEN QuantityProduct 
                ELSE 0 
            END) AS qtdListaPresenca,
        SUM(CASE WHEN NameProduct = 'Resgatar Ponei' 
                    THEN QuantityProduct 
                ELSE 0 
            END) AS qtdResgatarPonei,
        SUM(CASE WHEN NameProduct = 'Troca de Pontos StreamElements' 
                    THEN QuantityProduct 
                ELSE 0 
            END) AS qtdTrocaPontos,
        SUM(CASE WHEN NameProduct = 'Presença Streak' 
                    THEN QuantityProduct 
                ELSE 0 
            END) AS qtdPresencaStreak,   

        SUM(CASE WHEN NameProduct = "ChatMessage" THEN pointsTransaction ELSE 0 END) AS pontosChatMessage,
        SUM(CASE WHEN NameProduct = "Lista de presença" THEN pointsTransaction ELSE 0 END) AS pontosListaPresenca,
        SUM(CASE WHEN NameProduct = "Resgatar Ponei" THEN pointsTransaction ELSE 0 END) AS pontosResgatarPonei,
        SUM(CASE WHEN NameProduct = "Troca de Pontos StreamElements" THEN pointsTransaction ELSE 0 END) AS pontosTrocaPontos,
        SUM(CASE WHEN NameProduct = "Presença Streak" THEN pointsTransaction ELSE 0 END) AS pontosPresencaStreak,

        1.0 * SUM(CASE WHEN NameProduct = 'ChatMessage' 
                    THEN QuantityProduct 
                ELSE 0 
            END) / SUM(QuantityProduct) AS pctChatMessage,
        1.0 * SUM(CASE WHEN NameProduct = 'Lista de presença'
                    THEN QuantityProduct 
                ELSE 0 
            END) / SUM(QuantityProduct) AS pctListaPresenca,
        1.0 * SUM(CASE WHEN NameProduct = 'Resgatar Ponei' 
                    THEN QuantityProduct 
                ELSE 0 
            END) / SUM(QuantityProduct) AS pctResgatarPonei,
        1.0 * SUM(CASE WHEN NameProduct = 'Troca de Pontos StreamElements' 
                    THEN QuantityProduct 
                ELSE 0 
            END) / SUM(QuantityProduct) AS pctTrocaPontos,
        1.0 * SUM(CASE WHEN NameProduct = 'Presença Streak' 
                    THEN QuantityProduct 
                ELSE 0 
            END) / SUM(QuantityProduct) AS pctPresencaStreak,

        1.0 * SUM(CASE WHEN NameProduct = 'ChatMessage' 
        THEN QuantityProduct ELSE 0 END)/COUNT(DISTINCT DATE(dtTransaction)) AS avgChatLive


    FROM tb_transaction_products

    GROUP BY idCustomer
),

tb_group AS (

    SELECT 
        idCustomer,
        NameProduct,
        SUM(QuantityProduct) AS qtd,
        SUM(pointsTransaction) AS pontos
    FROM tb_transaction_products
    GROUP BY idCustomer, NameProduct
),

tb_rn AS (

    SELECT 
        *,
        ROW_NUMBER() OVER (PARTITION BY idCustomer ORDER BY qtd DESC, pontos DESC) AS rnQtd
        --faz uma "lista" de 1, 2, 3... para cada usuário ordenando qtd e pontos
    FROM tb_group 
),

tb_produto_max AS (
    SELECT
        * 
    FROM tb_rn 
    WHERE rnQtd = 1
)

SELECT
    '{date}' AS dtRef,
    t1.*,
    t2.NameProduct
FROM tb_share AS t1
LEFT JOIN tb_produto_max AS t2
ON t1.idCustomer = t2.idCustomer 