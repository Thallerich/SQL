USE Wozabal;
GO

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS Vsa, Bereich.Bereich, Bereich.BereichBez AS Produktbereich, Wochentag = (
  CASE Touren.Wochentag
    WHEN 1 THEN N'Montag'
    WHEN 2 THEN N'Dienstag'
    WHEN 3 THEN N'Mittwoch'
    WHEN 4 THEN N'Donnerstag'
    WHEN 5 THEN N'Freitag'
    WHEN 6 THEN N'Samstag'
    WHEN 7 THEN N'Sonntag'
    ELSE 'what?'
  END
), COUNT(VsaTour.ID) AS [Anzahl VSA-Touren]
FROM VsaTour
JOIN Touren ON VsaTour.TourenID = Touren.ID
JOIN KdBer ON VsaTour.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN Vsa ON VsaTour.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
  AND Vsa.Status = N'A'
  AND Kunden.Status = N'A'
GROUP BY Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez, Bereich.Bereich, Bereich.BereichBez, Touren.Wochentag,
  CASE Touren.Wochentag
    WHEN 1 THEN N'Montag'
    WHEN 2 THEN N'Dienstag'
    WHEN 3 THEN N'Mittwoch'
    WHEN 4 THEN N'Donnerstag'
    WHEN 5 THEN N'Freitag'
    WHEN 6 THEN N'Samstag'
    WHEN 7 THEN N'Sonntag'
    ELSE 'what?'
  END
HAVING COUNT(VsaTour.ID) > 1
ORDER BY Kunden.KdNr, Vsa.VsaNr, Bereich.Bereich, Touren.Wochentag;