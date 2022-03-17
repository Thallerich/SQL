SELECT Standort.SuchCode AS Lagerstandort, Lagerart.LagerartBez$LAN$ AS Lagerart, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, LagerBew.Zeitpunkt AS [Zeitpunkt Inventurbuchung], LagerBew.BestandNeu + LagerBew.Differenz AS [Bestand vor Inventur], LagerBew.BestandNeu AS [Bestand nach Inventur], LagerBew.Differenz
FROM LagerBew
JOIN Bestand ON LagerBew.BestandID = Bestand.ID
JOIN Lagerart ON Bestand.LagerArtID = Lagerart.ID
JOIN Standort ON Lagerart.LagerID = Standort.ID
JOIN ArtGroe ON Bestand.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN GroePo ON Artikel.GroeKoID = GroePo.GroeKoID AND ArtGroe.Groesse = GroePo.Groesse
JOIN LgBewCod ON LagerBew.LgBewCodID = LgBewCod.ID
WHERE LgBewCod.Code IN (N'INV', N'DINV')
  AND LagerBew.Zeitpunkt BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Lagerart.ID IN ($3$)
  AND (($4$ = 1 AND LagerBew.Differenz != 0) OR $4$ = 0)
  AND (($5$ = 1 AND (LagerBew.BestandNeu != 0 OR LagerBew.Differenz != 0)) OR $5$ = 0)
ORDER BY Lagerstandort, Lagerart, ArtikelNr, GroePo.Folge;