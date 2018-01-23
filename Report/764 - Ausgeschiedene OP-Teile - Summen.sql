SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, WegGrund.WegGrundBez$LAN$ AS WegGrund, COUNT(OPTeile.ID) AS AnzahlAusgeschieden
FROM OPTeile, WegGrund, Artikel, Vsa, Kunden
WHERE OPTeile.WegGrundID = WegGrund.ID
	AND OPTeile.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND OPTeile.ArtikelID = Artikel.ID
	AND OPTeile.WegGrundID > 0
	AND OPTeile.WegDatum BETWEEN $2$ AND $3$
	AND Vsa.StandKonID IN ($1$)
	AND Kunden.SichtbarID IN ($SICHTBARIDS$)
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, WegGrund.WegGrundBez$LAN$
ORDER BY Artikel.ArtikelNr, WegGrund;