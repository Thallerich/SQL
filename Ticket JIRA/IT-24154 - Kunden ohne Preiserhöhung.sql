SELECT Kunden.KdNr, KUnden.SuchCode AS Kunde, KdGf.KurzBez AS Geschäftsbereich, Firma.Bez AS Firma
FROM Kunden
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
WHERE Kunden.ID IN (
    SELECT Vertrag.KundenID
    FROM Vertrag
    WHERE Vertrag.LetztePeDatum IS NULL
  )
  AND Kunden.ID NOT IN (
    SELECT Vertrag.KundenID
    FROM Vertrag
    WHERE Vertrag.LetztePeDatum IS NOT NULL
  )
  AND Kunden.Status = N'A'
  AND Firma.SuchCode = N'WOMI'
  AND KdGf.Status = N'A'
  AND KdGf.KurzBez <> N'INT';