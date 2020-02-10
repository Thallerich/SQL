SELECT KdGf.KurzBez AS Marktsegment, Branche.Branche AS [SIC-Code], Holding.Holding AS Kette, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kunden.Land, Kunden.PLZ, Kunden.Ort, Kunden.Strasse, Bereich.Bereich, eProd.SuchCode AS [prod. BT], iProd.SuchCode AS [Intern prod. BT], Firma.SuchCode AS [Fakturierender BT], [Datum inaktiv] = 
  IIF(Kunden.Status = N'I', (
      SELECT CAST(MAX(History.Zeitpunkt) AS date)
      FROM History
      WHERE History.TableName = N'KUNDEN'
        AND History.TableID = Kunden.ID
        AND History.HistKatID = 10023
    ), NULL)
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Branche ON Kunden.BrancheID = Branche.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN VsaBer ON VsaBer.VsaID = Vsa.ID
JOIN KdBer ON VsaBer.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.Id
JOIN StandBer ON StandBer.StandKonID = Vsa.StandKonID AND StandBer.BereichID = Bereich.ID
JOIN Standort AS iProd ON StandBer.ProduktionID = iProd.ID
JOIN Standort AS eProd ON StandBer.ExpeditionID = eProd.ID
WHERE Kunden.AdrArtID = 1
  AND VsaBer.[Status] = N'A'
  AND KdBer.[Status] = N'A';