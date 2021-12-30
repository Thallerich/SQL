WITH PrListPE AS (
  SELECT Kunden.ID AS PrListID, Kunden.KdNr AS PrListNr, Kunden.Name1 AS PrListBez,
    LAST_VALUE(Vertrag.LetztePeDatum) OVER (PARTITION BY Kunden.ID ORDER BY Vertrag.LetztePeDatum ASC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS PrListLastPEDate,
    LAST_VALUE(Vertrag.LetztePeProz) OVER (PARTITION BY Kunden.ID ORDER BY Vertrag.LetztePeDatum ASC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS PrListLastPEProz
  FROM Vertrag
  JOIN Kunden ON Vertrag.KundenID = Kunden.ID
  WHERE Kunden.AdrArtID = 5
),
VertragPE AS (
  SELECT Vertrag.KundenID, Vertrag.PrLaufID,
    LAST_VALUE(Vertrag.LetztePeDatum) OVER (PARTITION BY Vertrag.KundenID, Vertrag.PrlaufID ORDER BY Vertrag.LetztePeDatum ASC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS VertragLastPEDate,
    LAST_VALUE(Vertrag.LetztePeProz) OVER (PARTITION BY Vertrag.KundenID, Vertrag.PrLaufID ORDER BY Vertrag.LetztePeDatum ASC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS VertragLastPEProz
  FROM Vertrag
  WHERE Vertrag.Status = N'A'
)
SELECT DISTINCT Firma.SuchCode AS Firma, Holding.Holding, [Zone].ZonenCode AS Vertriebszone, KdGf.KurzBez AS Geschäftsbereich, Abc.ABCBez$LAN$ AS [ABC-Klasse], Kunden.KdNr, Kunden.SuchCode AS Kunde, VertragPE.VertragLastPEDate AS [Datum der letzten PE], IIF(VertragPE.VertragLastPEProz = 0, NULL, VertragPE.VertragLastPEProz) AS [letzte PE - Prozent], PrLauf.PrLaufBez AS [PE-Kennzeichen], PrListPE.PrListNr AS [Preisliste-Nr], PrListPE.PrListBez AS Preisliste, PrListPE.PrListLastPEDate AS [Datum letzte PE Preisliste], IIF(PrListPE.PrListLastPeProz = 0, NULL, PrListPE.PrListLastPEProz) AS [letzte PE Preisliste - Prozent]
FROM VertragPE
JOIN Kunden ON VertragPE.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Abc ON Kunden.AbcID = Abc.ID
JOIN PrLauf ON VertragPE.PrLaufID = PrLauf.ID
LEFT JOIN PrListPE ON Kunden.PrListKundenID = PrListPe.PrListID
WHERE Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1
  AND Firma.ID IN ($1$)
  AND KdGf.ID IN ($2$)
  AND [Zone].ID IN ($3$)
  AND Abc.ID IN ($4$)
  AND Kunden.SichtbarID IN ($SICHTBARIDS$);