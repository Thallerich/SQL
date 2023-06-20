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
  WHERE RechKo.DruckZeitpunkt > N'2023-06-20 11:00:00'
    AND RechKo.DrLaufID = (SELECT DrLaufID FROM RechKo WHERE RechNr = 30336338)
) AS x
RIGHT JOIN Rechnungsanlagen ON Rechnungsanlagen.KundenID = x.KundenID
WHERE x.RechKoID IS NOT NULL
ORDER BY Drucklauf, DruckMitarbeiter, DruckZeitpunkt;

GO

SELECT COUNT(RechKo.ID) AS [Anzahl Rechnungen noch zu Drucken]
FROM RechKo
WHERE RechKo.DrLaufID = (SELECT DrLaufID FROM RechKo WHERE RechNr = 30336338)
  AND RechKo.[Status] < N'F'
  AND RechKo.RechChkID = -1;

GO

SELECT CAST(LogItem.Anlage_ AS date) AS Datum, LogItem.[Version], LogItem.Memo, CONVERT(datetime, SUBSTRING(LogItem.Memo, 1, 23), 104) AS Starttime, CONVERT(datetime, SUBSTRING(LogItem.Memo, LEN(LogItem.Memo) - 38, 23), 104) AS EndTime, DATEDIFF(minute, CONVERT(datetime, SUBSTRING(LogItem.Memo, 1, 23), 104), CONVERT(datetime, SUBSTRING(LogItem.Memo, LEN(LogItem.Memo) - 38, 23), 104)) AS Duration
FROM LogItem
WHERE LogItem.LogCaseID = (SELECT ID FROM LogCase WHERE Bez = N'RechnungsdruckAnalyse')
  AND LogItem.[Version] LIKE N'SVOBKU %'
  AND LogItem.Version LIKE N'% (9.60.%)'
ORDER BY ID DESC;

GO