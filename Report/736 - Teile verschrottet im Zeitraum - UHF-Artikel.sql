SELECT KdGf.KurzBez AS SGF, OpTeile.Code AS Barcode, Artikel.ArtikelNr, Artikel.ArtikelNr2 AS [BMD-ArtikelNr], Artikel.ArtikelBez$LAN$ AS ArtikelBez, Artikel.EKPreis, OpTeile.ErstWoche, OpTeile.WegDatum, WegGrund.WegGrundBez$LAN$ AS WegGrund, OpTeile.AnzWasch
FROM OpTeile, Vsa, Kunden, KdGf, Artikel, WegGrund
WHERE OpTeile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.KdGfID = KdGf.ID
  AND Kunden.KdGfID IN ($4$)
  AND OpTeile.ArtikelID = Artikel.ID
  AND Artikel.EAN IS NOT NULL --nur UHF-Artikel
  AND OpTeile.WegGrundID = WegGrund.ID
  AND OpTeile.WegGrundID IN ($3$)
  AND OpTeile.WegDatum BETWEEN $1$ AND $2$
ORDER BY Artikel.ArtikelBez, OpTeile.WegDatum ASC;