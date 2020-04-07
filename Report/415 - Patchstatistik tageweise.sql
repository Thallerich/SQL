DECLARE @PatchData TABLE (
  LagerID int,
  Patchdatum date,
  AnzahlBestellung int,
  AnzahlNeu int,
  AnzahlGebraucht int,
  AnzahlGesamt int
);

DECLARE @Patch TABLE (
  LagerID int,
  Lagerstandort nvarchar(40) COLLATE Latin1_General_CS_AS,
  Patchdatum date,
  Bestellung int DEFAULT 0,
  Neu int DEFAULT 0,
  Gebraucht int DEFAULT 0,
  Gesamt int DEFAULT 0
);

WITH Dates AS (
  SELECT [Date] = $1$
  UNION ALL
  SELECT [Date] = DATEADD(day, 1, [Date])
  FROM Dates
  WHERE [Date] <= $2$
)
INSERT INTO @Patch (LagerID, Lagerstandort, Patchdatum)
SELECT Standort.ID AS LagerID, Standort.Bez AS Lagerstanort, [Date] AS Patchdatum
FROM Dates
CROSS JOIN Standort
WHERE Standort.Lager = 1
  AND Standort.ID > 0
OPTION (MAXRECURSION 31);

INSERT INTO @PatchData
SELECT LagerArt.LagerID, Teile.Patchdatum, 
  AnzahlBestellung = COUNT(CASE WHEN LagerArt.Zustand = N'W' THEN 1 ELSE NULL END),
  AnzahlNeu = COUNT(CASE WHEN LagerArt.Zustand = N'N' THEN 1 ELSE NULL END),
  AnzahlGebraucht = COUNT(CASE WHEN LagerArt.Zustand IN (N'G', N'S') THEN 1 ELSE NULL END),
  AnzahlGesamt = COUNT(*)
FROM Teile
JOIN LagerArt ON Teile.LagerArtID = LagerArt.ID
JOIN Artikel ON Teile.ArtikelID = Artikel.ID
WHERE Teile.Patchdatum BETWEEN $1$ AND $2$
  AND Artikel.BereichID IN (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich IN (N'BK', N'FW'))
  AND Teile.LagerArtID > 0
  AND LagerArt.SichtbarID IN ($SICHTBARIDS$)
GROUP BY LagerArt.LagerID, Teile.Patchdatum

UPDATE Patch SET Bestellung = PatchData.AnzahlBestellung, Neu = PatchData.AnzahlNeu, Gebraucht = PatchData.AnzahlGebraucht, Gesamt = PatchData.AnzahlGesamt
FROM @Patch AS Patch
JOIN @PatchData AS PatchData ON PatchData.LagerID = Patch.LagerID AND PatchData.PatchDatum = Patch.Patchdatum;

SELECT Lagerstandort, Patchdatum, Bestellung, Neu, Gebraucht, Gesamt
FROM @Patch
WHERE Neu != 0 OR Gebraucht != 0 OR Bestellung != 0
ORDER BY Lagerstandort, Patchdatum;