DECLARE @WorkData TABLE (
  TraegerID int,
  VsaID int,
  Schrank nchar(6) COLLATE Latin1_General_CS_AS,
  Fach int
);

INSERT INTO @WorkData (TraegerID, VsaID, Schrank, Fach)
SELECT Traeger.ID AS TraegerID, Traeger.VsaID, _HallFach.Schrank, _HallFach.Fach
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Salesianer.dbo._HallFach ON Traeger.Traeger = RIGHT(N'0000' + RTRIM(_HallFach.Traeger), 4) COLLATE Latin1_General_CS_AS
WHERE Kunden.KdNr = 240068;

UPDATE TraeFach SET TraegerID = -1
WHERE TraegerID IN (
  SELECT TraegerID
  FROM @WorkData
);

UPDATE TraeFach SET TraegerID = wd.TraegerID
FROM TraeFach
JOIN Schrank ON TraeFach.SchrankID = Schrank.ID
JOIN Vsa ON Schrank.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN @WorkData AS wd ON wd.Schrank = Schrank.SchrankNr AND wd.Fach = TraeFach.Fach AND wd.VsaID = Schrank.VsaID
WHERE Kunden.KdNr = 240068;

UPDATE Traeger SET SchrankInfo = RTRIM(wd.Schrank) + N'/' + RTRIM(CAST(wd.Fach AS nchar(4)))
FROM @WorkData wd
WHERE Traeger.ID = wd.TraegerID;

UPDATE Teile SET TeileSchrankInfo = RTRIM(wd.Schrank) + N'/' + RTRIM(CAST(wd.Fach AS nchar(4)))
FROM @WorkData wd
WHERE Teile.TraegerID = wd.TraegerID
  AND Teile.Status = N'Q';