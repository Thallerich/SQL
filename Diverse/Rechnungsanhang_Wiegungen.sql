SELECT RKo.RechNr, RKo.RechDat, LsKo.LsNr, Artikel.ArtikelNr, Langbez.Bez AS Artikel, Wiegung.Zeitpunkt, Wiegung.IdentNr, Wiegung.Brutto, Wiegung.Tara, Wiegung.Netto
FROM Wiegung, LsKo, LsPo, KdArti, Artikel, Langbez, RPo, RKo
WHERE Wiegung.LsPoID = LsPo.ID
	AND LsPo.LsKoID = LsKo.ID
	AND LsPo.KdArtiID = KdArti.ID
	AND KdArti.ArtikelID = Artikel.ID
	AND Langbez.TableID = Artikel.ID
	AND Langbez.TableName = 'ARTIKEL'
	AND LsPo.RPoID = RPo.ID
	AND RPo.RKoID = RKo.ID
	