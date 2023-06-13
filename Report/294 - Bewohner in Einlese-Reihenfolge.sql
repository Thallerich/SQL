SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], Traeger.Traeger, Traeger.Vorname, Traeger.Nachname, MIN(Scans.[DateTime]) AS [Zeitpunkt Einlese-Scan], Lot.LotNr, Mitarbei.Name AS [eingelesen von]
FROM Scans
JOIN EinzHist ON Scans.EinzHistID = EinzHist.ID
JOIN EinzTeil ON EinzHist.EinzTeilID = EinzTeil.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
JOIN Lot ON Scans.LotID = Lot.ID
JOIN Mitarbei ON Lot.EinleseMitarbeiID = Mitarbei.ID
WHERE Scans.[DateTime] BETWEEN $1$ AND DATEADD(day, 1, $1$)
  AND Scans.ZielNrID = 1
  AND Scans.Menge = 1
  AND EinzTeil.AltenheimModus = 1
  AND StandBer.ProduktionID = $2$
GROUP BY Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez, Traeger.Traeger, Traeger.Vorname, Traeger.Nachname, Lot.LotNr, Mitarbei.Name
ORDER BY [Zeitpunkt Einlese-Scan] ASC;