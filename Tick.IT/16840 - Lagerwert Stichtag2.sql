DECLARE @Stichtag TIMESTAMP;

TRY
  DROP TABLE #TmpLagerwert;
  DROP TABLE #TmpBestandStichtag;
CATCH ALL END;

@Stichtag = CONVERT('01.05.2016 00:00:00', SQL_TIMESTAMP);

SELECT Artikel.ID AS ArtikelID, Bestand.ID AS BestandID, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, 0 AS Bestand, LagerArt.Neuwertig AS Neuware, Artikel.EKPreis, CONVERT(NULL, SQL_TIMESTAMP) AS LetzteBewegung, LagerArt.LagerArtBez$LAN$ AS Lagerart, CONVERT(0, SQL_MONEY) AS GleitPreis
INTO #TmpLagerwert
FROM Artikel, ArtGroe, Bestand, LagerArt
WHERE Bestand.ArtGroeID = ArtGroe.ID
  AND ArtGroe.ArtikelID = Artikel.ID
  AND Bestand.LagerArtID = LagerArt.ID
  AND LagerArt.LagerID = 5001
  AND LagerArt.Neuwertig = $TRUE$
  AND ArtikelID > 0;

SELECT LagerBew.BestandID, MAX(LagerBew.Zeitpunkt) AS Zeitpunkt
INTO #TmpBestandStichtag
FROM LagerBew, Bestand
WHERE LagerBew.BestandID = Bestand.ID
  AND LagerBew.Zeitpunkt < @Stichtag
  AND LagerBew.BestandID IN (SELECT BestandID FROM #TmpLagerwert)
GROUP BY LagerBew.BestandID;

UPDATE Lagerwert
SET Lagerwert.Bestand = LagerBew.BestandNeu, Lagerwert.LetzteBewegung = BestandStichtag.Zeitpunkt, Lagerwert.GleitPreis = IIF(LagerBew.BestandNeu = 0, LagerBew.EPreis, LagerBew.GleitPreis)
FROM LagerBew, #TmpBestandStichtag BestandStichtag, #TmpLagerwert Lagerwert
WHERE Lagerwert.BestandID = BestandStichtag.BestandID
  AND LagerBew.BestandID = BestandStichtag.BestandID
  AND LagerBew.Zeitpunkt = BestandStichtag.Zeitpunkt;

SELECT Lagerart, ArtikelNr, Artikelbezeichnung, Groesse, EKPreis, Bestand AS [Bestand 30.06.2016], LetzteBewegung AS [Letzte Bewegung vor Stichtag], Bestand * GleitPreis AS Lagerwert
FROM #TmpLagerwert
WHERE Bestand <> 0;