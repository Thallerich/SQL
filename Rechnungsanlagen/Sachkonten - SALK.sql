SELECT RechPo.RechKoID, KdArti.Referenz, SUM(RechPo.GPreis) AS Summe
FROM RechPo
JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
WHERE RechPo.RechKoID = $RECHKOID$
GROUP BY RechPo.RechKoID, KdArti.Referenz
ORDER BY Referenz ASC;