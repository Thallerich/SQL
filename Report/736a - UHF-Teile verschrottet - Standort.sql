SELECT Standort.Bez AS Produktionsstandort, Artikel.ArtikelNr, Artikel.ArtikelNr2 AS [BMD-ArtikelNr], Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Artikel.EKPreis, WegGrund.WegGrundBez$LAN$ AS Schrottgrund, COUNT(OPTeile.ID) AS Menge, (SUM(OPTeile.AnzWasch) / COUNT(OPTeile.ID)) AS [Durchschnitt Waschzyklen]
FROM OPTeile, ZielNr, Standort, Artikel, WegGrund
WHERE OPTeile.ZielNrID = ZielNr.ID
  AND ZielNr.ProduktionsID = Standort.ID
  AND Standort.ID IN ($4$)
  AND ZielNr.GeraeteNr IS NOT NULL
  AND OPTeile.ArtikelID = Artikel.ID
  AND Artikel.EAN IS NOT NULL --nur UHF-Artikel
  AND OPTeile.WegGrundID = WegGrund.ID
  AND OPTeile.WegGrundID IN ($3$)
  AND OPTeile.WegDatum BETWEEN $1$ AND $2$
  AND OPTeile.Status = 'Z'
GROUP BY Standort.Bez, Artikel.ArtikelNr, ARtikel.ArtikelNr2, Artikel.ArtikelBez$LAN$, Artikel.EKPreis, WegGrund.WegGrundBez$LAN$
ORDER BY Produktionsstandort, Artikelbezeichnung;