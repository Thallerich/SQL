DECLARE @MinLagerBewID int = (SELECT CAST(ValueMemo AS int) FROM Settings WHERE Parameter = 'LAST_LAGERBEWID_TO_SAP');

TRUNCATE TABLE __LagerBewHW;

INSERT INTO __LagerBewHW (ID, Zeitpunkt, ArtikelNr, ArtikelBez, SuchCode, Differenz, Groesse, BestandID, LgBewCodBez)
SELECT LagerBew.ID, LagerBew.Zeitpunkt, Artikel.ArtikelNr, Artikel.ArtikelBez, Standort.SuchCode, LagerBew.Differenz, ArtGroe.Groesse, Bestand.ID BestandID, LgBewCodBez
FROM LagerBew, Bestand, ArtGroe, Artikel, LagerArt, Standort, LgBewCod, Firma
WHERE LagerBew.BestandID = Bestand.ID
  AND Bestand.ArtGroeID = ArtGroe.ID
  AND ArtGroe.ArtikelID = Artikel.ID
  AND Bestand.LagerArtID = LagerArt.ID
  AND LagerArt.LagerID = Standort.ID
  AND LagerArt.ArtiTypeID = 1
  AND LagerBew.LgBewCodID = LgBewCod.ID
  AND Lagerart.FirmaID = Firma.ID
  AND (Firma.SuchCode = N'FA14' OR Firma.SuchCode = N'BUDA')
  AND ((DB_NAME() = N'Salesianer' AND Standort.SuchCode != N'SMZL') OR (DB_NAME() != N'Salesianer'))
  AND LagerBew.ID > @MinLagerBewID;