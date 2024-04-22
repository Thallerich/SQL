WITH AnzFaktLastYear AS (
  SELECT RechKo.KundenID, COUNT(RechKo.ID) AS AnzFakt
  FROM RechKo
  WHERE RechKo.Status < N'X'
    AND RechKo.[Status] NOT IN (N'DH', N'HH', N'JH')
    AND RechKo.RechDat >= DATEADD(year, -1, GETDATE())
  GROUP BY RechKo.KundenID
)
SELECT Firma.Bez AS Firma, KdGf.KurzBez AS Geschäftsbereich, Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, Standort.Bez AS Hauptstandort, Bereich.BereichBez$LAN$ AS Kundenbereich
FROM KdBer
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN Kunden ON KdBer.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
LEFT JOIN AnzFaktLastYear ON AnzFaktLastYear.KundenID = Kunden.ID
WHERE KdBer.[Status] = N'A'
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1
  AND KdGf.Status = N'A'
  AND KdGf.KurzBez != N'INT'
  AND Kunden.FirmaID IN ($1$)
  AND (($2$ = 1 AND ISNULL(AnzFaktLastYear.AnzFakt, 0) > 0) OR ($2$ = 0))
  AND NOT EXISTS (
    SELECT Vertrag.*
    FROM Vertrag
    WHERE KdBer.VertragID = Vertrag.ID
      AND Vertrag.Status = N'A'
  );