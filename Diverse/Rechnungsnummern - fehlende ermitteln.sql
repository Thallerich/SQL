DECLARE RechNrKr CURSOR FOR
SELECT DISTINCT RechNrKr.FirmaID, CAST(sequences.start_value AS int) AS startnum, CAST(sequences.current_value AS int) AS endnum FROM sys.sequences JOIN Wozabal.dbo.RechNrKr ON N'NextID_RECHNRKR_' + RechNrKr.NextIDCode = sequences.name COLLATE Latin1_General_CI_AS WHERE sequences.name LIKE N'NextID_RECHNRKR_SALI_%_8ST';

DECLARE @FirmaID int;
DECLARE @startnum int;
DECLARE @endnum int;

DECLARE @RechKo TABLE (
  FirmaID int,
  RechNr int,
  RechDat date,
  ExportDate date,
  used bit DEFAULT 0,
  exported bit DEFAULT 0
);

OPEN RechNrKr;

FETCH NEXT FROM RechNrKr INTO @FirmaID, @startnum, @endnum;

WHILE @@FETCH_STATUS = 0
BEGIN
  WITH CTE_RechNrKr AS (
    SELECT @FirmaID AS FirmaID, @startnum AS RechNr
    UNION ALL
    SELECT @FirmaID, RechNr + 1 FROM CTE_RechNrKr WHERE RechNr + 1 < @endnum
  )
  INSERT INTO @RechKo (FirmaID, RechNr)
  SELECT FirmaID, RechNr FROM CTE_RechNrKr OPTION (MAXRECURSION 32767);

  FETCH NEXT FROM RechNrKr INTO @FirmaID, @startnum, @endnum;
END;

CLOSE RechNrKr;
DEALLOCATE RechNrKr;

UPDATE r SET r.used = 1, r.RechDat = Rechko.RechDat
FROM @RechKo AS r
JOIN Wozabal.dbo.RechKo ON r.RechNr = RechKo.RechNr;

UPDATE r SET r.exported = 1, r.ExportDate = CAST(FibuExp.Zeitpunkt AS date)
FROM @RechKo AS r
JOIN Wozabal.dbo.RechKo ON r.RechNr = RechKo.RechNr
JOIN Wozabal.dbo.FibuExp ON RechKo.FibuExpID = FibuExp.ID
WHERE RechKo.FibuExpID > 0;

SELECT Firma.SuchCode AS Firma, r.RechNr, r.RechDat, r.ExportDate, r.used, r.exported
FROM @RechKo AS r
JOIN Firma ON r.FirmaID = Firma.ID;