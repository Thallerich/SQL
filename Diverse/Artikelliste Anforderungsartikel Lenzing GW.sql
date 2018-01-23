SELECT Kunden.KdNr, Kunden.SuchCode, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez, VsaAnf.Status
FROM VsaAnf, Vsa, Kunden, KdArti, ViewArtikel Artikel, KdGf, StandKon, StandBer, Standort
WHERE VsaAnf.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Kunden.KdGfID = KdGf.ID
	AND VsaAnf.KdArtiID = KdArti.ID
	AND KdArti.ArtikelID = Artikel.ID
	AND Vsa.StandKonID = StandKon.ID
	AND StandBer.StandKonID = StandKon.ID
	AND StandBer.ExpeditionID = Standort.ID
	AND Artikel.BereichID = StandBer.BereichID
	AND KdGf.KurzBez = 'GW'
	AND Standort.ID = 1
	AND VsaAnf.Status = 'A';