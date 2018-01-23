SELECT Artikel.ArtikelNr, Langbez.Bez AS Bezeichnung, SUM(VsaAnf.Normmenge) AS Summe_Normmenge
FROM VsaAnf, Artikel, Langbez, Vsa, VsaBer, KdBer, KdArti
WHERE Vsa.StandKonID = 55
	AND VsaAnf.VsaID = Vsa.ID
	AND KdBer.BereichID = 103
	AND VsaBer.KdBerID = KdBer.ID
	AND VsaBer.VsaID = Vsa.ID
	AND VsaBer.Status = 'A'
	AND VsaAnf.Art = 'N'
	AND Vsa.Status = 'A'
	AND VsaAnf.KdArtiID = KdArti.ID
	AND KdArti.ArtikelID = Artikel.ID
	AND Langbez.TableName = 'ARTIKEL'
	AND Langbez.TableID = Artikel.ID
	AND Langbez.LanguageID = -1
	AND VsaAnf.NormMenge > 0
GROUP BY ArtikelNr, Bezeichnung