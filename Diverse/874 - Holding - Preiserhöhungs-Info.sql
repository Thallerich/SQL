DECLARE @Date12 date = DATEADD(month, -12, GETDATE());

WITH PeKzKunde AS (
  SELECT DISTINCT Vertrag.KundenID, Vertrag.PrLaufID
  FROM Vertrag
  WHERE Vertrag.Status = N'A'
),
PeLetzte AS (
  SELECT DISTINCT Kunden.HoldingID,
    Vertrag.PrLaufID,
    LAST_VALUE(Vertrag.LetztePeDatum) OVER (PARTITION BY Kunden.HoldingID, Vertrag.PrLaufID ORDER BY Vertrag.LetztePeDatum ASC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS LetztePeDatum,
    LAST_VALUE(Vertrag.LetztePeProz) OVER (PARTITION BY Kunden.HoldingID, Vertrag.PrLaufID ORDER BY Vertrag.LetztePeDatum ASC RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING) AS LetztePeProz
  FROM Vertrag
  JOIN Kunden ON Vertrag.KundenID = Kunden.ID
  WHERE Vertrag.Status = N'A'
),
Umsatz12 AS (
  SELECT Kunden.HoldingID, SUM(RechKo.NettoWert) AS Umsatz
  FROM RechKo
  JOIN Kunden ON RechKo.KundenID = Kunden.ID
  WHERE RechKo.RechDat >= @Date12
  GROUP BY Kunden.HoldingID
)
SELECT Holding.Holding AS [Holding-Stichwort], Holding.Bez AS [Holding-Bezeichnung], COUNT(Kunden.ID) AS [Anzahl aktive Kunden], Umsatz12.Umsatz AS [Netto-Umsatz letzte 12 Monate], PrLauf.PrLaufBez$LAN$ AS Preiserhöhungskennzeichen, PeLetzte.LetztePeDatum AS [letzte Preiserhöhung], IIF(PeLetzte.LetztePeProz = 0, NULL, PeLetzte.LetztePeProz) AS [letzter PE-Satz]
FROM Kunden
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN PeKzKunde ON Kunden.ID = PeKzKunde.KundenID
JOIN PrLauf ON PeKzKunde.PrLaufID = PrLauf.ID
JOIN Umsatz12 ON Holding.ID = Umsatz12.HoldingID
JOIN PeLetzte ON Holding.ID = PeLetzte.HoldingID AND Prlauf.ID = PeLetzte.PrLaufID
WHERE Kunden.AdrArtID = 1
  AND Kunden.Status = N'A'
  AND Kunden.FirmaID IN ($1$)
GROUP BY Holding.Holding, Holding.Bez, Umsatz12.Umsatz, PrLauf.PrLaufBez, PeLetzte.LetztePeDatum, PeLetzte.LetztePeProz
ORDER BY Holding.Holding ASC;