SELECT OpTeile.Code AS Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, Artikel.EKPreis, OpTeile.ErstWoche, OpTeile.WegDatum, WegGrund.WegGrundBez$LAN$ AS WegGrund, OpTeile.AnzSteril, OpTeile.AnzWasch, OpTeile.AnzImpregnier
FROM OpTeile, Vsa, Kunden, Artikel, WegGrund
WHERE OpTeile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.KdGfID IN ($4$)
  AND OpTeile.ArtikelID = Artikel.ID
  AND OpTeile.WegGrundID = WegGrund.ID
  AND OpTeile.WegGrundID IN ($3$)
  AND OpTeile.WegDatum BETWEEN $1$ AND $2$
ORDER BY Artikel.ArtikelBez$LAN$, OpTeile.WegDatum ASC;