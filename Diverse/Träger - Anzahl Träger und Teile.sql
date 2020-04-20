SELECT IIF(Firma.SuchCode = N'91', N'Gasser', Firma.SuchCode) AS Firma, KdGf.KurzBez AS Geschäftsbereich, FORMAT(COUNT(DISTINCT Traeger.ID), N'N0', N'de-At') AS [Anzahl Träger], FORMAT(COUNT(Teile.ID), N'N0', N'de-AT') AS [Anzahl Teile]
FROM Teile
RIGHT JOIN Traeger ON Teile.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
WHERE (Teile.Status BETWEEN N'Q' AND N'W' OR Teile.Status IS NULL)
  AND Teile.Einzug IS NULL
  AND Traeger.Geschlecht IN (N'M', N'W')
  AND Traeger.Status IN (N'A', N'K')
  AND Vsa.Status = N'A'
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1
  AND KdGf.KurzBez != N'INT'
  AND KdGf.ID > 0
  AND (UPPER(Traeger.Nachname) NOT LIKE N'POOL%' OR UPPER(Traeger.Nachname) NOT LIKE N'MUSTER%' OR UPPER(Traeger.Vorname) NOT LIKE N'POOL%' OR UPPER(Traeger.Vorname) NOT LIKE N'MUSTER%')
GROUP BY IIF(Firma.SuchCode = N'91', N'Gasser', Firma.SuchCode), KdGf.KurzBez
ORDER BY Firma, Geschäftsbereich;