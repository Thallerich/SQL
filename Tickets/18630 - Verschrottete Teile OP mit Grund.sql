--Paramter Verschrottungsgründe OP:
SELECT ID, Bez
FROM WegGrund
WHERE OpSchrott = TRUE;


-- Ticket 18630:
SELECT OpTeile.Code AS Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez, OpTeile.ErstWoche, OpTeile.WegDatum, WegGrund.Bez AS WegGrund, OpTeile.AnzSteril, OpTeile.AnzWasch, OpTeile.AnzImpregnier, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Kunden.KdNr, Kunden.SuchCode
FROM OpTeile, Vsa, Kunden, ViewArtikel Artikel, WegGrund
WHERE OpTeile.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND OpTeile.ArtikelID = Artikel.ID
	AND OpTeile.WegGrundID = WegGrund.ID
	AND OpTeile.WegGrundID IN ($3$)
	AND OpTeile.WegDatum BETWEEN $1$ AND $2$
	AND Artikel.LanguageID = $LANGUAGE$
ORDER BY OpTeile.WegDatum ASC;