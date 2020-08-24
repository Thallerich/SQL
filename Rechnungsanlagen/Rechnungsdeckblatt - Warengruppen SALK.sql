SELECT RechKo.ID AS RechKoID, RechKo.KundenID AS KundenID, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, KdArti.Referenz AS WarengruppeSALK, SUM(RechPo.GPreis) AS Nettobetrag
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN Abteil ON RechPo.AbteilID = Abteil.ID
LEFT JOIN KdArti ON RechPo.KdArtiID = KdArti.ID
WHERE RechKo.ID = $RECHKOID$
GROUP BY RechKo.ID, RechKo.KundenID, Abteil.Abteilung, Abteil.Bez, KdArti.Referenz
ORDER BY WarengruppeSALK ASC, Kostenstelle ASC;