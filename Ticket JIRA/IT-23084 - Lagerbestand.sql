DECLARE @Stichtag date = N'2019-04-01';

DROP TABLE IF EXISTS #TmpResultSet;
DROP TABLE IF EXISTS #TmpBestandStichtag;

SELECT Artikel.ID AS ArtikelID, Bestand.ID AS BestandID, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse, 0 AS Bestand, LagerArt.Neuwertig AS Neuware, Artikel.EKPreis, CONVERT(datetime, NULL) AS Letzte_Bewegung,
  LagerStandort = 
    CASE Standort.Bez
      WHEN N'Lenzing GW' THEN N'MBK Lenzing'
      WHEN N'Lenzing IG' THEN N'Micronclean Lenzing'
    ELSE Standort.Bez
  END,
  Standort.ID AS LagerID
INTO #TmpResultSet
FROM Artikel, ArtGroe, Bestand, LagerArt, Standort
WHERE Bestand.ArtGroeID = ArtGroe.ID
  AND ArtGroe.ArtikelID = Artikel.ID
  AND Bestand.LagerArtID = LagerArt.ID
  AND LagerArt.LagerID = Standort.ID
  AND Standort.SuchCode IN (N'WOLE', N'UKLU')
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
  AND LagerBew.Zeitpunkt = BestandStichtag.Zeitpunkt
  AND LagerBew.ID = (SELECT MAX(ID) FROM LagerBew AS LB WHERE LB.BestandID = BestandStichtag.BestandID AND LB.Zeitpunkt = BestandStichtag.Zeitpunkt);

WITH CTE_Kundenstand AS (
  SELECT Artikel.ID AS ArtikelID, Standort.ID AS LagerID, COUNT(Teile.ID) AS AnzahlTeileKunden
  FROM Teile
  JOIN Artikel ON Teile.ArtikelID = Artikel.ID
  JOIN LagerArt ON Teile.LagerArtID = LagerArt.ID
  JOIN Standort ON LagerArt.LagerID = Standort.ID
  WHERE (Standort.SuchCode IN (N'WOLE', N'UKLU') OR Standort.ID < 0)
    AND (Teile.IndienstDat IS NULL OR Teile.IndienstDat < @Stichtag)
    AND (Teile.Ausdienst IS NULL OR Teile.AusdienstDat >= @Stichtag)
    AND Teile.Status >= N'L'
    AND Artikel.ID > 0
  GROUP BY Artikel.ID, Standort.ID
),
CTE_Lagerbewegung AS (
  SELECT Artikel.ID AS ArtikelID, Standort.ID AS LagerID, SUM(IIF(LagerBew.Differenz > 0, LagerBew.Differenz, 0)) AS Zugang, SUM(IIF(LagerBew.Differenz < 0, LagerBew.Differenz, 0)) AS Abgang
  FROM LagerBew
  JOIN Bestand ON LagerBew.BestandID = Bestand.ID
  JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
  JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
  JOIN LagerArt ON Bestand.LagerArtID = LagerArt.ID
  JOIN Standort ON LagerArt.LagerID = Standort.ID
  WHERE Standort.SuchCode IN (N'WOLE', N'UKLU')
    AND Artikel.ID > 0
    AND LagerBew.Zeitpunkt >= DATEADD(year, -1, @Stichtag)
    AND LagerBew.Zeitpunkt < @Stichtag
  GROUP BY Artikel.ID, Standort.ID
)
SELECT ArtikelNr, Artikelbezeichnung, [Lagerbestand Gesamt], [Bestand Neuware], [Bestand Gebrauchtware], Zugang, Abgang, [Teile bei Kunden], EKPreis, EKPreis * [Bestand Neuware] AS [Neuware Gesamt], Lagerstandort
FROM (
  SELECT BestandResult.ArtikelNr, BestandResult.Artikelbezeichnung, SUM(ISNULL(BestandResult.Bestand, 0)) AS [Lagerbestand Gesamt], SUM(IIF(ISNULL(BestandResult.Neuware, 0) = 1, ISNULL(BestandResult.Bestand, 0), 0)) AS [Bestand Neuware], SUM(IIF(ISNULL(BestandResult.Neuware, 0) = 0, ISNULL(BestandResult.Bestand, 0), 0)) AS [Bestand Gebrauchtware], CTE_Lagerbewegung.Zugang, CTE_Lagerbewegung.Abgang, ISNULL(CTE_Kundenstand.AnzahlTeileKunden, 0) AS [Teile bei Kunden], BestandResult.EKPreis, BestandResult.LagerStandort AS Lagerstandort
  FROM #TmpResultSet AS BestandResult
  LEFT OUTER JOIN CTE_Kundenstand ON BestandResult.ArtikelID = CTE_Kundenstand.ArtikelID AND BestandResult.LagerID = CTE_Kundenstand.LagerID
  LEFT OUTER JOIN CTE_Lagerbewegung ON BestandResult.ArtikelID = CTE_Lagerbewegung.ArtikelID AND BestandResult.LagerID = CTE_Lagerbewegung.LagerID
  WHERE (BestandResult.Bestand > 0 OR CTE_Kundenstand.AnzahlTeileKunden > 0)
  GROUP BY BestandResult.ArtikelNr, BestandResult.Artikelbezeichnung, CTE_Lagerbewegung.Zugang, CTE_Lagerbewegung.Abgang, BestandResult.EKPreis, BestandResult.LagerStandort, CTE_Kundenstand.AnzahlTeileKunden
) AS x
ORDER BY ArtikelNr, Lagerstandort;