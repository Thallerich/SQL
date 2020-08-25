SELECT Produktion.Bez AS [Produktions-Standort], Artikel.ArtikelNr AS Artikelnummer, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, COUNT(DISTINCT OPTeile.ID) AS [Anzahl eingelesen]
FROM OPScans
JOIN ZielNr ON OPScans.ZielNrID = ZielNr.ID
JOIN Standort AS Produktion ON ZielNr.ProduktionsID = Produktion.ID
JOIN OPTeile ON OPScans.OPTeileID = OPTeile.ID
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
WHERE ZielNr.GeraeteNr IS NOT NULL
  AND OPScans.Zeitpunkt BETWEEN $STARTDATE$ AND DATEADD(day, 1, $ENDDATE$)
  AND OPScans.Menge = 1
  AND Produktion.ID IN ($1$)
GROUP BY Produktion.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$;