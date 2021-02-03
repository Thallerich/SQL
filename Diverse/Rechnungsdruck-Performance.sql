WITH Rechnungsanlagen AS (
  SELECT KdRKoAnl.KundenID, COUNT(DISTINCT KdRKoAnl.RKoAnlagID) AS AnzAnlagen
  FROM KdRKoAnl
  GROUP BY KdRKoAnl.KundenID
)
SELECT Drucklauf, DruckMitarbeiter, RechNr, RechDat, NettoWert, BruttoWert, VorherigerDruckzeitpunkt, DruckZeitpunkt, DATEDIFF(second, VorherigerDruckzeitpunkt, DruckZeitpunkt) AS DruckDauer, Rechnungsanlagen.AnzAnlagen
FROM (
  SELECT RechKo.ID AS RechKoID, RechKo.KundenID, DrLauf.Bez AS Drucklauf, Mitarbei.Name AS DruckMitarbeiter, RechKo.RechNr, RechKo.RechDat, RechKo.NettoWert, RechKo.BruttoWert, RechKo.DruckZeitpunkt, LAG(RechKo.DruckZeitpunkt, 1, NULL) OVER (PARTITION BY RechKo.DrLaufID, RechKo.DruckMitarbeiID ORDER BY RechKo.DruckZeitpunkt) AS VorherigerDruckzeitpunkt
  FROM RechKo
  JOIN DrLauf ON RechKo.DrLaufID = DrLauf.ID
  JOIN Mitarbei ON RechKo.DruckMitarbeiID = Mitarbei.ID
  WHERE RechKo.FreigabeZeit > N'2021-02-02 00:00:00'
    AND RechKo.FirmaID = (SELECT Firma.ID FROM Firma WHERE Firma.SuchCode = N'FA14')
) AS x
RIGHT JOIN Rechnungsanlagen ON Rechnungsanlagen.KundenID = x.KundenID
WHERE x.RechKoID IS NOT NULL
ORDER BY Drucklauf, DruckMitarbeiter, DruckZeitpunkt;