-----------------
--
--Artikelnummer, Anzahl der auf Lager befindlichen Teile, Neuware oder gebraucht (je Artikelnummer ev. 2 Zeilen falls Neu und gebraucht eingelagert sind), Einkaufspreis, Einlagerdatum.
--Auswählbar sein soll ein Stichtag, um Lagerstände zu vergleichen.
--
-----------------

DECLARE @Stichtag TIMESTAMP;

TRY
	DROP TABLE #TmpResultSet;
	DROP TABLE #TmpBestandStichtag;
CATCH ALL END;

@Stichtag = CONVERT($1$ + ' 00:00:00', SQL_TIMESTAMP);

SELECT Artikel.ID AS ArtikelID, Bestand.ID AS BestandID, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse, 0 AS Bestand, LagerArt.Neuwertig AS Neuware, Artikel.EKPreis, CONVERT(NULL, SQL_TIMESTAMP) AS Letzte_Bewegung, Standort.SuchCode AS LagerStandort
INTO #TmpResultSet
FROM ViewArtikel Artikel, ArtGroe, Bestand, LagerArt, Standort
WHERE Bestand.ArtGroeID = ArtGroe.ID
	AND ArtGroe.ArtikelID = Artikel.ID
	AND Bestand.LagerArtID = LagerArt.ID
	AND LagerArt.LagerID = Standort.ID
	AND Artikel.LanguageID = $LANGUAGE$;
	
SELECT LagerBew.BestandID, MAX(LagerBew.Zeitpunkt) AS Zeitpunkt
INTO #TmpBestandStichtag
FROM LagerBew, Bestand
WHERE LagerBew.BestandID = Bestand.ID
	AND LagerBew.Zeitpunkt < @Stichtag
GROUP BY LagerBew.BestandID;

UPDATE ResultSet
SET ResultSet.Bestand = LagerBew.BestandNeu, ResultSet.Letzte_Bewegung = BestandStichtag.Zeitpunkt
FROM LagerBew, #TmpBestandStichtag BestandStichtag, #TmpResultSet ResultSet
WHERE ResultSet.BestandID = BestandStichtag.BestandID
	AND LagerBew.BestandID = BestandStichtag.BestandID
	AND LagerBew.Zeitpunkt = BestandStichtag.Zeitpunkt;
	
SELECT ArtikelNr, ArtikelBez, Groesse, SUM(Bestand) AS Bestand, Neuware, EKPreis, MAX(Letzte_Bewegung) AS Letzte_Bewegung, LagerStandort
FROM #TmpResultSet
WHERE Bestand > 0
GROUP BY ArtikelNr, ArtikelBez, Groesse, Neuware, EKPreis, LagerStandort
ORDER BY ArtikelNr, Groesse, Neuware, LagerStandort;