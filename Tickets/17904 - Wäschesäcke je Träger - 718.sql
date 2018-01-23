SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS Vsa, Vsa.Bez AS VsaBezeichnung, Traeger.Vorname, Traeger.Nachname, Teile.Barcode, Artikel.ArtikelNr, Artikel.ArtikelBez, Status.Bez AS Status
FROM Kunden, Vsa, Traeger, Teile, ViewArtikel Artikel, Status, ArtGru
WHERE Teile.TraegerID = Traeger.ID
	AND Traeger.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Teile.ArtikelID = Artikel.ID
	AND Artikel.ArtGruID = ArtGru.ID
	AND Teile.Status = Status.Status
	AND ArtGru.Sack = TRUE	-- Nur Wäschesäcke !
	AND Kunden.ID IN ($ID$)
	AND Artikel.LanguageID = $LANGUAGE$
	AND Status.Tabelle = 'TEILE'
ORDER BY KdNr, Vsa, Nachname, ArtikelNr;