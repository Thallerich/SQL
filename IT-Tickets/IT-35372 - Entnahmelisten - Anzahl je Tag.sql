SELECT CAST(EntnKo.DruckDatum AS date) AS DruckDatum, Lager.SuchCode AS LagKurz, Lager.Bez AS Lagerstandort, COUNT(DISTINCT EntnKo.ID) AS [Anzahl Entnahmelisten]
FROM EntnKo
JOIN EntnPo ON EntnPo.EntnKoID = EntnKo.ID
JOIN Standort AS Lager ON EntnKo.LagerID = Lager.ID
WHERE EntnKo.DruckDatum > N'2020-03-01'
  AND (
    EntnKo.PatchMitarbeiID IN (
      SELECT Mitarbei.ID
      FROM Mitarbei
      WHERE Mitarbei.MitarAbtID = 5111024  -- Mitarbeiter-Abteilung "Bekleidungsservice Lenzing"
        AND Mitarbei.Status = N'A'
    )
    OR
    EntnPo.LagerArtID IN (
      SELECT Lagerart.ID
      FROM Lagerart
      JOIN Standort ON Lagerart.LagerID = Standort.ID
      WHERE Standort.SuchCode IN (N'WOL3', N'WOLX')
    )
  )
GROUP BY CAST(EntnKo.DruckDatum AS date), Lager.SuchCode, Lager.Bez
ORDER BY DruckDatum, LagKurz;