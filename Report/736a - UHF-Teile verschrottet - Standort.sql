DECLARE @startdatetime datetime2 = CAST($STARTDATE$ AS datetime2), @enddatetime datetime2 = CAST(DATEADD(day, 1, $ENDDATE$) AS datetime);

SELECT COALESCE(IIF(ZielNr.ProduktionsID = -1, NULL, ZStandort.Bez), MStandort.Bez) AS Produktionsstandort, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Artikel.EKPreis, WegGrund.WegGrundBez$LAN$ AS Schrottgrund, COUNT(EINZTEIL.ID) AS Menge, (SUM(EINZTEIL.RuecklaufG) / COUNT(EINZTEIL.ID)) AS [Durchschnitt Waschzyklen]
FROM Scans
JOIN ZielNr ON Scans.ZielNrID = ZielNr.ID
JOIN Standort AS ZStandort ON ZielNr.ProduktionsID = ZStandort.ID
JOIN Mitarbei ON Scans.AnlageUserID_ = Mitarbei.ID
JOIN Standort AS MStandort ON Mitarbei.StandortID = MStandort.ID
JOIN EinzTeil ON Scans.EinzTeilID = EinzTeil.ID
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
JOIN WegGrund ON EinzTeil.WegGrundID = WegGrund.ID
WHERE (Mitarbei.StandortID IN ($3$) OR ZielNr.ProduktionsID IN ($3$))
  AND EinzTeil.WegGrundID IN ($2$)
  AND Scans.[DateTime] >= @startdatetime
  AND Scans.[DateTime] < @enddatetime
  AND Scans.ActionsID = 108 /* Schrott */
GROUP BY COALESCE(IIF(ZielNr.ProduktionsID = -1, NULL, ZStandort.Bez), MStandort.Bez), Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, Artikel.EKPreis, WegGrund.WegGrundBez$LAN$;