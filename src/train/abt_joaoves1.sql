WITH tb_fl_churn AS (   
    SELECT 
        t1.dtRef,
        t1.idCustomer,
        CASE WHEN t2.idCustomer IS NULL THEN 1 ELSE 0 END AS flChurn    
    FROM fs_general AS t1
    LEFT JOIN fs_general AS t2
    ON t1.idCustomer = t2.idCustomer
    AND t1.dtRef = date(t2.dtRef, '-21 day') 

    WHERE t1.dtRef < DATE('2024-06-26', '-21 day') 
    AND strftime("%d", t1.dtRef) = '01'
)

SELECT 
    t1.*,
    t2.recenciaDias,
    t2.frequenciaDias,
    t2.valorPoints,
    t2.idadeBaseDias,
    t2.flEmail,
    t3.qtdPontosManha,
    t3.qtdPontosTarde,
    t3.qtdPontosNoite,
    t3.pctPontosManha,
    t3.pctPontosTarde,
    t3.pctPontosNoite,
    t3.qtdTransacoesManha,
    t3.qtdTransacoesTarde,
    t3.qtdTransacoesNoite,
    t3.pctTransacoesManha,
    t3.pctTransacoesTarde,
    t3.pctTransacoesNoite,
    t4.saldoPointsD21,
    t4.saldoPontosD14,
    t4.saldoPontosD7,
    t4.pontosAcumuladosD21,
    t4.pontosAcumuladosD14,
    t4.pontosAcumuladosD7,
    t4.pontosResgatadosD21,
    t4.pontosResgatadosD14,
    t4.pontosResgatadosD7 ,
    t4.saldoPontos,
    t4.pontosAcumuladosVida,
    t4.pontosResgatadosVida,
    t4.pontosPorDia,
    t5.qtdChatMessage,
    t5.qtdListaPresenca,
    t5.qtdResgatarPonei,
    t5.qtdTrocaPontos,
    t5.qtdPresencaStreak,
    t5.pontosChatMessage,
    t5.pontosListaPresenca,
    t5.pontosResgatarPonei,
    t5.pontosTrocaPontos,
    t5.pontosPresencaStreak,
    t5.pctChatMessage,
    t5.pctListaPresenca,
    t5.pctResgatarPonei,
    t5.pctTrocaPontos,
    t5.pctPresencaStreak,
    t5.avgChatLive,
    t5.NameProduct AS productMaxQtde,
    t6.qtdDiasD21,
    t6.qtdDiasD14,
    t6.qtdDiasD7,
    t6.avgLiveMinutes,
    t6.sumLiveMinutes,
    t6.minLiveMinutes,
    t6.maxLiveMinutes,
     t6.avgTransacaoPorDia


FROM tb_fl_churn AS t1

LEFT JOIN fs_general_joaoves1 AS t2
ON t1.idCustomer = t2.idCustomer
AND t1.dtRef = t2.dtRef

LEFT JOIN fs_horario_joaoves1 AS t3
ON t1.idCustomer = t3.idCustomer
AND t1.dtRef = t3.dtRef

LEFT JOIN fs_points_joaoves1 AS t4
ON t1.idCustomer = t4.idCustomer
AND t1.dtRef = t4.dtRef

LEFT JOIN fs_produtos_joaoves1 AS t5
ON t1.idCustomer = t5.idCustomer
AND t1.dtRef = t5.dtRef

LEFT JOIN fs_transacoes_joaoves1 AS t6
ON t1.idCustomer = t6.idCustomer
AND t1.dtRef = t6.dtRef