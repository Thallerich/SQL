DECLARE @KdNr int = 2035;
DECLARE @DateCorrect date = CAST(N'2019-08-05' AS date);
DECLARE @DateWrong date = CAST(N'2019-09-19' AS date);

DECLARE @LsKo TABLE (
  LsKoID int
);

INSERT INTO @LsKo
SELECT DISTINCT LsKo.ID
FROM LsKo, Vsa, Kunden, LsKoArt, LsPo, Scans
WHERE LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.KdNr = @KdNr
  AND LsKo.LsKoArtID = LsKoArt.ID
  AND LsKoArt.Art = 'L'
  AND LsPo.LsKoID = LsKo.ID
  AND Scans.LsPoID = LsPo.ID
  AND LsKo.Datum = @DateWrong
  --AND CAST(Scans.DateTime AS date) = @DateWrong
  --AND Scans.DateTime BETWEEN CAST(N'2018-05-15 00:00:00' AS datetime) AND CAST(N'2018-05-15 23:59:00' AS datetime)

UPDATE LsKo SET Datum = @DateCorrect, FahrtID = 750823, MemoIntern = IIF(MemoIntern IS NULL, N'Lieferdatum geändert auf ' + CAST(@DateCorrect AS nchar(10)) + ' laut Ticket IT-21205  -- STHA', MemoIntern + char(13) + char(10) + N'Lieferdatum geändert auf ' + CAST(@DateCorrect AS nchar(10)) + ' laut Ticket IT-21205  -- STHA')
WHERE LsKo.ID IN (SELECT LsKoID FROM @LsKo);

UPDATE Scans SET EinAusDat = @DateCorrect
FROM Scans
WHERE Scans.LsPoID IN (
  SELECT LsPo.ID
  FROM LsPo
  WHERE LsPo.LsKoID IN (SELECT LsKoID FROM @LsKo)
);

UPDATE Teile SET Ausgang1 = @DateCorrect
FROM Teile
WHERE Teile.ID IN (
  SELECT Scans.TeileID
  FROM Scans
  WHERE Scans.LsPoID IN (
    SELECT LsPo.ID
    FROM LsPo
    WHERE LsPo.LsKoID IN (SELECT LsKoID FROM @LsKo)
  )
);

-- To check for values above.
/*
DECLARE @KdNr int = 2035;
DECLARE @DateCorrect date = CAST(N'2019-08-05' AS date);
DECLARE @DateWrong date = CAST(N'2019-09-19' AS date);

SELECT DISTINCT LsKo.LsNr, LsKo.Datum, LsKo.MemoIntern, LsKo.FahrtID, LsKo.TourenID, LsKo.Folge
FROM LsKo, Vsa, Kunden, LsKoArt, LsPo, Scans
WHERE LsKo.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.KdNr = @KdNr
  AND LsKo.LsKoArtID = LsKoArt.ID
  AND LsKoArt.Art = 'L'
  AND LsPo.LsKoID = LsKo.ID
  AND Scans.LsPoID = LsPo.ID
  AND LsKo.Datum = @DateWrong
  --AND CAST(Scans.DateTime AS date) = @DateWrong
  --AND Scans.DateTime BETWEEN CAST(N'2018-05-15 00:00:00' AS datetime) AND CAST(N'2018-05-15 23:59:00' AS datetime)
;

SELECT N'Wrong' AS Type, LsKo.ID, LsKo.LsNr, LsKo.Status, LsKo.VsaID, LsKo.TraegerID, LsKo.Datum, LsKo.UrDatum, LsKo.FahrtID, LsKo.TourenID, LsKo.Folge, LsKo.MemoIntern, LsKo.UrDatum
FROM LsKo
WHERE LsKo.LsNr = 27193848
UNION
SELECT N'Right' AS Type, LsKo.ID, LsKo.LsNr, LsKo.Status, LsKo.VsaID, LsKo.TraegerID, LsKo.Datum, LsKo.UrDatum, LsKo.FahrtID, LsKo.TourenID, LsKo.Folge, LsKo.MemoIntern, LsKo.UrDatum
FROM LsKo
WHERE LsKo.LsNr = 27193850;

*/