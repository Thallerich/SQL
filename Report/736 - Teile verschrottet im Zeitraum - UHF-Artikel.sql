SELECT KdGf.KurzBez AS SGF, OpTeile.Code AS Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Artikel.EKPreis, OpTeile.ErstWoche, OpTeile.WegDatum, WegGrund.WegGrundBez$LAN$ AS WegGrund, OpTeile.AnzWasch AS [Anzahl Wäschen], Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung]
FROM OpTeile, Vsa, Kunden, KdGf, Artikel, WegGrund
WHERE OpTeile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.KdGfID = KdGf.ID
  AND Kunden.KdGfID IN ($2$)
  AND Kunden.StandortID IN ($1$)
  AND OpTeile.ArtikelID = Artikel.ID
  AND Artikel.EAN IS NOT NULL --nur UHF-Artikel
  AND OpTeile.WegGrundID = WegGrund.ID
  AND OpTeile.WegGrundID IN ($3$)
  AND OpTeile.WegDatum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
ORDER BY Artikel.ArtikelBez, OpTeile.WegDatum ASC;