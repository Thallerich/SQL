SELECT Kunden.KdNr, Kunden.SuchCode, ViewArtikel.ArtikelNr, ViewArtikel.ArtikelBez, KdArti.LeasingPreis, KdArti.WaschPreis
FROM Kunden, ViewArtikel, KdArti
WHERE KdArti.ArtikelID = ViewArtikel.ID
	AND KdArti.KundenID = Kunden.ID
	AND ViewArtikel.LanguageID = $LANGUAGE$
	AND KdArti.LeasingPreis + KdArti.WaschPreis = 0
	AND KdArti.Status = 'A'
	AND Kunden.Status = 'A'
	AND Kunden.FirmaID = 5001 --Umlauft-Kunden
	AND Kunden.KdNr NOT IN (2500002) --Ausnahme-Liste Kunden
	AND ViewArtikel.BereichID <> 11
	AND ViewArtikel.ArtikelNr NOT IN ('N01', 'N02', 'N03', '122023', '122024', '122025', 'E002') --Ausnahme-Liste Artikel (z.B. Container, Namensschilder,...)
ORDER BY KdNr, ArtikelNr;