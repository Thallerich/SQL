DECLARE @KundenID int = (SELECT ID FROM Kunden WHERE KdNr = 19021);

UPDATE Teile SET RestwertInfo = TeileRW.RestwertInfo, AusdRestw = TeileRW.RestwertInfo
FROM Teile
JOIN Week ON DATEADD(week, -1, Teile.AusdienstDat) BETWEEN Week.VonDat AND Week.BisDat
JOIN Vsa ON Teile.VsaID = Vsa.ID
CROSS APPLY funcGetRestwert (Teile.ID, Week.Woche, 1) AS TeileRW
WHERE Vsa.KundenID = @KundenID
  AND Teile.Status = N'W'
  AND Teile.EKGrundAkt != 0
  AND (Teile.RestwertInfo != TeileRW.RestwertInfo OR Teile.AusdRestW != TeileRW.RestwertInfo);