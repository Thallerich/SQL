DECLARE @RechKoID int = $RECHKOID$;

DECLARE @MinDate date = (
  SELECT MIN(LsKo.Datum) AS MinDate
  FROM LsKo
  JOIN LsPo ON LsPo.LsKoID = LsKo.ID
  JOIN RechPo ON LsPo.RechPoID = RechPo.ID
  WHERE RechPo.RechKoID = @RechKoID
);

DECLARE @MaxDate date = (
  SELECT MAX(LsKo.Datum) AS MaxDate
  FROM LsKo
  JOIN LsPo ON LsPo.LsKoID = LsKo.ID
  JOIN RechPo ON LsPo.RechPoID = RechPo.ID
  WHERE RechPo.RechKoID = @RechKoID
);

DECLARE @MinLeasDate date = (
  SELECT RechKo.VonDatum
  FROM RechKo
  WHERE RechKo.ID = @RechKoID
);

DECLARE @MaxLeasDate date = (
  SELECT RechKo.BisDatum
  FROM RechKo
  WHERE RechKo.ID = @RechKoID
);

IF (@MinDate IS NULL OR @MinDate > @MinLeasDate) SET @MinDate = @MinLeasDate;
IF (@MaxDate IS NULL OR @MaxDate < @MaxLeasDate) SET @MaxDate = @MaxLeasDate;

DECLARE @LsKdData TABLE (
  KundenID int,
  KdNr int,
  AbteilID int,
  KsSt nvarchar(15),
  KsStBez nvarchar(80),
  LsNr int,
  LsDatum date
);

DROP TABLE IF EXISTS #LsDataRKoAnlag3062;

CREATE TABLE #LsDataRKoAnlag3062 (
  KundenID int,
  KdNr int,
  AbteilID int,
  KsSt nvarchar(15),
  KsStBez nvarchar(80),
  LsNrs nvarchar(max)
);

INSERT INTO @LsKdData
SELECT DISTINCT Kunden.ID AS KundenID, Kunden.KdNr, Abteil.ID AS AbteilID, Abteil.Abteilung AS KsSt, Abteil.Bez AS KsStBez, LsKo.LsNr, LsKo.Datum AS LsDatum
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON LsPo.AbteilID = Abteil.ID
WHERE LsKo.ID IN (
  SELECT LsKo.ID
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  WHERE LsKo.Datum BETWEEN @MinDate AND @MaxDate
    AND LsPo.AbteilID IN (
      SELECT DISTINCT RechPo.AbteilID
      FROM RechPo
      WHERE RechPo.RechKoID = @RechKoID
    )
    AND (LsPo.RechPoID < 0 OR LsPo.RechPoID IN (SELECT RechPo.ID FROM RechPo WHERE RechPo.RechKoID = @RechKoID))
);

INSERT INTO #LsDataRKoAnlag3062 (KundenID, KdNr, AbteilID, KsSt, KsStBez)
SELECT DISTINCT KundenID, KdNr, AbteilID, KsSt, KsStBez
FROM @LsKdData;

UPDATE #LsDataRKoAnlag3062 SET LsNrs = (SELECT (STUFF((SELECT N', ' + RTRIM(CAST(LsNr AS char)) + N': ' + FORMAT(LsDatum, 'd', 'de-at') FROM @LsKdData AS x WHERE x.AbteilID = #LsDataRKoAnlag3062.AbteilID ORDER BY LsNr FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 2, '')));

SELECT * FROM #LsDataRKoAnlag3062 ORDER BY KsSt ASC;