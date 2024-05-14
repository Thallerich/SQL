DECLARE @StandortID int = (SELECT ID FROM Standort WHERE SuchCode = N'LEOG');

DECLARE @KundenID int;

DECLARE @Kunden TABLE (
  KundenID int
);

DECLARE Tourdaten CURSOR LOCAL FAST_FORWARD FOR
  SELECT KundenID FROM @Kunden;

DROP TABLE IF EXISTS #VsaTourLief;

CREATE TABLE #VsaTourLief (
  VsaTourID int,
  LiefVsaTourID int
);

INSERT INTO @Kunden
SELECT DISTINCT Kunden.ID
FROM VsaTour
JOIN Vsa ON VsaTour.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Touren ON VsaTour.TourenID = Touren.ID
JOIN VsaBer ON VsaBer.VsaID = Vsa.ID
JOIN KdBer ON VsaBer.KdBerID = KdBer.ID
WHERE Touren.ExpeditionID = @StandortID
  AND KdBer.BereichID IN (SELECT ID FROM Bereich WHERE Bereich IN (N'FW', N'LW'))
  AND Vsa.Status = N'A'
  AND Kunden.Status = N'A'
  AND VsaTour.BisDatum >= CAST(GETDATE() AS date);

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

DELETE FROM #VsaTourLief
WHERE VsaTourID IN (
  SELECT vtl.VsaTourID
  FROM #VsaTourLief vtl
  JOIN VsaTour ON vtl.VsaTourID = VsaTour.ID
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  WHERE Touren.ExpeditionID != @StandortID
);

SELECT DISTINCT
  Kunden.KdNr AS Kundennummer,
  Vsa.Bez AS Verteilstellenbezeichnung,
  Vsa.Strasse,
  ISNULL(Vsa.PLZ, N'') + ' ' + ISNULL(Vsa.Ort, N'') AS PLZ,
  Montag = 
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
  Dienstag =
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
  Mittwoch =
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
  Donnerstag =
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
  Freitag =
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
  Samstag =
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
  Sonntag =
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
  [Tourenbeschreibung Montag] = 
    CASE LEFT(Montagstour.LiefTour, 1)
      WHEN N'1' THEN N'A ' + RIGHT(RTRIM(Montagstour.LiefTour), 3)
      WHEN N'2' THEN N'B ' + RIGHT(RTRIM(Montagstour.LiefTour), 3)
      WHEN N'3' THEN N'C ' + RIGHT(RTRIM(Montagstour.LiefTour), 3)
      WHEN N'4' THEN N'D ' + RIGHT(RTRIM(Montagstour.LiefTour), 3)
      WHEN N'5' THEN N'E ' + RIGHT(RTRIM(Montagstour.LiefTour), 3)
      WHEN N'6' THEN N'F ' + RIGHT(RTRIM(Montagstour.LiefTour), 3)
      WHEN N'7' THEN N'G ' + RIGHT(RTRIM(Montagstour.LiefTour), 3)
      ELSE Montagstour.LiefTourenBez
    END,
  [Tourenbeschreibung Dienstag] = 
    CASE LEFT(Dienstagstour.LiefTour, 1)
      WHEN N'1' THEN N'A ' + RIGHT(RTRIM(Dienstagstour.LiefTour), 3)
      WHEN N'2' THEN N'B ' + RIGHT(RTRIM(Dienstagstour.LiefTour), 3)
      WHEN N'3' THEN N'C ' + RIGHT(RTRIM(Dienstagstour.LiefTour), 3)
      WHEN N'4' THEN N'D ' + RIGHT(RTRIM(Dienstagstour.LiefTour), 3)
      WHEN N'5' THEN N'E ' + RIGHT(RTRIM(Dienstagstour.LiefTour), 3)
      WHEN N'6' THEN N'F ' + RIGHT(RTRIM(Dienstagstour.LiefTour), 3)
      WHEN N'7' THEN N'G ' + RIGHT(RTRIM(Dienstagstour.LiefTour), 3)
      ELSE Dienstagstour.LiefTourenBez
    END,
  [Tourenbeschreibung Mittwoch] = 
    CASE LEFT(Mittwochstour.LiefTour, 1)
      WHEN N'1' THEN N'A ' + RIGHT(RTRIM(Mittwochstour.LiefTour), 3)
      WHEN N'2' THEN N'B ' + RIGHT(RTRIM(Mittwochstour.LiefTour), 3)
      WHEN N'3' THEN N'C ' + RIGHT(RTRIM(Mittwochstour.LiefTour), 3)
      WHEN N'4' THEN N'D ' + RIGHT(RTRIM(Mittwochstour.LiefTour), 3)
      WHEN N'5' THEN N'E ' + RIGHT(RTRIM(Mittwochstour.LiefTour), 3)
      WHEN N'6' THEN N'F ' + RIGHT(RTRIM(Mittwochstour.LiefTour), 3)
      WHEN N'7' THEN N'G ' + RIGHT(RTRIM(Mittwochstour.LiefTour), 3)
      ELSE Mittwochstour.LiefTourenBez
    END,
  [Tourenbeschreibung Donnerstag] = 
    CASE LEFT(Donnerstagstour.LiefTour, 1)
      WHEN N'1' THEN N'A ' + RIGHT(RTRIM(Donnerstagstour.LiefTour), 3)
      WHEN N'2' THEN N'B ' + RIGHT(RTRIM(Donnerstagstour.LiefTour), 3)
      WHEN N'3' THEN N'C ' + RIGHT(RTRIM(Donnerstagstour.LiefTour), 3)
      WHEN N'4' THEN N'D ' + RIGHT(RTRIM(Donnerstagstour.LiefTour), 3)
      WHEN N'5' THEN N'E ' + RIGHT(RTRIM(Donnerstagstour.LiefTour), 3)
      WHEN N'6' THEN N'F ' + RIGHT(RTRIM(Donnerstagstour.LiefTour), 3)
      WHEN N'7' THEN N'G ' + RIGHT(RTRIM(Donnerstagstour.LiefTour), 3)
      ELSE Donnerstagstour.LiefTourenBez
    END,
  [Tourenbeschreibung Freitag] = 
    CASE LEFT(Freitagstour.LiefTour, 1)
      WHEN N'1' THEN N'A ' + RIGHT(RTRIM(Freitagstour.LiefTour), 3)
      WHEN N'2' THEN N'B ' + RIGHT(RTRIM(Freitagstour.LiefTour), 3)
      WHEN N'3' THEN N'C ' + RIGHT(RTRIM(Freitagstour.LiefTour), 3)
      WHEN N'4' THEN N'D ' + RIGHT(RTRIM(Freitagstour.LiefTour), 3)
      WHEN N'5' THEN N'E ' + RIGHT(RTRIM(Freitagstour.LiefTour), 3)
      WHEN N'6' THEN N'F ' + RIGHT(RTRIM(Freitagstour.LiefTour), 3)
      WHEN N'7' THEN N'G ' + RIGHT(RTRIM(Freitagstour.LiefTour), 3)
      ELSE Freitagstour.LiefTourenBez
    END,
  [Tourenbeschreibung Samstag] = 
    CASE LEFT(Samstagstour.LiefTour, 1)
      WHEN N'1' THEN N'A ' + RIGHT(RTRIM(Samstagstour.LiefTour), 3)
      WHEN N'2' THEN N'B ' + RIGHT(RTRIM(Samstagstour.LiefTour), 3)
      WHEN N'3' THEN N'C ' + RIGHT(RTRIM(Samstagstour.LiefTour), 3)
      WHEN N'4' THEN N'D ' + RIGHT(RTRIM(Samstagstour.LiefTour), 3)
      WHEN N'5' THEN N'E ' + RIGHT(RTRIM(Samstagstour.LiefTour), 3)
      WHEN N'6' THEN N'F ' + RIGHT(RTRIM(Samstagstour.LiefTour), 3)
      WHEN N'7' THEN N'G ' + RIGHT(RTRIM(Samstagstour.LiefTour), 3)
      ELSE Samstagstour.LiefTourenBez
    END,
  [Tourenbeschreibung Sonntag] = 
    CASE LEFT(Sonntagstour.LiefTour, 1)
      WHEN N'1' THEN N'A ' + RIGHT(RTRIM(Sonntagstour.LiefTour), 3)
      WHEN N'2' THEN N'B ' + RIGHT(RTRIM(Sonntagstour.LiefTour), 3)
      WHEN N'3' THEN N'C ' + RIGHT(RTRIM(Sonntagstour.LiefTour), 3)
      WHEN N'4' THEN N'D ' + RIGHT(RTRIM(Sonntagstour.LiefTour), 3)
      WHEN N'5' THEN N'E ' + RIGHT(RTRIM(Sonntagstour.LiefTour), 3)
      WHEN N'6' THEN N'F ' + RIGHT(RTRIM(Sonntagstour.LiefTour), 3)
      WHEN N'7' THEN N'G ' + RIGHT(RTRIM(Sonntagstour.LiefTour), 3)
      ELSE Sonntagstour.LiefTourenBez
    END,
  LiefArt.LiefArtBez AS Transportartikel,
  Fahrerbemerkung = (
    SELECT FBText.Memo + N'  '
    FROM VsaTexte AS FBText 
    WHERE FBText.KundenID = Kunden.ID 
      AND (FBText.VsaID = Vsa.ID OR FBText.VsaID = -1) 
      AND FBText.TextArtID = 20 
      AND CAST(GETDATE() AS date) BETWEEN FBText.VonDatum AND FBText.BisDatum
    FOR XML PATH('')
  ),
  NULL AS Abteilung,
  Vsa.VsaNr,
  N'FW' AS Aktivität,
  Vsa.ID AS VerteilstellenID,
  IIF(Montagstour.Tour IS NOT NULL, N'MO', NULL) AS Montag_1,
  IIF(Dienstagstour.Tour IS NOT NULL, N'DI', NULL) AS Dienstag_1,
  IIF(Mittwochstour.Tour IS NOT NULL, N'MI', NULL) AS Mittwoch_1,
  IIF(Donnerstagstour.Tour IS NOT NULL, N'DO', NULL) AS Donnerstag_1,
  IIF(Freitagstour.Tour IS NOT NULL, N'FR', NULL) AS Freitag_1,
  IIF(Samstagstour.Tour IS NOT NULL, N'SA', NULL) AS Smastag_1,
  IIF(Sonntagstour.Tour IS NOT NULL, N'SO', NULL) AS Sonntag_1,
  [Tourenbeschreibung Montag_1] = 
    CASE LEFT(Montagstour.Tour, 1)
      WHEN N'1' THEN N'A ' + RIGHT(RTRIM(Montagstour.Tour), 3)
      WHEN N'2' THEN N'B ' + RIGHT(RTRIM(Montagstour.Tour), 3)
      WHEN N'3' THEN N'C ' + RIGHT(RTRIM(Montagstour.Tour), 3)
      WHEN N'4' THEN N'D ' + RIGHT(RTRIM(Montagstour.Tour), 3)
      WHEN N'5' THEN N'E ' + RIGHT(RTRIM(Montagstour.Tour), 3)
      WHEN N'6' THEN N'F ' + RIGHT(RTRIM(Montagstour.Tour), 3)
      WHEN N'7' THEN N'G ' + RIGHT(RTRIM(Montagstour.Tour), 3)
      ELSE Montagstour.TourenBez
    END,
  [Tourenbeschreibung Dienstag_1] = 
    CASE LEFT(Dienstagstour.Tour, 1)
      WHEN N'1' THEN N'A ' + RIGHT(RTRIM(Dienstagstour.Tour), 3)
      WHEN N'2' THEN N'B ' + RIGHT(RTRIM(Dienstagstour.Tour), 3)
      WHEN N'3' THEN N'C ' + RIGHT(RTRIM(Dienstagstour.Tour), 3)
      WHEN N'4' THEN N'D ' + RIGHT(RTRIM(Dienstagstour.Tour), 3)
      WHEN N'5' THEN N'E ' + RIGHT(RTRIM(Dienstagstour.Tour), 3)
      WHEN N'6' THEN N'F ' + RIGHT(RTRIM(Dienstagstour.Tour), 3)
      WHEN N'7' THEN N'G ' + RIGHT(RTRIM(Dienstagstour.Tour), 3)
      ELSE Dienstagstour.TourenBez
    END,
  [Tourenbeschreibung Mittwoch_1] = 
    CASE LEFT(Mittwochstour.Tour, 1)
      WHEN N'1' THEN N'A ' + RIGHT(RTRIM(Mittwochstour.Tour), 3)
      WHEN N'2' THEN N'B ' + RIGHT(RTRIM(Mittwochstour.Tour), 3)
      WHEN N'3' THEN N'C ' + RIGHT(RTRIM(Mittwochstour.Tour), 3)
      WHEN N'4' THEN N'D ' + RIGHT(RTRIM(Mittwochstour.Tour), 3)
      WHEN N'5' THEN N'E ' + RIGHT(RTRIM(Mittwochstour.Tour), 3)
      WHEN N'6' THEN N'F ' + RIGHT(RTRIM(Mittwochstour.Tour), 3)
      WHEN N'7' THEN N'G ' + RIGHT(RTRIM(Mittwochstour.Tour), 3)
      ELSE Mittwochstour.TourenBez
    END,
  [Tourenbeschreibung Donnerstag_1] = 
    CASE LEFT(Donnerstagstour.Tour, 1)
      WHEN N'1' THEN N'A ' + RIGHT(RTRIM(Donnerstagstour.Tour), 3)
      WHEN N'2' THEN N'B ' + RIGHT(RTRIM(Donnerstagstour.Tour), 3)
      WHEN N'3' THEN N'C ' + RIGHT(RTRIM(Donnerstagstour.Tour), 3)
      WHEN N'4' THEN N'D ' + RIGHT(RTRIM(Donnerstagstour.Tour), 3)
      WHEN N'5' THEN N'E ' + RIGHT(RTRIM(Donnerstagstour.Tour), 3)
      WHEN N'6' THEN N'F ' + RIGHT(RTRIM(Donnerstagstour.Tour), 3)
      WHEN N'7' THEN N'G ' + RIGHT(RTRIM(Donnerstagstour.Tour), 3)
      ELSE Donnerstagstour.TourenBez
    END,
  [Tourenbeschreibung Freitag_1] = 
    CASE LEFT(Freitagstour.Tour, 1)
      WHEN N'1' THEN N'A ' + RIGHT(RTRIM(Freitagstour.Tour), 3)
      WHEN N'2' THEN N'B ' + RIGHT(RTRIM(Freitagstour.Tour), 3)
      WHEN N'3' THEN N'C ' + RIGHT(RTRIM(Freitagstour.Tour), 3)
      WHEN N'4' THEN N'D ' + RIGHT(RTRIM(Freitagstour.Tour), 3)
      WHEN N'5' THEN N'E ' + RIGHT(RTRIM(Freitagstour.Tour), 3)
      WHEN N'6' THEN N'F ' + RIGHT(RTRIM(Freitagstour.Tour), 3)
      WHEN N'7' THEN N'G ' + RIGHT(RTRIM(Freitagstour.Tour), 3)
      ELSE Freitagstour.TourenBez
    END,
  [Tourenbeschreibung Samstag_1] = 
    CASE LEFT(Samstagstour.Tour, 1)
      WHEN N'1' THEN N'A ' + RIGHT(RTRIM(Samstagstour.Tour), 3)
      WHEN N'2' THEN N'B ' + RIGHT(RTRIM(Samstagstour.Tour), 3)
      WHEN N'3' THEN N'C ' + RIGHT(RTRIM(Samstagstour.Tour), 3)
      WHEN N'4' THEN N'D ' + RIGHT(RTRIM(Samstagstour.Tour), 3)
      WHEN N'5' THEN N'E ' + RIGHT(RTRIM(Samstagstour.Tour), 3)
      WHEN N'6' THEN N'F ' + RIGHT(RTRIM(Samstagstour.Tour), 3)
      WHEN N'7' THEN N'G ' + RIGHT(RTRIM(Samstagstour.Tour), 3)
      ELSE Samstagstour.TourenBez
    END,
  [Tourenbeschreibung Sonntag_1] = 
    CASE LEFT(Sonntagstour.Tour, 1)
      WHEN N'1' THEN N'A ' + RIGHT(RTRIM(Sonntagstour.Tour), 3)
      WHEN N'2' THEN N'B ' + RIGHT(RTRIM(Sonntagstour.Tour), 3)
      WHEN N'3' THEN N'C ' + RIGHT(RTRIM(Sonntagstour.Tour), 3)
      WHEN N'4' THEN N'D ' + RIGHT(RTRIM(Sonntagstour.Tour), 3)
      WHEN N'5' THEN N'E ' + RIGHT(RTRIM(Sonntagstour.Tour), 3)
      WHEN N'6' THEN N'F ' + RIGHT(RTRIM(Sonntagstour.Tour), 3)
      WHEN N'7' THEN N'G ' + RIGHT(RTRIM(Sonntagstour.Tour), 3)
      ELSE Sonntagstour.TourenBez
    END,
  Packzettelbemerkung = (
    SELECT PZText.Memo + N'  '
    FROM VsaTexte AS PZText
    WHERE PZText.KundenID = Kunden.ID
      AND (PZText.VsaID = Vsa.ID OR PZText.VsaID = -1)
      AND PZText.TextArtID = 5
      AND CAST(GETDATE() AS date) BETWEEN PZText.VonDatum AND PZText.BisDatum
    FOR XML PATH('')
  ),
  Lieferscheinbemerkung = (
    SELECT LSText.Memo + N'  '
    FROM VsaTexte AS LSText
    WHERE LSText.KundenID = Kunden.ID
      AND (LSText.VsaID = Vsa.ID OR LSText.VsaID = -1)
      AND LSText.TextArtID = 2
      AND CAST(GETDATE() AS date) BETWEEN LSText.VonDatum AND LSText.BisDatum
    FOR XML PATH('')
  ),
  Folge = COALESCE(Montagstour.Folge, Dienstagstour.Folge, Mittwochstour.Folge, Donnerstagstour.Folge, Freitagstour.Folge, Samstagstour.Folge, Sonntagstour.Folge),
  [gültig von Montag] = Montagstour.VonDatum,
  [gültig bis Montag] = Montagstour.BisDatum,
  [gültig von Dienstag] = Dienstagstour.VonDatum,
  [gültig bis Dienstag] = Dienstagstour.BisDatum,
  [gültig von Mittwoch] = Mittwochstour.VonDatum,
  [gültig bis Mittwoch] = Mittwochstour.BisDatum,
  [gültig von Donnerstag] = Donnerstagstour.VonDatum,
  [gültig bis Donnerstag] = Donnerstagstour.BisDatum,
  [gültig von Freitag] = Freitagstour.VonDatum,
  [gültig bis Freitag] = Freitagstour.BisDatum,
  [gültig von Samstag] = Samstagstour.VonDatum,
  [gültig bis Samstag] = Samstagstour.BisDatum,
  [gültig von Sonntag] = Sonntagstour.VonDatum,
  [gültig bis Sonntag] = Sonntagstour.BisDatum
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN VsaBer ON VsaBer.VsaID = Vsa.ID
JOIN KdBer ON VsaBer.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN LiefArt ON Vsa.LiefArtID = LiefArt.ID
LEFT OUTER JOIN (
  SELECT VsaTour.VsaID, VsaTour.KdBerID, Touren.Tour, Touren.Bez AS TourenBez, LiefTouren.Wochentag AS LiefWochentag, LiefTouren.Tour AS LiefTour, LiefTouren.Bez AS LiefTourenBez, LiefVsaTour.Folge, LiefVsaTour.VonDatum, LiefVsaTour.BisDatum
  FROM VsaTour
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  JOIN #VsaTourLief AS VTL ON VTL.VsaTourID = VsaTour.ID
  JOIN VsaTour AS LiefVsaTour ON VTL.LiefVsaTourID = LiefVsaTour.ID
  JOIN Touren AS LiefTouren ON LiefVsaTour.TourenID = LiefTouren.ID
  WHERE Touren.Wochentag = 1 --Montag
    AND VsaTour.BisDatum >= CAST(GETDATE() AS date)
) AS Montagstour ON Montagstour.VsaID = Vsa.ID AND Montagstour.KdBerID = VsaBer.KdBerID
LEFT OUTER JOIN (
  SELECT VsaTour.VsaID, VsaTour.KdBerID, Touren.Tour, Touren.Bez AS TourenBez, LiefTouren.Wochentag AS LiefWochentag, LiefTouren.Tour AS LiefTour, LiefTouren.Bez AS LiefTourenBez, LiefVsaTour.Folge, LiefVsaTour.VonDatum, LiefVsaTour.BisDatum
  FROM VsaTour
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  JOIN #VsaTourLief AS VTL ON VTL.VsaTourID = VsaTour.ID
  JOIN VsaTour AS LiefVsaTour ON VTL.LiefVsaTourID = LiefVsaTour.ID
  JOIN Touren AS LiefTouren ON LiefVsaTour.TourenID = LiefTouren.ID
  WHERE Touren.Wochentag = 2 --Dienstag
    AND VsaTour.BisDatum >= CAST(GETDATE() AS date)
) AS Dienstagstour ON Dienstagstour.VsaID = Vsa.ID AND Dienstagstour.KdBerID = VsaBer.KdBerID
LEFT OUTER JOIN (
  SELECT VsaTour.VsaID, VsaTour.KdBerID, Touren.Tour, Touren.Bez AS TourenBez, LiefTouren.Wochentag AS LiefWochentag, LiefTouren.Tour AS LiefTour, LiefTouren.Bez AS LiefTourenBez, LiefVsaTour.Folge, LiefVsaTour.VonDatum, LiefVsaTour.BisDatum
  FROM VsaTour
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  JOIN #VsaTourLief AS VTL ON VTL.VsaTourID = VsaTour.ID
  JOIN VsaTour AS LiefVsaTour ON VTL.LiefVsaTourID = LiefVsaTour.ID
  JOIN Touren AS LiefTouren ON LiefVsaTour.TourenID = LiefTouren.ID
  WHERE Touren.Wochentag = 3 --Mittwoch
    AND VsaTour.BisDatum >= CAST(GETDATE() AS date)
) AS Mittwochstour ON Mittwochstour.VsaID = Vsa.ID AND Mittwochstour.KdBerID = VsaBer.KdBerID
LEFT OUTER JOIN (
  SELECT VsaTour.VsaID, VsaTour.KdBerID, Touren.Tour, Touren.Bez AS TourenBez, LiefTouren.Wochentag AS LiefWochentag, LiefTouren.Tour AS LiefTour, LiefTouren.Bez AS LiefTourenBez, LiefVsaTour.Folge, LiefVsaTour.VonDatum, LiefVsaTour.BisDatum
  FROM VsaTour
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  JOIN #VsaTourLief AS VTL ON VTL.VsaTourID = VsaTour.ID
  JOIN VsaTour AS LiefVsaTour ON VTL.LiefVsaTourID = LiefVsaTour.ID
  JOIN Touren AS LiefTouren ON LiefVsaTour.TourenID = LiefTouren.ID
  WHERE Touren.Wochentag = 4 --Donnerstag
    AND VsaTour.BisDatum >= CAST(GETDATE() AS date)
) AS Donnerstagstour ON Donnerstagstour.VsaID = Vsa.ID AND Donnerstagstour.KdBerID = VsaBer.KdBerID
LEFT OUTER JOIN (
  SELECT VsaTour.VsaID, VsaTour.KdBerID, Touren.Tour, Touren.Bez AS TourenBez, LiefTouren.Wochentag AS LiefWochentag, LiefTouren.Tour AS LiefTour, LiefTouren.Bez AS LiefTourenBez, LiefVsaTour.Folge, LiefVsaTour.VonDatum, LiefVsaTour.BisDatum
  FROM VsaTour
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  JOIN #VsaTourLief AS VTL ON VTL.VsaTourID = VsaTour.ID
  JOIN VsaTour AS LiefVsaTour ON VTL.LiefVsaTourID = LiefVsaTour.ID
  JOIN Touren AS LiefTouren ON LiefVsaTour.TourenID = LiefTouren.ID
  WHERE Touren.Wochentag = 5 --Freitag
    AND VsaTour.BisDatum >= CAST(GETDATE() AS date)
) AS Freitagstour ON Freitagstour.VsaID = Vsa.ID AND Freitagstour.KdBerID = VsaBer.KdBerID
LEFT OUTER JOIN (
  SELECT VsaTour.VsaID, VsaTour.KdBerID, Touren.Tour, Touren.Bez AS TourenBez, LiefTouren.Wochentag AS LiefWochentag, LiefTouren.Tour AS LiefTour, LiefTouren.Bez AS LiefTourenBez, LiefVsaTour.Folge, LiefVsaTour.VonDatum, LiefVsaTour.BisDatum
  FROM VsaTour
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  JOIN #VsaTourLief AS VTL ON VTL.VsaTourID = VsaTour.ID
  JOIN VsaTour AS LiefVsaTour ON VTL.LiefVsaTourID = LiefVsaTour.ID
  JOIN Touren AS LiefTouren ON LiefVsaTour.TourenID = LiefTouren.ID
  WHERE Touren.Wochentag = 6 --Samstag
    AND VsaTour.BisDatum >= CAST(GETDATE() AS date)
) AS Samstagstour ON Samstagstour.VsaID = Vsa.ID AND Samstagstour.KdBerID = VsaBer.KdBerID
LEFT OUTER JOIN (
  SELECT VsaTour.VsaID, VsaTour.KdBerID, Touren.Tour, Touren.Bez AS TourenBez, LiefTouren.Wochentag AS LiefWochentag, LiefTouren.Tour AS LiefTour, LiefTouren.Bez AS LiefTourenBez, LiefVsaTour.Folge, LiefVsaTour.VonDatum, LiefVsaTour.BisDatum
  FROM VsaTour
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  JOIN #VsaTourLief AS VTL ON VTL.VsaTourID = VsaTour.ID
  JOIN VsaTour AS LiefVsaTour ON VTL.LiefVsaTourID = LiefVsaTour.ID
  JOIN Touren AS LiefTouren ON LiefVsaTour.TourenID = LiefTouren.ID
  WHERE Touren.Wochentag = 7 --Sonntag
    AND VsaTour.BisDatum >= CAST(GETDATE() AS date)
) AS Sonntagstour ON Sonntagstour.VsaID = Vsa.ID AND Sonntagstour.KdBerID = VsaBer.KdBerID
WHERE Kunden.ID IN (SELECT KundenID FROM @Kunden)
  AND Bereich.ID IN (SELECT ID FROM Bereich WHERE Bereich IN (N'FW', N'LW'))
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