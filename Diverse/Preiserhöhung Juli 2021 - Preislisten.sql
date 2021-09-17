WITH PrListPE AS (
  SELECT DISTINCT Kunden.PrListKundenID
  FROM Kunden
  WHERE Kunden.FirmaID = 5260
    AND Kunden.PrListKundenID > 0
    AND EXISTS (
      SELECT PePo.*
      FROM PePo
      JOIN PeKo ON PePo.PeKoID = PeKo.ID
      JOIN Vertrag ON PePo.VertragID = Vertrag.ID
      WHERE Vertrag.KundenID = Kunden.ID
        AND PeKo.Status = N'C'
    )
),
PrListABCKunden AS (
  SELECT Kunden.PrListKundenID, ABC.ABC, COUNT(Kunden.ID) AS Anzahl
  FROM Kunden
  JOIN ABC ON Kunden.AbcID = ABC.ID
  WHERE Kunden.PrListKundenID > 0
    AND Kunden.Status = N'A'
  GROUP BY Kunden.PrListKundenID, ABC.ABC
)
SELECT [Preislisten-Nummer], Preisliste, [Preislisten-Bezeichnung], Preiserhöhungslauf, [Letzte Preiserhöhung], [1] AS [A-Kunden], [2] AS [B-Kunden], [3] AS [C-Kunden]
FROM (
  SELECT DISTINCT Kunden.KdNr AS [Preislisten-Nummer], Kunden.Name1 AS [Preisliste], Kunden.Name2 AS [Preislisten-Bezeichnung], PrLauf.PrLaufBez AS [Preiserhöhungslauf], Vertrag.LetztePeDatum AS [Letzte Preiserhöhung], PrListABCKunden.ABC, PrListABCKunden.Anzahl
  FROM Kunden
  JOIN PrListABCKunden ON PrListABCKunden.PrListKundenID = Kunden.ID
  JOIN Vertrag ON Vertrag.KundenID = Kunden.ID
  JOIN PrLauf ON Vertrag.PrLaufID = PrLauf.ID
  WHERE Kunden.ID IN (
    SELECT PrListPe.PrListKundenID
    FROM PrListPe
  )
) PivotData
PIVOT (
  SUM(Anzahl) FOR ABC IN ([1], [2], [3])
) AS PivotResult
ORDER BY [Preislisten-Nummer] ASC;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

WITH PrListPE AS (
  SELECT DISTINCT Kunden.PrListKundenID
  FROM Kunden
  WHERE Kunden.FirmaID = 5260
    AND Kunden.PrListKundenID > 0
    AND EXISTS (
      SELECT PePo.*
      FROM PePo
      JOIN PeKo ON PePo.PeKoID = PeKo.ID
      JOIN Vertrag ON PePo.VertragID = Vertrag.ID
      WHERE Vertrag.KundenID = Kunden.ID
        AND PeKo.Status = N'C'
    )
)
SELECT DISTINCT Kunden.KdNr AS [Preislisten-Nummer], Kunden.Name1 AS [Preisliste], Kunden.Name2 AS [Preislisten-Bezeichnung], PrLauf.PrLaufBez AS [Preiserhöhungslauf Preisliste], KundePrList.KdNr, KundePrList.SuchCode AS Kunde, ABC.ABCBez AS [ABC-Klasse], KdPrLauf.PrLaufBez AS [Preiserhöhungslauf Kunde]
FROM Kunden
JOIN Vertrag ON Vertrag.KundenID = Kunden.ID
JOIN PrLauf ON Vertrag.PrLaufID = PrLauf.ID
JOIN Kunden AS KundePrList ON KundePrList.PrListKundenID = Kunden.ID
JOIN ABC ON KundePrList.AbcID = ABC.ID
JOIN Vertrag AS VertragPrList ON VertragPrList.KundenID = KundePrList.ID
JOIN PrLauf AS KdPrLauf ON VertragPrList.PrLaufID = KdPrLauf.ID
WHERE Kunden.ID IN (
  SELECT PrListPe.PrListKundenID
  FROM PrListPe
)
ORDER BY [Preislisten-Nummer], KdNr ASC;