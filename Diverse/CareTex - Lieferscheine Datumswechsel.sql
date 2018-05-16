DECLARE @KdNr int = 31205;
DECLARE @DateCorrect date = CAST(N'2018-05-21' AS date);
DECLARE @DateWrong date = CAST(N'2018-05-15' AS date);

UPDATE LsKo SET Datum = @DateCorrect, FahrtID = 717038, TourenID = 57351, Folge = 10, MemoIntern = IIF(MemoIntern IS NULL, N'Lieferdatum geändert auf ' + CAST(@DateCorrect AS nchar(10)) + ' laut Ticket tick.IT:23600  -- STHA', MemoIntern + char(13) + char(10) + N'Lieferdatum geändert auf ' + CAST(@DateCorrect AS nchar(10)) + ' laut Ticket tick.IT:23600  -- STHA')
WHERE LsKo.ID IN (
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
);

-- To check for values above.
/*
DECLARE @KdNr int = 31205;
DECLARE @DateCorrect date = CAST(N'2018-05-17' AS date);
DECLARE @DateWrong date = CAST(N'2018-05-15' AS date);

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

SELECT N'Wrong' AS Type, LsKo.ID, LsKo.LsNr, LsKo.Status, LsKo.VsaID, LsKo.TraegerID, LsKo.Datum, LsKo.UrDatum, LsKo.FahrtID, LsKo.TourenID, LsKo.Folge, LsKo.MemoIntern
FROM LsKo
WHERE LsKo.LsNr = 25946474
UNION
SELECT N'Right' AS Type, LsKo.ID, LsKo.LsNr, LsKo.Status, LsKo.VsaID, LsKo.TraegerID, LsKo.Datum, LsKo.UrDatum, LsKo.FahrtID, LsKo.TourenID, LsKo.Folge, LsKo.MemoIntern
FROM LsKo
WHERE LsKo.LsNr = 25946473;

*/