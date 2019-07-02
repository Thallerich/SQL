SELECT OPTeile.Code AS Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, Artikel.EKPreis, OPTeile.ErstWoche, OPTeile.WegDatum, WegGrund.WegGrundBez$LAN$ AS WegGrund, OPTeile.AnzSteril, OPTeile.AnzWasch, OPTeile.AnzImpregnier
FROM OPTeile, Vsa, Kunden, Artikel, WegGrund
WHERE OPTeile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.KdGfID IN ($5$)
  AND Kunden.FirmaID IN ($4$)
  AND OPTeile.ArtikelID = Artikel.ID
  AND OPTeile.WegGrundID = WegGrund.ID
  AND OPTeile.WegGrundID IN ($3$)
  AND OPTeile.WegDatum BETWEEN $1$ AND $2$
  AND Artikel.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = N'ST')
ORDER BY Artikel.ArtikelBez$LAN$, OPTeile.WegDatum ASC;