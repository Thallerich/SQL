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
  AND (Firma.SuchCode = N'FA14' OR Firma.SuchCode = N'BUDA')
  AND (LagerArt.ArtiTypeID = 1 OR (Lagerart.ArtiTypeID = 3 AND (Standort.SuchCode = N'SMZL' OR Firma.SuchCode = N'BUDA')))  /* alle Bewegungen zu textilen Artikeln, sowie Bewegungen zu Emblem-Artikeln wenn der Lagerstandort SMZL ist oder das Lager zur Firma BUDA gehört */
  AND ((Bereich.Bereich = N'HW' AND (Standort.SuchCode = N'SMZL' OR Firma.SuchCode = N'BUDA')) OR Bereich.Bereich != N'HW') /* Bewegungen zu Artikeln aus dem Bereich Handelsware nur wenn der Lagerstandort SMZL ist oder die Firma BUDA ist. Handelswaren-Bewegungen aus den Betriebslägern nicht übertragen */
  AND LgBewCod.Code != N'IN??'
  AND LagerBew.Differenz != 0
  AND LagerBew.ID > @MinLagerBewID;