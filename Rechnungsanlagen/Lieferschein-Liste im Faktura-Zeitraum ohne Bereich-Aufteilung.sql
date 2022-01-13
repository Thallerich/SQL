DECLARE @RechKoID int = (SELECT ID FROM RechKo WHERE RechNr = 30176933); --$RECHKOID$;

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
WHERE Kunden.ID = (SELECT RechKo.KundenID FROM RechKo WHERE RechKo.ID =  @RechKoID)
  AND LsKo.Datum BETWEEN @MinDate AND @MaxDate
  AND LsPo.AbteilID IN (
    SELECT DISTINCT RechPo.AbteilID
    FROM RechPo
    WHERE RechPo.RechKoID = @RechKoID
  )
  AND (LsPo.RechPoID < 0 OR LsPo.RechPoID IN (SELECT RechPo.ID FROM RechPo WHERE RechPo.RechKoID = @RechKoID));

INSERT INTO #LsDataRKoAnlag3062 (KundenID, KdNr, AbteilID, KsSt, KsStBez)
SELECT DISTINCT KundenID, KdNr, AbteilID, KsSt, KsStBez
FROM @LsKdData;

DROP TABLE IF EXISTS #LsDataRKoAnlag3062LsNrsProAbteilDat;

select AbteilID, LsDatum, (FORMAT(LsDatum, 'd', 'de-at') + ': ' + LsNrs) LsNrs
into #LsDataRKoAnlag3062LsNrsProAbteilDat
from (
SELECT AbteilID, LsDatum, STUFF((select ', ' + RTRIM(CAST(LsNr AS char)) from @LsKdData as innerLsKoData where innerLsKoData.LsDatum = LsKoData.LsDatum
and innerLsKoData.AbteilID = LsKoData.AbteilID order by LsNr for xml path('')), 1,1,'') as LsNrs
FROM @LsKdData as LsKoData
group by AbteilID, LsDatum) Daten
order by AbteilID, LsDatum;

update #LsDataRKoAnlag3062 set LsNrs = Daten2.DatLsNr
from (
select AbteilID, STUFF((select char(10) + LsNrs from #LsDataRKoAnlag3062LsNrsProAbteilDat as innertbl where innertbl.AbteilID = #LsDataRKoAnlag3062LsNrsProAbteilDat.AbteilID order by AbteilID, LsDatum for xml path('')), 1,1,'') as DatLsNr
from #LsDataRKoAnlag3062LsNrsProAbteilDat
group by AbteilID) Daten2
where Daten2.AbteilID = #LsDataRKoAnlag3062.AbteilID;

SELECT * FROM #LsDataRKoAnlag3062 ORDER BY KsSt ASC;