DECLARE @Stichtag date = N'2019-03-01';

DROP TABLE IF EXISTS #TmpResultSet;
DROP TABLE IF EXISTS #TmpBestandStichtag;

SELECT Artikel.ID AS ArtikelID, Bestand.ID AS BestandID, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse, 0 AS Bestand, LagerArt.Neuwertig AS Neuware, Artikel.EKPreis, CONVERT(datetime, NULL) AS Letzte_Bewegung, Standort.Bez AS LagerStandort, Standort.ID AS LagerID
INTO #TmpResultSet
FROM Artikel, ArtGroe, Bestand, LagerArt, Standort
WHERE Bestand.ArtGroeID = ArtGroe.ID
  AND ArtGroe.ArtikelID = Artikel.ID
  AND Bestand.LagerArtID = LagerArt.ID
  AND LagerArt.LagerID = Standort.ID
  AND Standort.SuchCode = N'WOLE'
  AND Artikel.ID > 0;

SELECT LagerBew.BestandID, MAX(LagerBew.Zeitpunkt) AS Zeitpunkt
INTO #TmpBestandStichtag
FROM LagerBew, Bestand
WHERE LagerBew.BestandID = Bestand.ID
  AND LagerBew.Zeitpunkt < @Stichtag
GROUP BY LagerBew.BestandID;

UPDATE ResultSet SET ResultSet.Bestand = LagerBew.BestandNeu, ResultSet.Letzte_Bewegung = BestandStichtag.Zeitpunkt
FROM LagerBew, #TmpBestandStichtag BestandStichtag, #TmpResultSet ResultSet
WHERE ResultSet.BestandID = BestandStichtag.BestandID
  AND LagerBew.BestandID = BestandStichtag.BestandID
  AND LagerBew.Zeitpunkt = BestandStichtag.Zeitpunkt;

WITH CTE_Kundenstand AS (
  SELECT Artikel.ID AS ArtikelID, Standort.ID AS LagerID, COUNT(Teile.ID) AS AnzahlTeileKunden
  FROM Teile
  JOIN Artikel ON Teile.ArtikelID = Artikel.ID
  JOIN LagerArt ON Teile.LagerArtID = LagerArt.ID
  JOIN Standort ON LagerArt.LagerID = Standort.ID
  WHERE (Standort.SuchCode = N'WOLE' OR Standort.ID < 0)
    AND (Teile.IndienstDat IS NULL OR Teile.IndienstDat < @Stichtag)
    AND (Teile.Ausdienst IS NULL OR Teile.AusdienstDat >= @Stichtag)
    AND Teile.Status >= N'L'
    AND Artikel.ID > 0
  GROUP BY Artikel.ID, Standort.ID
)
SELECT BestandResult.ArtikelNr, BestandResult.Artikelbezeichnung, SUM(IIF(ISNULL(BestandResult.Neuware, 0) = 1, ISNULL(BestandResult.Bestand, 0), 0)) AS [Bestand Neuware], SUM(IIF(ISNULL(BestandResult.Neuware, 0) = 0, ISNULL(BestandResult.Bestand, 0), 0)) AS [Bestand Gebrauchtware], SUM(ISNULL(BestandResult.Bestand, 0)) AS [Bestand Gesamt], ISNULL(CTE_Kundenstand.AnzahlTeileKunden, 0) AS [Teile bei Kunden], BestandResult.EKPreis, BestandResult.LagerStandort AS Lagerstandort
FROM #TmpResultSet AS BestandResult
LEFT OUTER JOIN CTE_Kundenstand ON BestandResult.ArtikelID = CTE_Kundenstand.ArtikelID AND BestandResult.LagerID = CTE_Kundenstand.LagerID
WHERE (BestandResult.Bestand > 0 OR CTE_Kundenstand.AnzahlTeileKunden > 0)
GROUP BY BestandResult.ArtikelNr, BestandResult.Artikelbezeichnung, BestandResult.EKPreis, BestandResult.LagerStandort, CTE_Kundenstand.AnzahlTeileKunden
ORDER BY ArtikelNr, Lagerstandort;