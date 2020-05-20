DECLARE @MinLagerBewID INTEGER;
DECLARE @MaxLagerBewID INTEGER;

SET @MinLagerBewID = (SELECT CAST(ValueMemo AS INTEGER) + 1 FROM Settings WHERE Parameter = 'LAST_LAGERBEWID_TO_SAP');
SET @MaxLagerBewID = (SELECT MAX(ID) FROM LagerBew);

TRUNCATE TABLE __LagerBewHW;

IF (@MaxLagerBewID >= @MinLagerBewID) BEGIN 
  INSERT INTO __LagerBewHW (ID, Zeitpunkt, ArtikelNr, ArtikelBez, SuchCode, Differenz, Groesse, BestandID, LgBewCodBez)
  SELECT LagerBew.ID, LagerBew.Zeitpunkt, Artikel.ArtikelNr, Artikel.ArtikelBez, Standort.SuchCode, LagerBew.Differenz, ArtGroe.Groesse, Bestand.ID BestandID, LgBewCodBez
  FROM LagerBew, Bestand, ArtGroe, Artikel, LagerArt, Standort, LgBewCod
  WHERE LagerBew.BestandID = Bestand.ID
    AND Bestand.ArtGroeID = ArtGroe.ID
    AND ArtGroe.ArtikelID = Artikel.ID
    AND Bestand.LagerArtID = LagerArt.ID
    AND LagerArt.LagerID = Standort.ID
    AND LagerBew.LgBewCodID = LgBewCod.ID
    AND Standort.SuchCode IN ('MATT','LEOG','SMS','ARNO','SCHI','GRAZ')
    AND LagerBew.ID BETWEEN @MinLagerBewID AND @MaxLagerBewID;
END;