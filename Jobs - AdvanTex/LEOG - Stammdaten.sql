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
  AND Kunden.Status = N'A';

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
  Montagstour.LiefTourenBez AS [Tourenbeschreibung Montag],
  Dienstagstour.LiefTourenBez AS [Tourenbeschreibung Dienstag],
  Mittwochstour.LiefTourenBez AS [Tourenbeschreibung Mittwoch],
  Donnerstagstour.LiefTourenBez AS [Tourenbeschreibung Donnerstag],
  Freitagstour.LiefTourenBez AS [Tourenbeschreibung Freitag],
  Samstagstour.LiefTourenBez AS [Tourenbeschreibung Samstag],
  Sonntagstour.LiefTourenBez AS [Tourenbeschreibung Sonntag],
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
  Montagstour.TourenBez AS [Tourenbeschreibung Montag_1],
  Dienstagstour.TourenBez AS [Tourenbeschreibung Dienstag_1],
  Mittwochstour.TourenBez AS [Tourenbeschreibung Mittwoch_1],
  Donnerstagstour.TourenBez AS [Tourenbeschreibung Donnerstag_1],
  Freitagstour.TourenBez AS [Tourenbeschreibung Freitag_1],
  Samstagstour.TourenBez AS [Tourenbeschreibung Samstag_1],
  Sonntagstour.TourenBez AS [Tourenbeschreibung Sonntag_1],
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
  )
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN VsaBer ON VsaBer.VsaID = Vsa.ID
JOIN KdBer ON VsaBer.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN LiefArt ON Vsa.LiefArtID = LiefArt.ID
LEFT OUTER JOIN (
  SELECT VsaTour.VsaID, VsaTour.KdBerID, Touren.Tour, Touren.Bez AS TourenBez, LiefTouren.Wochentag AS LiefWochentag, LiefTouren.Tour AS LiefTour, LiefTouren.Bez AS LiefTourenBez
  FROM VsaTour
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  JOIN #VsaTourLief AS VTL ON VTL.VsaTourID = VsaTour.ID
  JOIN VsaTour AS LiefVsaTour ON VTL.LiefVsaTourID = LiefVsaTour.ID
  JOIN Touren AS LiefTouren ON LiefVsaTour.TourenID = LiefTouren.ID
  WHERE Touren.Wochentag = 1 --Montag
) AS Montagstour ON Montagstour.VsaID = Vsa.ID AND Montagstour.KdBerID = VsaBer.KdBerID
LEFT OUTER JOIN (
  SELECT VsaTour.VsaID, VsaTour.KdBerID, Touren.Tour, Touren.Bez AS TourenBez, LiefTouren.Wochentag AS LiefWochentag, LiefTouren.Tour AS LiefTour, LiefTouren.Bez AS LiefTourenBez
  FROM VsaTour
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  JOIN #VsaTourLief AS VTL ON VTL.VsaTourID = VsaTour.ID
  JOIN VsaTour AS LiefVsaTour ON VTL.LiefVsaTourID = LiefVsaTour.ID
  JOIN Touren AS LiefTouren ON LiefVsaTour.TourenID = LiefTouren.ID
  WHERE Touren.Wochentag = 2 --Dienstag
) AS Dienstagstour ON Dienstagstour.VsaID = Vsa.ID AND Dienstagstour.KdBerID = VsaBer.KdBerID
LEFT OUTER JOIN (
  SELECT VsaTour.VsaID, VsaTour.KdBerID, Touren.Tour, Touren.Bez AS TourenBez, LiefTouren.Wochentag AS LiefWochentag, LiefTouren.Tour AS LiefTour, LiefTouren.Bez AS LiefTourenBez
  FROM VsaTour
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  JOIN #VsaTourLief AS VTL ON VTL.VsaTourID = VsaTour.ID
  JOIN VsaTour AS LiefVsaTour ON VTL.LiefVsaTourID = LiefVsaTour.ID
  JOIN Touren AS LiefTouren ON LiefVsaTour.TourenID = LiefTouren.ID
  WHERE Touren.Wochentag = 3 --Mittwoch
) AS Mittwochstour ON Mittwochstour.VsaID = Vsa.ID AND Mittwochstour.KdBerID = VsaBer.KdBerID
LEFT OUTER JOIN (
  SELECT VsaTour.VsaID, VsaTour.KdBerID, Touren.Tour, Touren.Bez AS TourenBez, LiefTouren.Wochentag AS LiefWochentag, LiefTouren.Tour AS LiefTour, LiefTouren.Bez AS LiefTourenBez
  FROM VsaTour
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  JOIN #VsaTourLief AS VTL ON VTL.VsaTourID = VsaTour.ID
  JOIN VsaTour AS LiefVsaTour ON VTL.LiefVsaTourID = LiefVsaTour.ID
  JOIN Touren AS LiefTouren ON LiefVsaTour.TourenID = LiefTouren.ID
  WHERE Touren.Wochentag = 4 --Donnerstag
) AS Donnerstagstour ON Donnerstagstour.VsaID = Vsa.ID AND Donnerstagstour.KdBerID = VsaBer.KdBerID
LEFT OUTER JOIN (
  SELECT VsaTour.VsaID, VsaTour.KdBerID, Touren.Tour, Touren.Bez AS TourenBez, LiefTouren.Wochentag AS LiefWochentag, LiefTouren.Tour AS LiefTour, LiefTouren.Bez AS LiefTourenBez
  FROM VsaTour
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  JOIN #VsaTourLief AS VTL ON VTL.VsaTourID = VsaTour.ID
  JOIN VsaTour AS LiefVsaTour ON VTL.LiefVsaTourID = LiefVsaTour.ID
  JOIN Touren AS LiefTouren ON LiefVsaTour.TourenID = LiefTouren.ID
  WHERE Touren.Wochentag = 5 --Freitag
) AS Freitagstour ON Freitagstour.VsaID = Vsa.ID AND Freitagstour.KdBerID = VsaBer.KdBerID
LEFT OUTER JOIN (
  SELECT VsaTour.VsaID, VsaTour.KdBerID, Touren.Tour, Touren.Bez AS TourenBez, LiefTouren.Wochentag AS LiefWochentag, LiefTouren.Tour AS LiefTour, LiefTouren.Bez AS LiefTourenBez
  FROM VsaTour
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  JOIN #VsaTourLief AS VTL ON VTL.VsaTourID = VsaTour.ID
  JOIN VsaTour AS LiefVsaTour ON VTL.LiefVsaTourID = LiefVsaTour.ID
  JOIN Touren AS LiefTouren ON LiefVsaTour.TourenID = LiefTouren.ID
  WHERE Touren.Wochentag = 6 --Samstag
) AS Samstagstour ON Samstagstour.VsaID = Vsa.ID AND Samstagstour.KdBerID = VsaBer.KdBerID
LEFT OUTER JOIN (
  SELECT VsaTour.VsaID, VsaTour.KdBerID, Touren.Tour, Touren.Bez AS TourenBez, LiefTouren.Wochentag AS LiefWochentag, LiefTouren.Tour AS LiefTour, LiefTouren.Bez AS LiefTourenBez
  FROM VsaTour
  JOIN Touren ON VsaTour.TourenID = Touren.ID
  JOIN #VsaTourLief AS VTL ON VTL.VsaTourID = VsaTour.ID
  JOIN VsaTour AS LiefVsaTour ON VTL.LiefVsaTourID = LiefVsaTour.ID
  JOIN Touren AS LiefTouren ON LiefVsaTour.TourenID = LiefTouren.ID
  WHERE Touren.Wochentag = 7 --Sonntag
) AS Sonntagstour ON Sonntagstour.VsaID = Vsa.ID AND Sonntagstour.KdBerID = VsaBer.KdBerID
/* WHERE Vsa.StandKonID IN (
  SELECT DISTINCT StandBer.StandKonID
  FROM StandBer
  WHERE StandBer.ProduktionID = @StandortID
) */
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
