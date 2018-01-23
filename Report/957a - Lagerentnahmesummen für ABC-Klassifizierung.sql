DECLARE @Zvon datetime;
DECLARE @Zbis datetime;

DROP TABLE IF EXISTS #TempLagerBew;
DROP TABLE IF EXISTS #TempBestand;

SET @Zvon = $1$;
SET @Zbis = DATEADD(day, 1, $2$);

SELECT LagerBew.BestandID, SUM(ABS(LagerBew.Differenz)) AS Entnahme
INTO #TempLagerBew
FROM LagerBew, LgBewCod
WHERE LagerBew.LgBewCodID = LgBewCod.ID
  AND (LgBewCod.Code = 'BUCH' OR LgBewCod.Code = 'DELB')
  AND LagerBew.Differenz < 0
  AND LagerBew.Zeitpunkt BETWEEN @Zvon AND @Zbis
GROUP BY LagerBew.BestandID;

SELECT LB.*, Bestand.ArtGroeID
INTO #TempBestand
FROM #TempLagerBew LB, Bestand, ArtGroe, Artikel
WHERE Bestand.ID = LB.BestandID
  AND ArtGroe.ID = Bestand.ArtGroeID
  AND Artikel.ID = ArtGroe.ArtikelID
  AND Artikel.ID > -1
  AND ArtGroe.ID > -1
  AND Artikel.ArtiTypeID = 1 --nur textile Artikel
  AND Artikel.BereichID IN ($3$);

SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, SUM(Entnahme) AS Entnahmemenge
FROM #TempBestand B, ArtGroe, Artikel
WHERE B.ArtGroeID = ArtGroe.ID
  AND ArtGroe.ArtikelID = Artikel.ID
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, ArtGroe.Groesse
ORDER BY Entnahmemenge DESC;