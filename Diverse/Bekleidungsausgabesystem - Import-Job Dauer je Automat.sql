SELECT Rentomat.ID AS RentomatID, Rentomat.Bez AS Ausgabesystem, LsKo.Datum, MIN(Scans.[Anlage_]) AS [Erster Scan], MAX(Scans.[Anlage_]) AS [Letzter Scan], COUNT(Scans.ID) AS [Anzahl Scans], DATEDIFF(second, MIN(Scans.[Anlage_]), MAX(Scans.[Anlage_])) AS Dauer
FROM Scans
JOIN EinzHist ON Scans.EinzHistID = EinzHist.ID
JOIN LsPo ON Scans.LsPoID = LsPo.ID
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Rentomat ON Vsa.RentomatID = Rentomat.ID
WHERE Scans.[DateTime] > N'2025-04-01 02:00:00.000'
  AND Scans.AnlageUserID_ IN (SELECT ID FROM Mitarbei WHERE MitarbeiUser IN (N'JOBLOG', N'JOB'))
  AND Scans.ActionsID = 65
GROUP BY Rentomat.ID, Rentomat.Bez, LsKo.Datum
ORDER BY [Erster Scan] ASC;

GO