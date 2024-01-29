SELECT Firma.SuchCode AS Firma,
    KdGf.KurzBez AS Geschäftsbereich,
    [Zone].ZonenCode AS Vertriebszone,
    Standort.SuchCode + ISNULL(N' - (' + Standort.Bez + ')', N'') AS Produktion,
    WegGrund.WegGrundBez AS Schrottgrund,
    COUNT(EinzHist.ID) AS [Anzahl Teile]
  FROM TeilSoFa
  JOIN EinzHist ON TeilSoFa.EinzHistID = EinzHist.ID
  JOIN Vsa ON EinzHist.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN Firma ON Kunden.FirmaID = Firma.ID
  JOIN KdGf ON Kunden.KdGfID = KdGf.ID
  JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
  JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
  JOIN Standort ON StandBer.ProduktionID = Standort.ID
  JOIN WegGrund ON EinzHist.WegGrundID = WegGrund.ID
  WHERE TeilSoFa.Zeitpunkt BETWEEN N'2023-01-01' AND GETDATE()
    AND Firma.ID NOT IN (SELECT Firma.ID FROM Firma WHERE Firma.SuchCode IN (N'FA14', N'WOMI'))
    AND TeilSoFa.SoFaArt = N'R'
    AND (EinzHist.Status = N'Y' OR (EinzHist.Status = N'S' AND EinzHist.WegGrundID > 0))
GROUP BY Firma.SuchCode, KdGf.KurzBez, [Zone].ZonenCode, Standort.SuchCode + ISNULL(N' - (' + Standort.Bez + ')', N''), WegGrund.WeggrundBez