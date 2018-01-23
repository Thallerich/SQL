DECLARE @Stichtag TIMESTAMP;
DECLARE @BestandCalc INTEGER;
DECLARE @BestandST INTEGER;

DECLARE curBestand CURSOR;
DECLARE curLagerBew CURSOR;

@Stichtag = CONVERT('01.06.2016 00:00:00', SQL_TIMESTAMP);

TRY
  DROP TABLE #TmpLagerwert;
CATCH ALL END;

CREATE TABLE #TmpLagerwert (Lagerart NVARCHAR(60), ArtikelNr NVARCHAR(15), Artikelbezeichnung NVARCHAR(60), Groesse NVARCHAR(10), EKPreis MONEY, Buchungsmenge INTEGER, Zeitpunkt TIMESTAMP, BestandStichtag INTEGER);

OPEN curBestand AS
  SELECT Bestand.ID AS BestandID, LagerArt.LagerArtBez$LAN$ AS LagerArt
  FROM Bestand, LagerArt
  WHERE Bestand.LagerArtID = LagerArt.ID
    AND LagerArt.LagerID = 5001
    AND LagerArt.Neuwertig = $TRUE$;

WHILE FETCH curBestand DO
  @BestandST = (SELECT TOP 1 IFNULL(LagerBew.BestandNeu, 0) FROM LagerBew WHERE LagerBew.BestandID = curBestand.BestandID AND LagerBew.Zeitpunkt < @Stichtag ORDER BY LagerBew.Zeitpunkt DESC);
  @BestandCalc = @BestandST;

  OPEN curLagerBew AS
    SELECT LagerArt.LagerArtBez$LAN$ AS Lagerart, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, IIF(LagerBew.BestandNeu = 0, LagerBew.EPreis, LagerBew.GleitPreis) AS EPreis, LagerBew.Differenz, LagerBew.Zeitpunkt, @BestandST AS BestandStichtag
    FROM LagerBew, Bestand, ArtGroe, Artikel, LagerArt
    WHERE LagerBew.BestandID = Bestand.ID
      AND Bestand.ArtGroeID = ArtGroe.ID
      AND ArtGroe.ArtikelID = Artikel.ID
      AND Bestand.LagerArtID = LagerArt.ID
      AND LagerBew.BestandID = curBestand.BestandID
      AND LagerBew.Zeitpunkt < @Stichtag
      AND LagerBew.Differenz > 0
    ORDER BY LagerBew.Zeitpunkt DESC;

  WHILE FETCH curLagerBew DO
    IF @BestandCalc - curLagerBew.Differenz >= 0 THEN
      INSERT INTO #TmpLagerWert VALUES (curLagerBew.Lagerart, curLagerBew.ArtikelNr, curLagerBew.Artikelbezeichnung, curLagerBew.Groesse, curLagerBew.EPreis, curLagerBew.Differenz, curLagerBew.Zeitpunkt, curLagerBew.BestandStichtag);
      @BestandCalc = @BestandCalc - curLagerBew.Differenz;
    END IF;

    IF (@BestandCalc - curLagerBew.Differenz < 0 AND @BestandCalc > 0) THEN
      INSERT INTO #TmpLagerWert VALUES (curLagerBew.Lagerart, curLagerBew.ArtikelNr, curLagerBew.Artikelbezeichnung, curLagerBew.Groesse, curLagerBew.EPreis, (curLagerBew.Differenz + (@BestandCalc - curLagerBew.Differenz)), curLagerBew.Zeitpunkt, curLagerBew.BestandStichtag);
      @BestandCalc = @BestandCalc - curLagerBew.Differenz;
    END IF;
  END WHILE;

  CLOSE curLagerBew;
END WHILE;

CLOSE curBestand;

SELECT Lagerart, ArtikelNr, Artikelbezeichnung, Groesse, EKPreis, BestandStichtag AS [Bestand 30.06.2016], Zeitpunkt AS Buchungszeitpunkt, Buchungsmenge AS [Stück], Buchungsmenge * EKPreis AS Lagerwert
FROM #TmpLagerwert;