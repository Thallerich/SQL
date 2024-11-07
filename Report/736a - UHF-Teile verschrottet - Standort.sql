DECLARE @startdatetime datetime2 = CAST($STARTDATE$ AS datetime2), @enddatetime datetime2 = CAST(DATEADD(day, 1, $ENDDATE$) AS datetime);

SELECT Standort.Bez AS Produktionsstandort, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Artikel.EKPreis, WegGrund.WegGrundBez$LAN$ AS Schrottgrund, COUNT(EINZTEIL.ID) AS Menge, (SUM(EINZTEIL.RuecklaufG) / COUNT(EINZTEIL.ID)) AS [Durchschnitt Waschzyklen]
FROM Scans
JOIN EinzTeil ON Scans.EinzTeilID = EinzTeil.ID
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
JOIN WegGrund ON EinzTeil.WegGrundID = WegGrund.ID
JOIN Mitarbei ON Scans.AnlageUserID_ = Mitarbei.ID
JOIN Standort ON Mitarbei.StandortID = Standort.ID
WHERE Mitarbei.StandortID IN ($3$)
  AND EinzTeil.WegGrundID IN ($2$)
  AND Scans.[DateTime] >= @startdatetime
  AND Scans.[DateTime] < @enddatetime
  AND Scans.ActionsID = 108 /* Schrott */
GROUP BY Standort.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, Artikel.EKPreis, WegGrund.WegGrundBez$LAN$;