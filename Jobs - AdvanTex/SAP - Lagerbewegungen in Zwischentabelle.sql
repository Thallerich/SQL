TRUNCATE TABLE __LagerBewHW;
DROP TABLE IF EXISTS #LagerBewSAP;

DECLARE @MinLagerBewID bigint = (SELECT CAST(ValueMemo AS bigint) FROM Settings WHERE Parameter = 'LAST_LAGERBEWID_TO_SAP');

/* Performance Tuning - Lagerbewegungen zuerst in Temp-Table laden - Folge-Query läuft damit wesentlich performanter */
SELECT LagerBew.ID, LagerBew.Zeitpunkt, LagerBew.Differenz, LagerBew.BestandID, LagerBew.LgBewCodID
INTO #LagerBewSAP
FROM LagerBew
WHERE LagerBew.ID > @MinLagerBewID
  AND LagerBew.Differenz != 0;

INSERT INTO __LagerBewHW (ID, Zeitpunkt, ArtikelNr, ArtikelBez, SuchCode, Differenz, Groesse, BestandID, LgBewCodBez)
SELECT #LagerBewSAP.ID, #LagerBewSAP.Zeitpunkt, Artikel.ArtikelNr, Artikel.ArtikelBez, Standort.SuchCode, #LagerBewSAP.Differenz, ArtGroe.Groesse, Bestand.ID BestandID, LgBewCod.LgBewCodBez
FROM #LagerBewSAP, Bestand, ArtGroe, Artikel, Bereich, LagerArt, Standort, LgBewCod, Firma
WHERE #LagerBewSAP.BestandID = Bestand.ID
  AND Bestand.ArtGroeID = ArtGroe.ID
  AND ArtGroe.ArtikelID = Artikel.ID
  AND Artikel.BereichID = Bereich.ID
  AND Bestand.LagerArtID = LagerArt.ID
  AND LagerArt.LagerID = Standort.ID
  AND #LagerBewSAP.LgBewCodID = LgBewCod.ID
  AND Lagerart.FirmaID = Firma.ID
  AND LagerArt.BestandZu = 0
  AND Standort.SuchCode IN (N'SMZL', N'BUDA')
  AND Lagerart.ArtiTypeID IN (1, 3, 2) /* Textile Artikel und Eblem-Artikel */
  AND Lagerart.Neuwertig = 1
  AND LgBewCod.Code NOT IN (N'IN??', N'WKOR', N'SYS2');

DROP TABLE IF EXISTS #LagerBewSAP;