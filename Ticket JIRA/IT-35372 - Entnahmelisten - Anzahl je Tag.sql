SELECT CAST(EntnKo.PatchDatum AS date) AS Patchdatum, Lager.SuchCode AS LagKurz, Lager.Bez AS Lagerstandort, COUNT(EntnKo.ID) AS [Anzahl Entnahmelisten]
FROM EntnKo
JOIN Standort AS Lager ON EntnKo.LagerID = Lager.ID
WHERE EntnKo.PatchDatum > N'2020-03-01'
  AND EntnKo.PatchMitarbeiID IN (
    SELECT Mitarbei.ID
    FROM Mitarbei
    WHERE Mitarbei.MitarAbtID = 5111024  -- Mitarbeiter-Abteilung "Bekleidungsservice Lenzing"
      AND Mitarbei.Status = N'A'
  )
GROUP BY CAST(EntnKo.PatchDatum AS date), Lager.SuchCode, Lager.Bez
ORDER BY Patchdatum, LagKurz;