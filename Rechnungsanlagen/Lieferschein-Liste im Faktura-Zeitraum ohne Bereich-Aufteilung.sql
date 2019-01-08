DECLARE @MinDate date = (
  SELECT MIN(LsKo.Datum) AS MinDate
  FROM LsKo
  JOIN LsPo ON LsPo.LsKoID = LsKo.ID
  JOIN RechPo ON LsPo.RechPoID = RechPo.ID
  WHERE RechPo.RechKoID = (SELECT ID FROM RechKo WHERE RechNr = 10014004)
);

DECLARE @MaxDate date = (
  SELECT MAX(LsKo.Datum) AS MaxDate
  FROM LsKo
  JOIN LsPo ON LsPo.LsKoID = LsKo.ID
  JOIN RechPo ON LsPo.RechPoID = RechPo.ID
  WHERE RechPo.RechKoID = (SELECT ID FROM RechKo WHERE RechNr = 10014004)
);

DECLARE @LsKdData TABLE (
  KundenID int,
  KdNr int,
  AbteilID int,
  KsSt nvarchar(15),
  KsStBez nvarchar(80),
  LsNr int
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
SELECT DISTINCT Kunden.ID AS KundenID, Kunden.KdNr, Abteil.ID AS AbteilID, Abteil.Abteilung AS KsSt, Abteil.Bez AS KsStBez, LsKo.LsNr
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
      WHERE RechPo.RechKoID = (SELECT ID FROM RechKo WHERE RechNr = 10014004)
    )
);

INSERT INTO #LsDataRKoAnlag3062 (KundenID, KdNr, AbteilID, KsSt, KsStBez)
SELECT DISTINCT KundenID, KdNr, AbteilID, KsSt, KsStBez
FROM @LsKdData;

UPDATE #LsDataRKoAnlag3062 SET LsNrs = (SELECT (STUFF((SELECT RTRIM(N', ' + CAST(LsNr AS char)) FROM @LsKdData AS x WHERE x.AbteilID = #LsDataRKoAnlag3062.AbteilID ORDER BY LsNr FOR XML PATH(''), TYPE).value('.', 'nvarchar(max)'), 1, 2, '')));

SELECT * FROM #LsDataRKoAnlag3062 ORDER BY KsSt ASC;