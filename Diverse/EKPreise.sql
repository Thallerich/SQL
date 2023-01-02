DROP TABLE IF EXISTS #EKList;
GO

SELECT Standort.SuchCode AS Lagerstandort, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse AS Größe, COALESCE(ArGrLief.EkPreis, ArtiLief.EkPreis, Artikel.EkPreis) AS EKPreis, Wae.IsoCode AS Währung, CAST(IIF(ISNULL(ArtiLief.LiefID, -9) = Artikel.LiefID AND ISNULL(ArtiLief.StandortID, -1) = -1, 1, 0) AS bit) AS Hauptlieferant, Lief.LiefNr, Lief.Name1 AS Lieferant, N'1' AS Src
INTO #EKList
FROM Artikel
CROSS JOIN Standort
JOIN ArtGroe ON ArtGroe.ArtikelID = Artikel.ID
LEFT JOIN ArtiLief ON ArtiLief.ArtikelID = Artikel.ID AND ArtiLief.StandortID = Standort.ID AND CAST(GETDATE() AS date) BETWEEN ISNULL(ArtiLief.VonDatum, N'1980-01-01') AND ISNULL(ArtiLief.BisDatum, N'2099-12-31')
LEFT JOIN ArGrLief ON ArGrLief.ArtiLiefID = ArtiLief.ID AND ArGrLief.ArtGroeID = ArtGroe.ID AND CAST(GETDATE() AS date) BETWEEN ISNULL(ArGrLief.VonDatum, N'1980-01-01') AND ISNULL(ArGrLief.BisDatum, N'2099-12-31')
LEFT JOIN Lief ON ArtiLief.LiefID = Lief.ID
LEFT JOIN Wae ON Lief.WaeID = Wae.ID
WHERE Standort.Lager = 1
  AND Standort.Status = N'A'
  AND Standort.ID > 0
  AND (Standort.SuchCode = N'SMZL' OR Standort.Land != N'AT')
  AND ArtiLief.ID IS NOT NULL;

GO

INSERT INTO #EKList
SELECT Standort.SuchCode AS Lagerstandort, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse AS Größe, COALESCE(ArGrLief.EkPreis, ArtiLief.EkPreis, Artikel.EkPreis) AS EKPreis, Wae.IsoCode AS Währung, CAST(IIF(ISNULL(ArtiLief.LiefID, -9) = Artikel.LiefID AND ISNULL(ArtiLief.StandortID, -1) = -1, 1, 0) AS bit) AS Hauptlieferant, Lief.LiefNr, Lief.Name1 AS Lieferant, N'2' AS Src
FROM Artikel
CROSS JOIN Standort
JOIN ArtGroe ON ArtGroe.ArtikelID = Artikel.ID
LEFT JOIN ArtiLief ON ArtiLief.ArtikelID = Artikel.ID AND ArtiLief.StandortID = -1 AND CAST(GETDATE() AS date) BETWEEN ISNULL(ArtiLief.VonDatum, N'1980-01-01') AND ISNULL(ArtiLief.BisDatum, N'2099-12-31')
LEFT JOIN ArGrLief ON ArGrLief.ArtiLiefID = ArtiLief.ID AND ArGrLief.ArtGroeID = ArtGroe.ID AND CAST(GETDATE() AS date) BETWEEN ISNULL(ArGrLief.VonDatum, N'1980-01-01') AND ISNULL(ArGrLief.BisDatum, N'2099-12-31')
LEFT JOIN Lief ON ArtiLief.LiefID = Lief.ID
LEFT JOIN Wae ON Lief.WaeID = Wae.ID
WHERE Standort.Lager = 1
  AND Standort.Status = N'A'
  AND Standort.ID > 0
  AND (Standort.SuchCode = N'SMZL' OR Standort.Land != N'AT')
  AND NOT EXISTS (
    SELECT x.*
    FROM #EKList x
    WHERE x.Lagerstandort = Standort.SuchCode
      AND x.ArtikelNr = Artikel.ArtikelNr
      AND x.Größe = ArtGroe.Groesse
  )
  AND ArtiLief.ID IS NOT NULL;

GO

SELECT EKList.Lagerstandort, EKList.ArtikelNr, EKList.ArtikelBez, EKList.Größe, CAST(EKPreis AS float) AS EKPreis, EKList.Währung, EKList.Hauptlieferant, EKList.LiefNr, EKList.Lieferant
FROM #EKList EKList
JOIN (
  SELECT DISTINCT Standort.SuchCode AS Lager, Artikel.ArtikelNr, ArtGroe.Groesse AS Größe
  FROM Bestand
  JOIN Lagerart ON Bestand.LagerArtID = Lagerart.ID
  JOIN Standort ON Lagerart.LagerID = Standort.ID
  JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
  JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
  WHERE Bestand.Bestand != 0
    AND Lagerart.Neuwertig = 1
) x ON x.Lager = EKList.Lagerstandort AND x.ArtikelNr = EKList.ArtikelNr AND x.Größe = EKList.Größe;

GO