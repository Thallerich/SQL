SELECT Woche, SUM(Eingang) AS [Anzahl Teile Eingang], SUM(Ausgang) AS [Anzahl Teile Ausgange]
FROM (
  SELECT Week.Woche, IIF(Scans.ZielNrID = 1, 1, 0) AS Eingang, IIF(Scans.ZielNrID = 2, 1, 0) AS Ausgang
  FROM Scans
  JOIN Teile ON Scans.TeileID = Teile.ID
  JOIN Vsa ON Teile.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN Week ON Scans.EinAusDat BETWEEN Week.VonDat AND Week.BisDat
  WHERE Kunden.KdNr = 2526018
    AND Scans.EinAusDat >= N'2018-01-01'
    AND Scans.ZielNrID IN (1, 2)
) AS x
GROUP BY Woche;