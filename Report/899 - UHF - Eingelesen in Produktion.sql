SELECT Produktion.Bez AS [Produktions-Standort], Artikel.ArtikelNr AS Artikelnummer, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, COUNT(DISTINCT EinzTeil.ID) AS [Anzahl eingelesen]
FROM Scans
JOIN ZielNr ON Scans.ZielNrID = ZielNr.ID
JOIN Standort AS Produktion ON ZielNr.ProduktionsID = Produktion.ID
JOIN EinzTeil ON Scans.EinzTeilID = EinzTeil.ID
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
WHERE ZielNr.GeraeteNr IS NOT NULL
  AND Scans.[DateTime] BETWEEN $STARTDATE$ AND DATEADD(day, 1, $ENDDATE$)
  AND Scans.Menge = 1
  AND Scans.EinzTeilID > 0
  AND Produktion.ID IN ($1$)
GROUP BY Produktion.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$;