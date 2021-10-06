WITH PeKoStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'PEKO'
)
SELECT DISTINCT Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, PeKo.Bez AS Preiserhöhung, PeKoStatus.StatusBez AS [Status Preiserhöhung], PeKo.WirksamDatum AS [Preiserhöhung wirksam ab], PePo.PeProzent AS [prozentuale Erhöhung], Vertrag.LetztePeDatum AS [letzte Preiserhöhung], Vertrag.Preisgarantie
FROM Vertrag
JOIN Kunden ON Vertrag.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
LEFT JOIN PePo ON PePo.VertragID = Vertrag.ID
LEFT JOIN PeKo ON PePo.PeKoID = PeKo.ID
LEFT JOIN PeKoStatus ON PeKo.[Status] = PeKoStatus.[Status]
WHERE ((PeKo.WirksamDatum = N'2021-09-01' AND PeKo.Status != N'X') OR PeKo.ID IS NULL)
  AND Holding.Holding IN (N'HOGD', N'HGP', N'HAND')
  AND Vertrag.Status = N'A'
  AND EXISTS (
    SELECT KdBer.*
    FROM KdBer
    WHERE KdBer.VertragID = Vertrag.ID
  )
ORDER BY Holding, KdNr;