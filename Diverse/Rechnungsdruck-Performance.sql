WITH Rechnungsanlagen AS (
  SELECT KdRKoAnl.KundenID, COUNT(DISTINCT KdRKoAnl.RKoAnlagID) AS AnzAnlagen
  FROM KdRKoAnl
  GROUP BY KdRKoAnl.KundenID
)
SELECT Drucklauf, DruckMitarbeiter, RechNr, RechDat, CAST(NettoWert AS float) AS NettoWert, CAST(BruttoWert AS float) AS BruttoWert, DruckZeitpunkt, NächsterDruckzeitpunkt, DATEDIFF(second, DruckZeitpunkt, NächsterDruckzeitpunkt) AS [DruckDauer Sekunden], Rechnungsanlagen.AnzAnlagen AS [Anzahl Rechnungsanlagen]
FROM (
  SELECT RechKo.ID AS RechKoID, RechKo.KundenID, DrLauf.Bez AS Drucklauf, Mitarbei.Name AS DruckMitarbeiter, RechKo.RechNr, RechKo.RechDat, RechKo.NettoWert, RechKo.BruttoWert, RechKo.DruckZeitpunkt, LEAD(RechKo.DruckZeitpunkt, 1, NULL) OVER (PARTITION BY RechKo.DrLaufID, RechKo.DruckMitarbeiID ORDER BY RechKo.DruckZeitpunkt) AS NächsterDruckzeitpunkt
  FROM RechKo
  JOIN DrLauf ON RechKo.DrLaufID = DrLauf.ID
  JOIN Mitarbei ON RechKo.DruckMitarbeiID = Mitarbei.ID
  WHERE RechKo.DruckZeitpunkt > N'2023-01-03 08:38:00'
    AND RechKo.DrLaufID = (SELECT DrLaufID FROM RechKo WHERE RechNr = 30287942)
) AS x
RIGHT JOIN Rechnungsanlagen ON Rechnungsanlagen.KundenID = x.KundenID
WHERE x.RechKoID IS NOT NULL
ORDER BY Drucklauf, DruckMitarbeiter, DruckZeitpunkt;