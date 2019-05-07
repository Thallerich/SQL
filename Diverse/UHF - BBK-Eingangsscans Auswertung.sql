WITH BBKScans AS (
  SELECT OPScans.OPTeileID, OPScans.Zeitpunkt, OPScans.EingAnfPoID
  FROM OPScans
  WHERE OPScans.ZielNrID = 202
)
SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, CAST(BBKScans.Zeitpunkt AS date) AS Scandatum, COUNT(DISTINCT BBKScans.OPTeileID) AS [Anzahl Teile gescannt], SUM(IIF(BBKScans.EingAnfPoID > 0, 1, 0)) AS [Anzahl Teile für Anforderung]
FROM BBKScans
JOIN OPTeile ON BBKScans.OPTeileID = OPTeile.ID
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez, CAST(BBKScans.Zeitpunkt AS date);