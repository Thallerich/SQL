DECLARE @von datetime;
DECLARE @bis datetime;

SET @von = $1$;
SET @bis = DATEADD(day, 1, $2$);

SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, Lief.LiefNr AS LieferantenNr, Lief.SuchCode AS Lieferant, Standort.Bez AS Lagerstandort, LagerArt.LagerArtBez$LAN$ AS Lagerart, CONVERT(char(4), DATEPART(year, LagerBew.Zeitpunkt)) + '/' + IIF(DATEPART(week, LagerBew.Zeitpunkt) < 10, '0' + CONVERT(char(1), DATEPART(week, LagerBew.Zeitpunkt)), CONVERT(char(2), DATEPART(week, LagerBew.Zeitpunkt))) AS Woche, ABS(SUM(LagerBew.Differenz)) AS Entnahmemenge
FROM Bestand, ArtGroe, Artikel, Lief, LagerArt, Standort, LagerBew, LgBewCod
WHERE Bestand.ArtGroeID = ArtGroe.ID
  AND ArtGroe.ArtikelID = Artikel.ID
  AND Artikel.LiefID = Lief.ID
  AND Bestand.LagerArtID = LagerArt.ID
  AND LagerArt.LagerID = Standort.ID
  AND LagerBew.BestandID = Bestand.ID
  AND LagerBew.LgBewCodID = LgBewCod.ID
  AND LgBewCod.Code = 'BUCH' --nur Entnahmen
  AND Standort.ID IN ($3$)
  AND LagerBew.Zeitpunkt BETWEEN @von AND @bis
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, ArtGroe.Groesse, Lief.LiefNr, Lief.SuchCode, Standort.Bez, LagerArt.LagerArtBez$LAN$, CONVERT(char(4), DATEPART(year, LagerBew.Zeitpunkt)) + '/' + IIF(DATEPART(week, LagerBew.Zeitpunkt) < 10, '0' + CONVERT(char(1), DATEPART(week, LagerBew.Zeitpunkt)), CONVERT(char(2), DATEPART(week, LagerBew.Zeitpunkt)))
ORDER BY Lagerstandort, Lagerart, Artikel.ArtikelNr, Woche;