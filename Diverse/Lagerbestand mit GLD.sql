DROP TABLE IF EXISTS #BestandGLD;
GO

SELECT Firma.SuchCode AS Firma, Firma.Bez AS Firmenbezeichnung, Lager.SuchCode AS Lagerstandort, Lagerart.Lagerart, Lagerart.LagerartBez AS [Lagerart Bezeichnung], Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Bestand.Bestand AS Lagerbestand, ArtGroe.EKPreis AS EKPreis, N'EUR' AS Währung, Artikel.ID AS ArtikelID, ArtGroe.ID AS ArtGroeID, Lager.ID AS StandortID, CAST(NULL AS nchar(10)) AS Updated
INTO #BestandGLD
FROM Bestand
JOIN Lagerart ON Bestand.LagerartID = Lagerart.ID
JOIN Standort AS Lager ON Lagerart.LagerID = Lager.ID
JOIN Firma ON Lagerart.FirmaID = Firma.ID
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
WHERE Lagerart.Neuwertig = 1
  AND Bestand.Bestand != 0
  AND Firma.SuchCode NOT IN (N'FA14', N'BUDA');

GO

WITH LiefInfo AS (
  SELECT ArtiLief.ArtikelID, ArGrLief.ArtGroeID, ArtiLief.StandortID, CAST(IIF(LiefPrio.ID IS NOT NULL, 1, 0) AS bit) AS Priorisiert, IIF(ArGrLief.ID IS NOT NULL, ArGrLief.EkPreis, ArtiLief.EKPreis) AS EKPreis
  FROM ArtiLief
  JOIN Lief ON ArtiLief.LiefID = Lief.ID
  LEFT JOIN LiefPrio ON ArtiLief.StandortID = LiefPrio.StandortID AND ArtiLief.ArtikelID = LiefPrio.ArtikelID AND LiefPrio.LiefID = ArtiLief.LiefID
  LEFT JOIN ArGrLief ON ArGrLief.ArtiLiefID = ArtiLief.ID
  WHERE CAST(GETDATE() AS date) BETWEEN ISNULL(ArtiLief.VonDatum, N'1980-01-01') AND ISNULL(ArtiLief.BisDatum, N'2099-12-31')
)
UPDATE #BestandGLD SET EKPreis = LiefInfo.EKPreis, Updated = N'ARGRLIEF_P'
FROM LiefInfo
WHERE LiefInfo.ArtGroeID = #BestandGLD.ArtGroeID
  AND LiefInfo.StandortID = #BestandGLD.StandortID
  AND LiefInfo.Priorisiert = 1
  AND #BestandGLD.Updated IS NULL;

GO

WITH LiefInfo AS (
  SELECT ArtiLief.ArtikelID, ArGrLief.ArtGroeID, ArtiLief.StandortID, CAST(IIF(LiefPrio.ID IS NOT NULL, 1, 0) AS bit) AS Priorisiert, IIF(ArGrLief.ID IS NOT NULL, ArGrLief.EkPreis, ArtiLief.EKPreis) AS EKPreis
  FROM ArtiLief
  JOIN Lief ON ArtiLief.LiefID = Lief.ID
  LEFT JOIN LiefPrio ON ArtiLief.StandortID = LiefPrio.StandortID AND ArtiLief.ArtikelID = LiefPrio.ArtikelID AND LiefPrio.LiefID = ArtiLief.LiefID
  LEFT JOIN ArGrLief ON ArGrLief.ArtiLiefID = ArtiLief.ID
  WHERE CAST(GETDATE() AS date) BETWEEN ISNULL(ArtiLief.VonDatum, N'1980-01-01') AND ISNULL(ArtiLief.BisDatum, N'2099-12-31')
)
UPDATE #BestandGLD SET EKPreis = LiefInfo.EKPreis, Updated = N'ARTILIEF_P'
FROM LiefInfo
WHERE LiefInfo.ArtikelID = #BestandGLD.ArtikelID
  AND LiefInfo.StandortID = #BestandGLD.StandortID
  AND LiefInfo.Priorisiert = 1
  AND LiefInfo.ArtGroeID IS NULL
  AND #BestandGLD.Updated IS NULL;

GO

WITH LiefInfo AS (
  SELECT ArtiLief.ArtikelID, ArGrLief.ArtGroeID, ArtiLief.StandortID, CAST(IIF(LiefPrio.ID IS NOT NULL, 1, 0) AS bit) AS Priorisiert, IIF(ArGrLief.ID IS NOT NULL, ArGrLief.EkPreis, ArtiLief.EKPreis) AS EKPreis
  FROM ArtiLief
  JOIN Lief ON ArtiLief.LiefID = Lief.ID
  LEFT JOIN LiefPrio ON ArtiLief.StandortID = LiefPrio.StandortID AND ArtiLief.ArtikelID = LiefPrio.ArtikelID AND LiefPrio.LiefID = ArtiLief.LiefID
  LEFT JOIN ArGrLief ON ArGrLief.ArtiLiefID = ArtiLief.ID
  WHERE CAST(GETDATE() AS date) BETWEEN ISNULL(ArtiLief.VonDatum, N'1980-01-01') AND ISNULL(ArtiLief.BisDatum, N'2099-12-31')
)
UPDATE #BestandGLD SET EKPreis = LiefInfo.EKPreis, Updated = N'ARGRLIEF_S'
FROM LiefInfo
WHERE LiefInfo.ArtGroeID = #BestandGLD.ArtGroeID
  AND LiefInfo.StandortID = -1
  AND LiefInfo.Priorisiert = 1
  AND #BestandGLD.Updated IS NULL;

GO

WITH LiefInfo AS (
  SELECT ArtiLief.ArtikelID, ArGrLief.ArtGroeID, ArtiLief.StandortID, CAST(IIF(LiefPrio.ID IS NOT NULL, 1, 0) AS bit) AS Priorisiert, IIF(ArGrLief.ID IS NOT NULL, ArGrLief.EkPreis, ArtiLief.EKPreis) AS EKPreis
  FROM ArtiLief
  JOIN Lief ON ArtiLief.LiefID = Lief.ID
  LEFT JOIN LiefPrio ON ArtiLief.StandortID = LiefPrio.StandortID AND ArtiLief.ArtikelID = LiefPrio.ArtikelID AND LiefPrio.LiefID = ArtiLief.LiefID
  LEFT JOIN ArGrLief ON ArGrLief.ArtiLiefID = ArtiLief.ID
  WHERE CAST(GETDATE() AS date) BETWEEN ISNULL(ArtiLief.VonDatum, N'1980-01-01') AND ISNULL(ArtiLief.BisDatum, N'2099-12-31')
)
UPDATE #BestandGLD SET EKPreis = LiefInfo.EKPreis, Updated = N'ARTILIEF_S'
FROM LiefInfo
WHERE LiefInfo.ArtikelID = #BestandGLD.ArtikelID
  AND LiefInfo.StandortID = -1
  AND LiefInfo.Priorisiert = 1
  AND LiefInfo.ArtGroeID IS NULL
  AND #BestandGLD.Updated IS NULL;

GO

WITH LiefInfo AS (
  SELECT ArtiLief.ArtikelID, ArGrLief.ArtGroeID, ArtiLief.StandortID, CAST(IIF(LiefPrio.ID IS NOT NULL, 1, 0) AS bit) AS Priorisiert, IIF(ArGrLief.ID IS NOT NULL, ArGrLief.EkPreis, ArtiLief.EKPreis) AS EKPreis
  FROM ArtiLief
  JOIN Lief ON ArtiLief.LiefID = Lief.ID
  LEFT JOIN LiefPrio ON ArtiLief.StandortID = LiefPrio.StandortID AND ArtiLief.ArtikelID = LiefPrio.ArtikelID AND LiefPrio.LiefID = ArtiLief.LiefID
  LEFT JOIN ArGrLief ON ArGrLief.ArtiLiefID = ArtiLief.ID
  WHERE CAST(GETDATE() AS date) BETWEEN ISNULL(ArtiLief.VonDatum, N'1980-01-01') AND ISNULL(ArtiLief.BisDatum, N'2099-12-31')
)
UPDATE #BestandGLD SET EKPreis = LiefInfo.EKPreis, Updated = N'ARGRLIEF'
FROM LiefInfo
WHERE LiefInfo.ArtGroeID = #BestandGLD.ArtGroeID
  AND LiefInfo.StandortID = #BestandGLD.StandortID
  AND LiefInfo.Priorisiert = 0
  AND #BestandGLD.Updated IS NULL;

GO

WITH LiefInfo AS (
  SELECT ArtiLief.ArtikelID, ArGrLief.ArtGroeID, ArtiLief.StandortID, CAST(IIF(LiefPrio.ID IS NOT NULL, 1, 0) AS bit) AS Priorisiert, IIF(ArGrLief.ID IS NOT NULL, ArGrLief.EkPreis, ArtiLief.EKPreis) AS EKPreis
  FROM ArtiLief
  JOIN Lief ON ArtiLief.LiefID = Lief.ID
  LEFT JOIN LiefPrio ON ArtiLief.StandortID = LiefPrio.StandortID AND ArtiLief.ArtikelID = LiefPrio.ArtikelID AND LiefPrio.LiefID = ArtiLief.LiefID
  LEFT JOIN ArGrLief ON ArGrLief.ArtiLiefID = ArtiLief.ID
  WHERE CAST(GETDATE() AS date) BETWEEN ISNULL(ArtiLief.VonDatum, N'1980-01-01') AND ISNULL(ArtiLief.BisDatum, N'2099-12-31')
)
UPDATE #BestandGLD SET EKPreis = LiefInfo.EKPreis, Updated = N'ARTILIEF'
FROM LiefInfo
WHERE LiefInfo.ArtikelID = #BestandGLD.ArtikelID
  AND LiefInfo.StandortID = #BestandGLD.StandortID
  AND LiefInfo.Priorisiert = 0
  AND LiefInfo.ArtGroeID IS NULL
  AND #BestandGLD.Updated IS NULL;

GO

WITH LiefInfo AS (
  SELECT ArtiLief.ArtikelID, ArGrLief.ArtGroeID, ArtiLief.StandortID, CAST(IIF(LiefPrio.ID IS NOT NULL, 1, 0) AS bit) AS Priorisiert, IIF(ArGrLief.ID IS NOT NULL, ArGrLief.EkPreis, ArtiLief.EKPreis) AS EKPreis
  FROM ArtiLief
  JOIN Lief ON ArtiLief.LiefID = Lief.ID
  LEFT JOIN LiefPrio ON ArtiLief.StandortID = LiefPrio.StandortID AND ArtiLief.ArtikelID = LiefPrio.ArtikelID AND LiefPrio.LiefID = ArtiLief.LiefID
  LEFT JOIN ArGrLief ON ArGrLief.ArtiLiefID = ArtiLief.ID
  WHERE CAST(GETDATE() AS date) BETWEEN ISNULL(ArtiLief.VonDatum, N'1980-01-01') AND ISNULL(ArtiLief.BisDatum, N'2099-12-31')
)
UPDATE #BestandGLD SET EKPreis = LiefInfo.EKPreis, Updated = N'ARGRLIEF_X'
FROM LiefInfo
WHERE LiefInfo.ArtGroeID = #BestandGLD.ArtGroeID
  AND LiefInfo.StandortID = -1
  AND LiefInfo.Priorisiert = 0
  AND #BestandGLD.Updated IS NULL;

GO

WITH LiefInfo AS (
  SELECT ArtiLief.ArtikelID, ArGrLief.ArtGroeID, ArtiLief.StandortID, CAST(IIF(LiefPrio.ID IS NOT NULL, 1, 0) AS bit) AS Priorisiert, IIF(ArGrLief.ID IS NOT NULL, ArGrLief.EkPreis, ArtiLief.EKPreis) AS EKPreis
  FROM ArtiLief
  JOIN Lief ON ArtiLief.LiefID = Lief.ID
  LEFT JOIN LiefPrio ON ArtiLief.StandortID = LiefPrio.StandortID AND ArtiLief.ArtikelID = LiefPrio.ArtikelID AND LiefPrio.LiefID = ArtiLief.LiefID
  LEFT JOIN ArGrLief ON ArGrLief.ArtiLiefID = ArtiLief.ID
  WHERE CAST(GETDATE() AS date) BETWEEN ISNULL(ArtiLief.VonDatum, N'1980-01-01') AND ISNULL(ArtiLief.BisDatum, N'2099-12-31')
)
UPDATE #BestandGLD SET EKPreis = LiefInfo.EKPreis, Updated = N'ARTILIEF_X'
FROM LiefInfo
WHERE LiefInfo.ArtikelID = #BestandGLD.ArtikelID
  AND LiefInfo.StandortID = -1
  AND LiefInfo.Priorisiert = 0
  AND LiefInfo.ArtGroeID IS NULL
  AND #BestandGLD.Updated IS NULL;

GO

SELECT Firma, Firmenbezeichnung, Lagerstandort, Lagerart, [Lagerart Bezeichnung], ArtikelNr, Artikelbezeichnung, Größe, Lagerbestand, EKPreis, Währung
FROM #BestandGLD;

GO