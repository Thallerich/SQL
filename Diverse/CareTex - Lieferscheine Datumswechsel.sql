DECLARE @KdNr int = 31201;
DECLARE @DateCorrect date = CAST(N'2018-01-25' AS date);
DECLARE @DateWrong date = CAST(N'2018-01-22' AS date);

UPDATE LsKo SET Datum = @DateCorrect, FahrtID = 698308, TourenID = 57371, Folge = 10, MemoIntern = MemoIntern + N'\r\nLieferdatum geändert laut Ticket tick.IT:22583  -- STHA'
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
    AND Scans.DateTime < CAST(N'2018-01-19 12:00:00' AS datetime)
);

-- To check for values above.
/*
DECLARE @KdNr int = 31201;
DECLARE @DateCorrect date = CAST(N'2018-01-25' AS date);
DECLARE @DateWrong date = CAST(N'2018-01-22' AS date);

SELECT DISTINCT LsKo.LsNr, LsKo.Datum
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
  AND Scans.DateTime < CAST(N'2018-01-19 12:00:00' AS datetime)
;

SELECT N'Worng' AS Type, LsKo.ID, LsKo.LsNr, LsKo.Status, LsKo.VsaID, LsKo.TraegerID, LsKo.Datum, LsKo.UrDatum, LsKo.FahrtID, LsKo.TourenID, LsKo.Folge, LsKo.MemoIntern
FROM LsKo
WHERE LsKo.LsNr = 25253583
UNION
SELECT N'Right' AS Type, LsKo.ID, LsKo.LsNr, LsKo.Status, LsKo.VsaID, LsKo.TraegerID, LsKo.Datum, LsKo.UrDatum, LsKo.FahrtID, LsKo.TourenID, LsKo.Folge, LsKo.MemoIntern
FROM LsKo
WHERE LsKo.LsNr = 25277800;

*/