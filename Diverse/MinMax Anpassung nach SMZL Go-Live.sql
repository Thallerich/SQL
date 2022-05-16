DROP TABLE IF EXISTS #MinMaxChange;
DROP TABLE IF EXISTS #MinMaxNonStandard;

GO

CREATE TABLE #MinMaxChange (
  BestandID int PRIMARY KEY,
  Minimum int,
  Maximum int
);

CREATE TABLE #MinMaxNonStandard (
  BestandID int PRIMARY KEY
);

GO

INSERT INTO #MinMaxNonStandard (BestandID)
SELECT Bestand.ID
FROM Bestand
JOIN Lagerart ON Bestand.LagerArtID = Lagerart.ID
JOIN Standort AS Lager ON Lagerart.LagerID = Lager.ID
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN GroePo ON GroePo.GroeKoID = Artikel.GroeKoID AND GroePo.Groesse = ArtGroe.Groesse
WHERE Lager.SuchCode IN (N'WOLX', N'WOEN', N'WOLI', N'WOL3')
  AND (Bestand.Minimum != 0 OR Bestand.Maximum != 0)
  AND ArtGroe.StandardLaenge = 0
  AND Lagerart.MinMax = 1
  AND ArtGroe.Status != N'I'
  AND EXISTS (
    SELECT StandardArtGroe.ID
    FROM ArtGroe AS StandardArtGroe
    JOIN Artikel AS StandardArtikel ON StandardArtGroe.ArtikelID = StandardArtikel.ID
    JOIN GroePo AS StandardGroePo ON StandardArtikel.GroeKoID = StandardGroePo.GroeKoID AND StandardArtGroe.Groesse = StandardGroePo.Groesse
    WHERE StandardArtGroe.ArtikelID = Artikel.ID
      AND StandardGroePo.Gruppe = GroePo.Gruppe
      AND StandardArtGroe.StandardLaenge = 1
  );

GO

WITH NonStandard AS (
  SELECT Bestand.ID AS BestandID, Bestand.LagerArtID, Bestand.ArtGroeID, ArtGroe.ArtikelID, GroePo.Gruppe, GroePo.Folge, GroePo.GroeKoID, Bestand.Minimum, Bestand.Maximum
  FROM Bestand
  JOIN Lagerart ON Bestand.LagerArtID = Lagerart.ID
  JOIN Standort AS Lager ON Lagerart.LagerID = Lager.ID
  JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
  JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
  JOIN GroePo ON GroePo.GroeKoID = Artikel.GroeKoID AND GroePo.Groesse = ArtGroe.Groesse
  WHERE Lager.SuchCode IN (N'WOLX', N'WOEN', N'WOLI', N'WOL3')
    AND (Bestand.Minimum != 0 OR Bestand.Maximum != 0)
    AND ArtGroe.StandardLaenge = 0
    AND Lagerart.MinMax = 1
    AND ArtGroe.Status != N'I'
    AND EXISTS (
      SELECT StandardArtGroe.ID
      FROM ArtGroe AS StandardArtGroe
      JOIN Artikel AS StandardArtikel ON StandardArtGroe.ArtikelID = StandardArtikel.ID
      JOIN GroePo AS StandardGroePo ON StandardArtikel.GroeKoID = StandardGroePo.GroeKoID AND StandardArtGroe.Groesse = StandardGroePo.Groesse
      WHERE StandardArtGroe.ArtikelID = Artikel.ID
        AND StandardGroePo.Gruppe = GroePo.Gruppe
        AND StandardArtGroe.StandardLaenge = 1
    )
)
INSERT INTO #MinMaxChange (BestandID, Minimum, Maximum)
SELECT Bestand.ID AS BestandID, Bestand.Minimum + SUM(NonStandard.Minimum) AS [Minimum neu], Bestand.Maximum + SUM(NonStandard.Maximum) AS [Maximum neu]
FROM Bestand
JOIN Lagerart ON Bestand.LagerArtID = Lagerart.ID
JOIN Standort AS Lager ON Lagerart.LagerID = Lager.ID
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN GroePo ON GroePo.GroeKoID = Artikel.GroeKoID AND GroePo.Groesse = ArtGroe.Groesse
JOIN NonStandard ON NonStandard.ArtikelID = Artikel.ID AND NonStandard.LagerArtID = Bestand.LagerArtID AND NonStandard.Folge < GroePo.Folge AND NonStandard.Gruppe = GroePo.Gruppe
WHERE Lager.SuchCode IN (N'WOLX', N'WOEN', N'WOLI', N'WOL3')
  AND ArtGroe.StandardLaenge = 1
  AND Lagerart.MinMax = 1
  AND ArtGroe.Status != N'I'
GROUP BY Bestand.ID, Bestand.Minimum, Bestand.Maximum;

GO

UPDATE Bestand SET Minimum = MinMaxChange.Minimum, Maximum = MinMaxChange.Maximum
FROM #MinMaxChange AS MinMaxChange
WHERE MinMaxChange.BestandID = Bestand.ID;

UPDATE Bestand SET Minimum = 0, Maximum = 0
FROM #MinMaxNonStandard AS MinMaxNonStandard
WHERE MinMaxNonStandard.BestandID = Bestand.ID;

GO