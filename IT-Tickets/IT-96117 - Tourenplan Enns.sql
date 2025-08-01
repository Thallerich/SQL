SET NOCOUNT ON;
SET XACT_ABORT ON;

GO

DECLARE @dbgmsg nvarchar(max);

DECLARE @StandortID int = (SELECT ID FROM Standort WHERE SuchCode = N'WOEN');
DECLARE @BereichID int = (SELECT ID FROM Bereich WHERE Bereich = N'BK');

DECLARE @KundenID int;

DROP TABLE IF EXISTS #VsaTourLief, #Liefermenge, #ScanTime, #Kunden;

CREATE TABLE #VsaTourLief (
  VsaTourID int,
  LiefVsaTourID int
);

SELECT DISTINCT Kunden.ID AS KundenID
INTO #Kunden
FROM VsaTour
JOIN Vsa ON VsaTour.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Touren ON VsaTour.TourenID = Touren.ID
JOIN VsaBer ON VsaBer.VsaID = Vsa.ID
JOIN KdBer ON VsaBer.KdBerID = KdBer.ID
WHERE Touren.ExpeditionID = @StandortID
  AND KdBer.BereichID = @BereichID
  AND Vsa.Status = N'A'
  AND Kunden.Status = N'A'
  AND CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum;

SET @dbgmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Anzahl Kunden: ' + CAST(@@ROWCOUNT AS nvarchar);
RAISERROR(@dbgmsg, 0, 1) WITH NOWAIT;

DECLARE Tourdaten CURSOR LOCAL FAST_FORWARD FOR
  SELECT KundenID FROM #Kunden;

OPEN Tourdaten;

FETCH NEXT FROM Tourdaten INTO @KundenID;

WHILE @@FETCH_STATUS = 0
BEGIN
  INSERT INTO #VsaTourLief
  SELECT VsaTourID, LiefVsaTourID
  FROM dbo.funcViewVsaTour(@KundenID, -1, 0, CAST(GETDATE() AS date), 1)

  FETCH NEXT FROM Tourdaten INTO @KundenID;
END;

CLOSE Tourdaten;
DEALLOCATE Tourdaten;

SET @dbgmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Tourenplan aufgebaut!';
RAISERROR(@dbgmsg, 0, 1) WITH NOWAIT;

DELETE FROM #VsaTourLief
WHERE VsaTourID IN (
  SELECT vtl.VsaTourID
  FROM #VsaTourLief vtl
  JOIN VsaTour ON vtl.VsaTourID = VsaTour.ID
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  WHERE Touren.ExpeditionID != @StandortID
);

SET @dbgmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Tourenplan bereinigt!';
RAISERROR(@dbgmsg, 0, 1) WITH NOWAIT;

SELECT LsKo.VsaID, CAST(ROUND(SUM(LsPo.Menge), 0) AS bigint) AS Menge, COUNT(DISTINCT LsKo.Datum) AS Liefertage
INTO #Liefermenge
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
WHERE Vsa.KundenID IN (SELECT KundenID FROM #Kunden)
  AND LsKo.Datum BETWEEN N'2025-01-01' AND N'2025-06-30'
  /* AND LsKo.Datum BETWEEN $STARTDATE$ AND $ENDDATE$ */
  AND LsKo.[Status] >= N'O'
GROUP BY LsKo.VsaID;

SET @dbgmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Liefermenge ermittelt!';
RAISERROR(@dbgmsg, 0, 1) WITH NOWAIT;

SELECT EinzHist.VsaID, FORMAT(Scans.[DateTime], N'HH:00') AS Einlesezeit, COUNT(Scans.ID) AS [Anzahl Scans]
INTO #ScanTime
FROM Scans
JOIN EinzHist ON Scans.EinzHistID = EinzHist.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
WHERE Vsa.KundenID IN (SELECT KundenID FROM #Kunden)
  AND Scans.[DateTime] > N'2025-01-01 00:00:00.000'
  AND Scans.[DateTime] < N'2025-07-01 00:00:00.000'
  AND Scans.Menge = 1
GROUP BY EinzHist.VsaID, FORMAT(Scans.[DateTime], N'HH:00');

SET @dbgmsg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': Scan-Zeiten ermittelt!';
RAISERROR(@dbgmsg, 0, 1) WITH NOWAIT;

SELECT DISTINCT
  Kunden.KdNr AS Kundennummer,
  Kunden.SuchCode AS Kunde,
  Vsa.VsaNr AS [VSA-Nummer],
  Vsa.Bez AS [VSA-Bezeichnung],
  Vsa.Strasse,
  ISNULL(Vsa.PLZ, N'') + ' ' + ISNULL(Vsa.Ort, N'') AS PLZ,
  StandKon.StandKonBez AS [Standort-Konfiguration],
  [Liefertour Abholung Montag] = 
    CASE Montagstour.LiefWochentag
      WHEN 1 THEN N'MO'
      WHEN 2 THEN N'DI'
      WHEN 3 THEN N'MI'
      WHEN 4 THEN N'DO'
      WHEN 5 THEN N'FR'
      WHEN 6 THEN N'SA'
      WHEN 7 THEN N'SO'
      ELSE NULL
    END,
  [Liefertour Abholung Dienstag] =
   CASE Dienstagstour.LiefWochentag
      WHEN 1 THEN N'MO'
      WHEN 2 THEN N'DI'
      WHEN 3 THEN N'MI'
      WHEN 4 THEN N'DO'
      WHEN 5 THEN N'FR'
      WHEN 6 THEN N'SA'
      WHEN 7 THEN N'SO'
      ELSE NULL
    END,
  [Liefertour Abholung Mittwoch] =
   CASE Mittwochstour.LiefWochentag
      WHEN 1 THEN N'MO'
      WHEN 2 THEN N'DI'
      WHEN 3 THEN N'MI'
      WHEN 4 THEN N'DO'
      WHEN 5 THEN N'FR'
      WHEN 6 THEN N'SA'
      WHEN 7 THEN N'SO'
      ELSE NULL
    END,
  [Liefertour Abholung Donnerstag] =
   CASE Donnerstagstour.LiefWochentag
      WHEN 1 THEN N'MO'
      WHEN 2 THEN N'DI'
      WHEN 3 THEN N'MI'
      WHEN 4 THEN N'DO'
      WHEN 5 THEN N'FR'
      WHEN 6 THEN N'SA'
      WHEN 7 THEN N'SO'
      ELSE NULL
    END,
  [Liefertour Abholung Freitag] =
   CASE Freitagstour.LiefWochentag
      WHEN 1 THEN N'MO'
      WHEN 2 THEN N'DI'
      WHEN 3 THEN N'MI'
      WHEN 4 THEN N'DO'
      WHEN 5 THEN N'FR'
      WHEN 6 THEN N'SA'
      WHEN 7 THEN N'SO'
      ELSE NULL
    END,
  [Liefertour Abholung Samstag] =
   CASE Samstagstour.LiefWochentag
      WHEN 1 THEN N'MO'
      WHEN 2 THEN N'DI'
      WHEN 3 THEN N'MI'
      WHEN 4 THEN N'DO'
      WHEN 5 THEN N'FR'
      WHEN 6 THEN N'SA'
      WHEN 7 THEN N'SO'
      ELSE NULL
    END,
  [Liefertour Abholung Sonntag] =
   CASE Sonntagstour.LiefWochentag
      WHEN 1 THEN N'MO'
      WHEN 2 THEN N'DI'
      WHEN 3 THEN N'MI'
      WHEN 4 THEN N'DO'
      WHEN 5 THEN N'FR'
      WHEN 6 THEN N'SA'
      WHEN 7 THEN N'SO'
      ELSE NULL
    END,
  [Tourenbeschreibung Montag] = Montagstour.LiefTour,
  [Tourenbeschreibung Dienstag] = Dienstagstour.LiefTour,
  [Tourenbeschreibung Mittwoch] = Mittwochstour.LiefTour,
  [Tourenbeschreibung Donnerstag] = Donnerstagstour.LiefTour,
  [Tourenbeschreibung Freitag] = Freitagstour.LiefTour,
  [Tourenbeschreibung Samstag] = Samstagstour.LiefTour,
  [Tourenbeschreibung Sonntag] = Sonntagstour.LiefTour,
  [Abholtour Montag] = IIF(Montagstour.Tour IS NOT NULL, N'MO', NULL),
  [Abholtour Dienstag] = IIF(Dienstagstour.Tour IS NOT NULL, N'DI', NULL),
  [Abholtour Mittwoch] = IIF(Mittwochstour.Tour IS NOT NULL, N'MI', NULL),
  [Abholtour Donnerstag] = IIF(Donnerstagstour.Tour IS NOT NULL, N'DO', NULL),
  [Abholtour Freitag] = IIF(Freitagstour.Tour IS NOT NULL, N'FR', NULL),
  [Abholtour Samstag] = IIF(Samstagstour.Tour IS NOT NULL, N'SA', NULL),
  [Abholtour Sonntag] = IIF(Sonntagstour.Tour IS NOT NULL, N'SO', NULL),
  [Tourenbeschreibung Montag Abholtour] = Montagstour.Tour,
  [Tourenbeschreibung Dienstag Abholtour] = Dienstagstour.Tour,
  [Tourenbeschreibung Mittwoch Abholtour] = Mittwochstour.Tour,
  [Tourenbeschreibung Donnerstag Abholtour] = Donnerstagstour.Tour,
  [Tourenbeschreibung Freitag Abholtour] = Freitagstour.Tour,
  [Tourenbeschreibung Samstag Abholtour] = Samstagstour.Tour,
  [Tourenbeschreibung Sonntag Abholtour] = Sonntagstour.Tour,
  Folge = COALESCE(Montagstour.Folge, Dienstagstour.Folge, Mittwochstour.Folge, Donnerstagstour.Folge, Freitagstour.Folge, Samstagstour.Folge, Sonntagstour.Folge),
  [Pause] = CASE
    WHEN EXISTS(
      SELECT VsaPause.*
      FROM VsaPause
      WHERE VsaPause.VsaID = Vsa.ID
        AND (CAST(GETDATE() AS date) BETWEEN VsaPause.VonDatum AND VsaPause.BisDatum OR dbo.WeekOfDate(GETDATE()) BETWEEN VsaPause.VonWoche AND VsaPause.BisWoche)
        AND VsaPause.IsLieferpause = 1
    )
    THEN CAST(1 AS bit)
    ELSE CAST(0 AS bit)
  END,
  [Pause bis] = (
    SELECT COALESCE(VsaPause.BisDatum, [Week].BisDat)
    FROM VsaPause
    LEFT JOIN [Week] ON VsaPause.BisWoche = [Week].Woche
    WHERE VsaPause.VsaID = Vsa.ID
      AND (CAST(GETDATE() AS date) BETWEEN VsaPause.VonDatum AND VsaPause.BisDatum OR dbo.WeekOfDate(GETDATE()) BETWEEN VsaPause.VonWoche AND VsaPause.BisWoche)
      AND VsaPause.IsLieferpause = 1
  ),
  [Liefermenge] = ISNULL(Liefermenge.Menge, 0),
  [durchschnittliche Liefermenge Stück] = CAST(ROUND(ISNULL(CAST(Liefermenge.Menge AS float) / CAST(IIF(Liefermenge.Liefertage IS NULL OR Liefermenge.Liefertage = 0, 1, Liefermenge.Liefertage) AS float), 0), 0) AS bigint),
  [übliche Einlesezeit] = (
    SELECT TOP 1 #ScanTime.Einlesezeit
    FROM #ScanTime
    WHERE #ScanTime.VsaID = Vsa.ID
    ORDER BY [Anzahl Scans] DESC
  )
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN VsaBer ON VsaBer.VsaID = Vsa.ID
JOIN KdBer ON VsaBer.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN StandKon ON Vsa.StandKonID = StandKon.ID
LEFT OUTER JOIN (
  SELECT VsaTour.VsaID, VsaTour.KdBerID, Touren.Tour, Touren.Bez AS TourenBez, LiefTouren.Wochentag AS LiefWochentag, LiefTouren.Tour AS LiefTour, LiefTouren.Bez AS LiefTourenBez, LiefVsaTour.Folge
  FROM VsaTour
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  JOIN #VsaTourLief AS VTL ON VTL.VsaTourID = VsaTour.ID
  JOIN VsaTour AS LiefVsaTour ON VTL.LiefVsaTourID = LiefVsaTour.ID
  JOIN Touren AS LiefTouren ON LiefVsaTour.TourenID = LiefTouren.ID
  WHERE Touren.Wochentag = 1 --Montag
    AND CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
) AS Montagstour ON Montagstour.VsaID = Vsa.ID AND Montagstour.KdBerID = VsaBer.KdBerID
LEFT OUTER JOIN (
  SELECT VsaTour.VsaID, VsaTour.KdBerID, Touren.Tour, Touren.Bez AS TourenBez, LiefTouren.Wochentag AS LiefWochentag, LiefTouren.Tour AS LiefTour, LiefTouren.Bez AS LiefTourenBez, LiefVsaTour.Folge
  FROM VsaTour
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  JOIN #VsaTourLief AS VTL ON VTL.VsaTourID = VsaTour.ID
  JOIN VsaTour AS LiefVsaTour ON VTL.LiefVsaTourID = LiefVsaTour.ID
  JOIN Touren AS LiefTouren ON LiefVsaTour.TourenID = LiefTouren.ID
  WHERE Touren.Wochentag = 2 --Dienstag
    AND CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
) AS Dienstagstour ON Dienstagstour.VsaID = Vsa.ID AND Dienstagstour.KdBerID = VsaBer.KdBerID
LEFT OUTER JOIN (
  SELECT VsaTour.VsaID, VsaTour.KdBerID, Touren.Tour, Touren.Bez AS TourenBez, LiefTouren.Wochentag AS LiefWochentag, LiefTouren.Tour AS LiefTour, LiefTouren.Bez AS LiefTourenBez, LiefVsaTour.Folge
  FROM VsaTour
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  JOIN #VsaTourLief AS VTL ON VTL.VsaTourID = VsaTour.ID
  JOIN VsaTour AS LiefVsaTour ON VTL.LiefVsaTourID = LiefVsaTour.ID
  JOIN Touren AS LiefTouren ON LiefVsaTour.TourenID = LiefTouren.ID
  WHERE Touren.Wochentag = 3 --Mittwoch
    AND CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
) AS Mittwochstour ON Mittwochstour.VsaID = Vsa.ID AND Mittwochstour.KdBerID = VsaBer.KdBerID
LEFT OUTER JOIN (
  SELECT VsaTour.VsaID, VsaTour.KdBerID, Touren.Tour, Touren.Bez AS TourenBez, LiefTouren.Wochentag AS LiefWochentag, LiefTouren.Tour AS LiefTour, LiefTouren.Bez AS LiefTourenBez, LiefVsaTour.Folge
  FROM VsaTour
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  JOIN #VsaTourLief AS VTL ON VTL.VsaTourID = VsaTour.ID
  JOIN VsaTour AS LiefVsaTour ON VTL.LiefVsaTourID = LiefVsaTour.ID
  JOIN Touren AS LiefTouren ON LiefVsaTour.TourenID = LiefTouren.ID
  WHERE Touren.Wochentag = 4 --Donnerstag
    AND CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
) AS Donnerstagstour ON Donnerstagstour.VsaID = Vsa.ID AND Donnerstagstour.KdBerID = VsaBer.KdBerID
LEFT OUTER JOIN (
  SELECT VsaTour.VsaID, VsaTour.KdBerID, Touren.Tour, Touren.Bez AS TourenBez, LiefTouren.Wochentag AS LiefWochentag, LiefTouren.Tour AS LiefTour, LiefTouren.Bez AS LiefTourenBez, LiefVsaTour.Folge
  FROM VsaTour
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  JOIN #VsaTourLief AS VTL ON VTL.VsaTourID = VsaTour.ID
  JOIN VsaTour AS LiefVsaTour ON VTL.LiefVsaTourID = LiefVsaTour.ID
  JOIN Touren AS LiefTouren ON LiefVsaTour.TourenID = LiefTouren.ID
  WHERE Touren.Wochentag = 5 --Freitag
    AND CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
) AS Freitagstour ON Freitagstour.VsaID = Vsa.ID AND Freitagstour.KdBerID = VsaBer.KdBerID
LEFT OUTER JOIN (
  SELECT VsaTour.VsaID, VsaTour.KdBerID, Touren.Tour, Touren.Bez AS TourenBez, LiefTouren.Wochentag AS LiefWochentag, LiefTouren.Tour AS LiefTour, LiefTouren.Bez AS LiefTourenBez, LiefVsaTour.Folge
  FROM VsaTour
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  JOIN #VsaTourLief AS VTL ON VTL.VsaTourID = VsaTour.ID
  JOIN VsaTour AS LiefVsaTour ON VTL.LiefVsaTourID = LiefVsaTour.ID
  JOIN Touren AS LiefTouren ON LiefVsaTour.TourenID = LiefTouren.ID
  WHERE Touren.Wochentag = 6 --Samstag
    AND CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
) AS Samstagstour ON Samstagstour.VsaID = Vsa.ID AND Samstagstour.KdBerID = VsaBer.KdBerID
LEFT OUTER JOIN (
  SELECT VsaTour.VsaID, VsaTour.KdBerID, Touren.Tour, Touren.Bez AS TourenBez, LiefTouren.Wochentag AS LiefWochentag, LiefTouren.Tour AS LiefTour, LiefTouren.Bez AS LiefTourenBez, LiefVsaTour.Folge
  FROM VsaTour
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  JOIN #VsaTourLief AS VTL ON VTL.VsaTourID = VsaTour.ID
  JOIN VsaTour AS LiefVsaTour ON VTL.LiefVsaTourID = LiefVsaTour.ID
  JOIN Touren AS LiefTouren ON LiefVsaTour.TourenID = LiefTouren.ID
  WHERE Touren.Wochentag = 7 --Sonntag
    AND CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum
) AS Sonntagstour ON Sonntagstour.VsaID = Vsa.ID AND Sonntagstour.KdBerID = VsaBer.KdBerID
LEFT JOIN #Liefermenge AS Liefermenge ON Vsa.ID = Liefermenge.VsaID
WHERE Kunden.ID IN (SELECT KundenID FROM #Kunden)
  AND Bereich.ID = @BereichID
  AND (
    Montagstour.LiefWochentag IS NOT NULL
    OR Dienstagstour.LiefWochentag IS NOT NULL
    OR Mittwochstour.LiefWochentag IS NOT NULL
    OR Donnerstagstour.LiefWochentag IS NOT NULL
    OR Freitagstour.LiefWochentag IS NOT NULL
    OR Samstagstour.LiefWochentag IS NOT NULL
    OR Sonntagstour.LiefWochentag IS NOT NULL
  )
ORDER BY Kundennummer ASC;