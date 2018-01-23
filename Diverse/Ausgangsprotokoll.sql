SELECT Kunden.KdNr, Kunden.Name1, Kunden.Name2, Kunden.Name3, Traeger.Traeger, Traeger.Vorname, Traeger.Nachname, ViewArtikel.ArtikelNr, ViewArtikel.ArtikelBez, ArtGroe.Groesse, Teile.Barcode, Teile.Eingang1, Teile.Ausgang1
FROM Kunden, Vsa, ViewArtikel, ArtGroe, Teile, Traeger
WHERE Teile.ArtikelID = ViewArtikel.ID
	AND Teile.ArtGroeID = ArtGroe.ID
	AND Teile.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Teile.TraegerID = Traeger.ID
	AND Teile.Ausgang1 BETWEEN $1$ AND $2$
	AND Teile.Ausgang1 >= Teile.Eingang1
	AND Kunden.ID = $ID$
	AND ViewArtikel.LanguageID = $LANGUAGE$
ORDER BY Kunden.KdNr, Traeger.Traeger, ViewArtikel.ArtikelNr;