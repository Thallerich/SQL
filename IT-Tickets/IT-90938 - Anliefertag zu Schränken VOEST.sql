SELECT Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], Schrank.SchrankNr, Schrank.FachVon AS [von Fach], Schrank.FachBis AS [bis Fach],
  Anliefertage = STUFF((
    SELECT N', ' + CASE Touren.Wochentag
      WHEN 1 THEN N'Montag'
      WHEN 2 THEN N'Dienstag'
      WHEN 3 THEN N'Mittwoch'
      WHEN 4 THEN N'Donnerstag'
      WHEN 5 THEN N'Freitag'
      WHEN 6 THEN N'Samstag'
      WHEN 7 THEN N'Sonntag'
      ELSE N'(unbekannt)'
    END
    FROM VsaTour
    JOIN KdBer ON VsaTour.KdBerID = KdBer.ID
    JOIN Touren ON VsaTour.TourenID = Touren.ID
    WHERE VsaTour.VsaID = Vsa.ID
      AND CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
      AND KdBer.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = N'BK')
    FOR XML PATH('')
  ), 1, 2, N'')
FROM Schrank
JOIN Vsa ON Schrank.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
WHERE Holding.Holding IN (N'VOES', N'VOESAN', N'VOESLE')