DECLARE @MinLagerBewID int = (SELECT CAST(ValueMemo AS int) FROM Settings WHERE Parameter = 'LAST_LAGERBEWID_TO_SAP');

TRUNCATE TABLE __LagerBewHW;

INSERT INTO __LagerBewHW (ID, Zeitpunkt, ArtikelNr, ArtikelBez, SuchCode, Differenz, Groesse, BestandID, LgBewCodBez)
SELECT LagerBew.ID, LagerBew.Zeitpunkt, Artikel.ArtikelNr, Artikel.ArtikelBez, Standort.SuchCode, LagerBew.Differenz, ArtGroe.Groesse, Bestand.ID BestandID, LgBewCodBez
FROM LagerBew, Bestand, ArtGroe, Artikel, LagerArt, Standort, LgBewCod
WHERE LagerBew.BestandID = Bestand.ID
  AND Bestand.ArtGroeID = ArtGroe.ID
  AND ArtGroe.ArtikelID = Artikel.ID
  AND Bestand.LagerArtID = LagerArt.ID
  AND LagerArt.LagerID = Standort.ID
  AND LagerBew.LgBewCodID = LgBewCod.ID
  AND Standort.FirmaID = 5260
  AND Standort.SuchCode != N'SMZL'
  AND LagerBew.ID > @MinLagerBewID;