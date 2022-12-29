DROP TABLE IF EXISTS #BestandGLD;
GO

SELECT Firma.SuchCode AS Firma, Firma.Bez AS Firmenbezeichnung, Lager.SuchCode AS Lagerstandort, Lagerart.Lagerart, Lagerart.LagerartBez AS [Lagerart Bezeichnung], Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Bestand.Bestand AS Lagerbestand, Bestand.GleitPreis AS GLD, Wae.IsoCode AS Währung, CAST(NULL AS money) AS [EKPreis SMZL], Artikel.ID AS ArtikelID, ArtGroe.ID AS ArtGroeID
INTO #BestandGLD
FROM Bestand
JOIN Lagerart ON Bestand.LagerartID = Lagerart.ID
JOIN Standort AS Lager ON Lagerart.LagerID = Lager.ID
JOIN Firma ON Lagerart.FirmaID = Firma.ID
JOIN Wae ON Firma.WaeID = Wae.ID
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
WHERE Lagerart.Neuwertig = 1
  AND Bestand.Bestand != 0
  AND Firma.SuchCode NOT IN (N'FA14', N'BUDA');

GO

WITH SMZLLiefInfo AS (
  SELECT ArGrLief.ArtGroeID, ArGrLief.EkPreis
  FROM ArtiLief
  JOIN Lief ON ArtiLief.LiefID = Lief.ID
  JOIN Standort ON ArtiLief.StandortID = Standort.ID
  JOIN ArGrLief ON ArGrLief.ArtiLiefID = ArtiLief.ID
  WHERE CAST(GETDATE() AS date) BETWEEN ISNULL(ArtiLief.VonDatum, N'1980-01-01') AND ISNULL(ArtiLief.BisDatum, N'2099-12-31')
    AND Standort.SuchCode = N'SMZL'
)
UPDATE #BestandGLD SET [EKPreis SMZL] = SMZLLiefInfo.EKPreis
FROM SMZLLiefInfo
WHERE SMZLLiefInfo.ArtGroeID = #BestandGLD.ArtGroeID
  AND #BestandGLD.[EKPreis SMZL] IS NULL;

GO

WITH SMZLLiefInfo AS (
  SELECT ArtiLief.ArtikelID, ArtiLief.EKPreis
  FROM ArtiLief
  JOIN Lief ON ArtiLief.LiefID = Lief.ID
  JOIN Standort ON ArtiLief.StandortID = Standort.ID
  WHERE CAST(GETDATE() AS date) BETWEEN ISNULL(ArtiLief.VonDatum, N'1980-01-01') AND ISNULL(ArtiLief.BisDatum, N'2099-12-31')
    AND Standort.SuchCode = N'SMZL'
)
UPDATE #BestandGLD SET [EKPreis SMZL] = SMZLLiefInfo.EKPreis
FROM SMZLLiefInfo
WHERE SMZLLiefInfo.ArtikelID = #BestandGLD.ArtikelID
  AND #BestandGLD.[EKPreis SMZL] IS NULL;

GO

WITH SMZLLiefInfo AS (
  SELECT ArGrLief.ArtGroeID, ArGrLief.EkPreis
  FROM ArtiLief
  JOIN Lief ON ArtiLief.LiefID = Lief.ID
  JOIN ArGrLief ON ArGrLief.ArtiLiefID = ArtiLief.ID
  JOIN Artikel ON ArtiLief.ArtikelID = Artikel.ID
  WHERE CAST(GETDATE() AS date) BETWEEN ISNULL(ArtiLief.VonDatum, N'1980-01-01') AND ISNULL(ArtiLief.BisDatum, N'2099-12-31')
    AND ArtiLief.LiefID = Artikel.LiefID --Hauptlieferant
    AND ArtiLief.StandortID = -1
)
UPDATE #BestandGLD SET [EKPreis SMZL] = SMZLLiefInfo.EKPreis
FROM SMZLLiefInfo
WHERE SMZLLiefInfo.ArtGroeID = #BestandGLD.ArtGroeID
  AND #BestandGLD.[EKPreis SMZL] IS NULL;

GO

WITH SMZLLiefInfo AS (
  SELECT ArtiLief.ArtikelID, ArtiLief.EKPreis
  FROM ArtiLief
  JOIN Lief ON ArtiLief.LiefID = Lief.ID
  JOIN Artikel ON ArtiLief.ArtikelID = Artikel.ID
  WHERE CAST(GETDATE() AS date) BETWEEN ISNULL(ArtiLief.VonDatum, N'1980-01-01') AND ISNULL(ArtiLief.BisDatum, N'2099-12-31')
    AND ArtiLief.LiefID = Artikel.LiefID --Hauptlieferant
    AND ArtiLief.StandortID = -1
)
UPDATE #BestandGLD SET [EKPreis SMZL] = SMZLLiefInfo.EKPreis
FROM SMZLLiefInfo
WHERE SMZLLiefInfo.ArtikelID = #BestandGLD.ArtikelID
  AND #BestandGLD.[EKPreis SMZL] IS NULL;

GO

UPDATE #BestandGLD SET [EKPreis SMZL] = ArtGroe.EKPreis
FROM ArtGroe
WHERE #BestandGLD.ArtGroeID = ArtGroe.ID
  AND #BestandGLD.[EKPreis SMZL] IS NULL;

GO

SELECT Firma, Firmenbezeichnung, Lagerstandort, Lagerart, [Lagerart Bezeichnung], ArtikelNr, Artikelbezeichnung, Größe, Lagerbestand, GLD, Währung, [EKPreis SMZL]
FROM #BestandGLD;

GO