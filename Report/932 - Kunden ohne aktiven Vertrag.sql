SELECT Firma.Bez AS Firma, KdGf.KurzBez AS Geschäftsbereich, Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, Standort.Bez AS Hauptstandort
FROM Kunden
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
WHERE Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1
  AND KdGf.Status = N'A'
  AND KdGf.KurzBez <> N'INT'
  AND NOT EXISTS (
    SELECT Vertrag.*
    FROM Vertrag
    WHERE Vertrag.KundenID = Kunden.ID
      AND Vertrag.Status = N'A'
  );