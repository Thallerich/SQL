WITH Jahresumsatz AS (
  SELECT RechKo.KundenID, SUM(RechKo.NettoWert) AS Umsatz
  FROM RechKo
  WHERE RechKo.RechDat BETWEEN DATEADD(year, -1, GETDATE()) AND GETDATE()
  GROUP BY RechKo.KundenID
)
SELECT Vertrag.ID AS VertragsID, Kunden.KdNr, Kunden.SuchCode AS Kunde, KdGf.KurzBez AS Geschäftsbereich, Zone.ZonenCode AS Vertriebszone, Vertrag.VertragLfdNr AS [laufende Vertragsnummer], Vertrag.VertragNr, VertTyp.VertTypBez AS Vertragstyp, Bereich.BereichBez AS [für Bereich], Vertrag.VertragAbschluss AS [abgeschlossen am], Mitarbei.Name AS [abgeschlossen von], Vertrag.VertragStart AS Vertragsstart, Vertrag.VertragEnde AS [reguläres Vertragsende], Vertrag.VertragFristErst AS [Kündigungsfrist Erstlaufzeit], Vertrag.VertragFrist AS [Kündigungsfrist Folgelaufzeit], Vertrag.VertragVerlaeng AS [automatische Verlängerung], Vertrag.VertragEndeMoegl AS [nächstmöglichees Vertragsende], Jahresumsatz.Umsatz AS Jahresumsatz
FROM Kunden
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Vertrag ON Vertrag.KundenID = Kunden.ID
JOIN VertTyp ON Vertrag.VertTypID = VertTyp.ID
JOIN Bereich ON Vertrag.BereichID = Bereich.ID
JOIN Mitarbei ON Vertrag.AbschlussID = Mitarbei.ID
JOIN Jahresumsatz ON Jahresumsatz.KundenID = Kunden.ID
WHERE Firma.SuchCode = N'FA14'
  AND Kunden.AdrArtID = 1
  AND Kunden.Status = N'A'
  AND Vertrag.[Status] = N'A'
ORDER BY Jahresumsatz DESC;