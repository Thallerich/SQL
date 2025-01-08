/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: prepareData                                                                                                     ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @Stichtag datetime = $1$;

DROP TABLE IF EXISTS #TmpResultSet;
DROP TABLE IF EXISTS #TmpBestandStichtag;

SELECT Artikel.ID AS ArtikelID, Bestand.ID AS BestandID, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,Artgru.ArtgruBez, ArtGroe.Groesse, 0 AS Bestand, LagerArt.Neuwertig AS Neuware , Lagerart.LagerartBez$LAN$, Artikel.EKPreis, CONVERT(datetime, NULL) AS Letzte_Bewegung, Standort.Bez AS LagerStandort, Bestand.Warenwert
INTO #TmpResultSet
FROM Artikel, ArtGroe, Bestand, LagerArt, Standort,Artgru
WHERE Bestand.ArtGroeID = ArtGroe.ID
  AND ArtGroe.ArtikelID = Artikel.ID
  AND Bestand.LagerArtID = LagerArt.ID
  AND LagerArt.LagerID = Standort.ID
  AND Artikel.ArtgruID = Artgru.ID
  AND Standort.ID IN ($2$);

SELECT LagerBew.BestandID, MAX(LagerBew.Zeitpunkt) as Zeitpunkt,MAX(LagerBew.ID) as MaxLagerBew
into #TmpBestandStichtag
FROM LagerBew, Bestand, LagerArt
WHERE LagerBew.BestandID = Bestand.ID
  AND Bestand.LagerArtID = LagerArt.ID
  AND LagerArt.LagerID IN ($2$)
  AND LagerBew.Zeitpunkt <= @Stichtag
GROUP BY LagerBew.BestandID;

UPDATE ResultSet SET ResultSet.Bestand = LagerBew.BestandNeu, ResultSet.Letzte_Bewegung = BestandStichtag.Zeitpunkt, ResultSet.Warenwert = Lagerbew.WertNeu
FROM LagerBew, #TmpBestandStichtag BestandStichtag, #TmpResultSet ResultSet
WHERE ResultSet.BestandID = BestandStichtag.BestandID
  AND LagerBew.BestandID = BestandStichtag.BestandID
  AND LagerBew.id = BestandStichtag.MaxLagerBew;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: Lagerbestand                                                                                                    ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT ArtikelNr, Artikelbezeichnung,ArtgruBez,Groesse,SUM(Bestand) AS Bestand, Neuware, EKPreis, sum(Warenwert) as Wert, MAX(Letzte_Bewegung) AS Letzte_Bewegung, LagerStandort, LagerartBez$LAN$, (sum(Warenwert) / SUM(Bestand)) as GLD
FROM #TmpResultSet
WHERE Bestand > 0
GROUP BY ArtikelNr, Artikelbezeichnung,ArtgruBez,Groesse, Neuware, EKPreis, LagerStandort, LagerartBez$LAN$
ORDER BY ArtikelNr, Groesse, Neuware, LagerStandort;