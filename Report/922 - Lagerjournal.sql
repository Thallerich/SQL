DECLARE @von datetime = $2$;
DECLARE @bis datetime = DATEADD(day, 1, $3$);

SELECT CAST(LagerBew.Zeitpunkt AS date) AS Datum, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, SUM(LagerBew.Differenz) AS [Stückzahl (Entnahmen + Zugänge)], Lagerort.Lagerort, LagerArt.LagerArtBez$LAN$ AS Lagerart, Mitarbei.Name AS Benutzer
FROM LagerBew
JOIN Bestand ON LagerBew.BestandID = Bestand.ID
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Lagerort ON LagerBew.LagerOrtID = Lagerort.ID
JOIN Mitarbei ON LagerBew.BenutzerID = Mitarbei.ID
JOIN LagerArt ON Bestand.LagerArtID = LagerArt.ID
WHERE LagerBew.Zeitpunkt BETWEEN @von AND @bis
  AND LagerArt.LagerID = $1$
GROUP BY CAST(LagerBew.Zeitpunkt AS date), Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, ArtGroe.Groesse, Lagerort.Lagerort, LagerArt.LagerArtBez$LAN$, Mitarbei.Name;