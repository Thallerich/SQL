SELECT OPTeile.Code AS Barcode, OPTMess.Datum, Standort.Bez AS Produktion, WaschMa.Bez AS Waschmaschine, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, OPTMess.Flaechenmessung AS Fläche, OPTMess.Nahtmessung AS Naht, OPTMess.Info, OPTeile.AnzWasch AS Wäschen
FROM OPTMess
JOIN OPTeile ON OPTMess.OPTeileID = OPTeile.ID
JOIN ArtGroe ON OPTeile.ArtGroeID = ArtGroe.ID
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
JOIN WaschMa ON OPTMess.WaschMaID = WaschMa.ID
JOIN Standort ON WaschMa.StandortID = Standort.ID
WHERE OPTMess.Datum BETWEEN $1$ AND $2$
  AND Standort.ID IN ($3$)
ORDER BY Datum ASC;