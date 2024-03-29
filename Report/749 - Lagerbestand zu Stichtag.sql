DECLARE @Stichtag datetime = $1$;

DROP TABLE IF EXISTS #TmpResultSet;
DROP TABLE IF EXISTS #TmpBestandStichtag;

SELECT Artikel.ID AS ArtikelID, Bestand.ID AS BestandID, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, 0 AS Bestand, LagerArt.Neuwertig AS Neuware, Artikel.EKPreis, CONVERT(datetime, NULL) AS Letzte_Bewegung, Standort.Bez AS LagerStandort
INTO #TmpResultSet
FROM Artikel, ArtGroe, Bestand, LagerArt, Standort
WHERE Bestand.ArtGroeID = ArtGroe.ID
  AND ArtGroe.ArtikelID = Artikel.ID
  AND Bestand.LagerArtID = LagerArt.ID
  AND LagerArt.LagerID = Standort.ID
  AND Standort.ID IN ($2$);

SELECT LagerBew.BestandID, MAX(LagerBew.Zeitpunkt) AS Zeitpunkt
INTO #TmpBestandStichtag
FROM LagerBew, Bestand, LagerArt
WHERE LagerBew.BestandID = Bestand.ID
  AND Bestand.LagerArtID = LagerArt.ID
  AND LagerArt.LagerID IN ($2$)
  AND LagerBew.Zeitpunkt < @Stichtag
GROUP BY LagerBew.BestandID;

UPDATE ResultSet SET ResultSet.Bestand = LagerBew.BestandNeu, ResultSet.Letzte_Bewegung = BestandStichtag.Zeitpunkt
FROM LagerBew, #TmpBestandStichtag BestandStichtag, #TmpResultSet ResultSet
WHERE ResultSet.BestandID = BestandStichtag.BestandID
  AND LagerBew.BestandID = BestandStichtag.BestandID
  AND LagerBew.Zeitpunkt = BestandStichtag.Zeitpunkt;

SELECT ArtikelNr, Artikelbezeichnung, Groesse, SUM(Bestand) AS Bestand, Neuware, EKPreis, MAX(Letzte_Bewegung) AS Letzte_Bewegung, LagerStandort
FROM #TmpResultSet
WHERE Bestand > 0
GROUP BY ArtikelNr, Artikelbezeichnung, Groesse, Neuware, EKPreis, LagerStandort
ORDER BY ArtikelNr, Groesse, Neuware, LagerStandort;