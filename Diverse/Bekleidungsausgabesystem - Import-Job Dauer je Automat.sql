SELECT Rentomat.ID AS RentomatID, Rentomat.Bez AS Ausgabesystem, LsKo.Datum, MIN(Scans.[Anlage_]) AS [Erster Scan], MAX(Scans.[Anlage_]) AS [Letzter Scan], COUNT(Scans.ID) AS [Anzahl Scans], DATEDIFF(second, MIN(Scans.[Anlage_]), MAX(Scans.[Anlage_])) AS Dauer
FROM Scans
JOIN EinzHist ON Scans.EinzHistID = EinzHist.ID
JOIN LsPo ON Scans.LsPoID = LsPo.ID
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Rentomat ON Vsa.RentomatID = Rentomat.ID
WHERE Scans.[DateTime] >= DATEADD(day, DATEDIFF(day, 1, GETDATE()), 0)
  AND Scans.Anlage_ >= DATETIME2FROMPARTS(YEAR(GETDATE()), MONTH(GETDATE()), DAY(GETDATE()), 2, 0, 0, 0, 0)
  AND Scans.AnlageUserID_ IN (SELECT ID FROM Mitarbei WHERE MitarbeiUser IN (N'JOBLOG', N'JOB'))
  AND Scans.ActionsID = 65
  AND Rentomat.ID IN (35, 36, 37, 38, 39, 40, 41, 47, 57, 59, 61, 62, 64, 65, 66, 70, 71, 72, 73, 75, 82, 83, 84, 85, 90, 97, 98, 100, 102)
GROUP BY Rentomat.ID, Rentomat.Bez, LsKo.Datum
ORDER BY [Erster Scan] ASC;

GO