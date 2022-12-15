DECLARE @MinLagerBewID int = (SELECT CAST(ValueMemo AS int) FROM Settings WHERE Parameter = 'LAST_LAGERBEWID_TO_SAP');

TRUNCATE TABLE __LagerBewHW;

INSERT INTO __LagerBewHW (ID, Zeitpunkt, ArtikelNr, ArtikelBez, SuchCode, Differenz, Groesse, BestandID, LgBewCodBez)
SELECT LagerBew.ID, LagerBew.Zeitpunkt, Artikel.ArtikelNr, Artikel.ArtikelBez, Standort.SuchCode, LagerBew.Differenz, ArtGroe.Groesse, Bestand.ID BestandID, LgBewCod.LgBewCodBez
FROM LagerBew, Bestand, ArtGroe, Artikel, Bereich, LagerArt, Standort, LgBewCod, Firma
WHERE LagerBew.BestandID = Bestand.ID
  AND Bestand.ArtGroeID = ArtGroe.ID
  AND ArtGroe.ArtikelID = Artikel.ID
  AND Artikel.BereichID = Bereich.ID
  AND Bestand.LagerArtID = LagerArt.ID
  AND LagerArt.LagerID = Standort.ID
  AND LagerBew.LgBewCodID = LgBewCod.ID
  AND Lagerart.FirmaID = Firma.ID
  AND LagerArt.BestandZu = 0
  AND Standort.SuchCode IN (N'SMZL', N'BUDA')
  AND Lagerart.ArtiTypeID IN (1, 3) /* Textile Artikel und Eblem-Artikel */
  AND Lagerart.Neuwertig = 1
  AND LgBewCod.Code != N'IN??'
  AND LagerBew.Differenz != 0
  AND LagerBew.ID > @MinLagerBewID;