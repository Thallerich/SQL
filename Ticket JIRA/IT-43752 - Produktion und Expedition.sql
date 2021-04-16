WITH VsaLiefTag AS (
  SELECT VsaID, KdBerID, ExpeditionID, ISNULL([1], 0) AS Montag, ISNULL([2], 0) AS Dienstag, ISNULL([3], 0) AS Mittwoch, ISNULL([4], 0) AS Donnerstag, ISNULL([5], 0) AS Freitag, ISNULL([6], 0) AS Samstag, ISNULL([7], 0) AS Sonntag
  FROM (
    SELECT VsaTour.VsaID, VsaTour.KdBerID, Touren.ExpeditionID, Touren.Wochentag, CAST(1 AS tinyint) AS IsLiefertag
    FROM VsaTour
    JOIN Touren ON VsaTour.TourenID = Touren.ID
    WHERE CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
      AND VsaTour.Bringen = 1
  ) AS Liefertag
  PIVOT (
    MAX(IsLiefertag) FOR Wochentag IN ([1], [2], [3], [4], [5], [6], [7])
  ) AS PivotLiefertag
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nummer], Vsa.Bez AS [VSA-Bezeichnung], Produktion.SuchCode AS [Produktions-Standort], Expedition.SuchCode AS [Expeditions-Standort]
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN VsaBer ON VsaBer.VsaID = Vsa.ID
JOIN VsaLiefTag ON VsaLiefTag.VsaID = Vsa.ID AND VsaLiefTag.KdBerID = VsaBer.KdBerID
JOIN KdBer ON VsaBer.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN StandBer ON StandBer.BereichID = KdBer.BereichID AND StandBer.StandKonID = Vsa.StandKonID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
JOIN Standort AS Expedition ON VsaLiefTag.ExpeditionID = Expedition.ID
WHERE Bereich.Bereich = N'BK'
  AND Expedition.SuchCode = N'UKLU'
  AND Produktion.SuchCode = N'GRAZ'
  AND Vsa.Status = N'A'
  AND Kunden.Status = N'A'
ORDER BY KdNr, [VSA-Nummer];