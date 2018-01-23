-- ######################  VSA  ##############################
SELECT Teile.Barcode, Status.Bez AS Status, Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, ViewArtikel.ArtikelNr, ViewArtikel.ArtikelBez, ArtGroe.Groesse, Kunden.KdNr, Kunden.Name1, Kunden.Name2, Kunden.Name3, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa
FROM Teile, Traeger, Vsa, Kunden, ViewArtikel, ArtGroe, Status
WHERE Teile.TraegerID = Traeger.ID
	AND Teile.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Teile.ArtikelID = ViewArtikel.ID
	AND Teile.ArtGroeID = ArtGroe.ID
	AND Teile.Status = Status.Status
	AND Status.Tabelle = 'TEILE'
	AND Vsa.ID = $ID$
	AND Teile.Status IN ('S', 'T', 'U', 'V', 'W')
	AND ViewArtikel.LanguageID = $LANGUAGE$
ORDER BY Traeger.Traeger, ViewArtikel.ArtikelNr, ArtGroe.Groesse;

-- ######################  KUNDE  ############################
SELECT Teile.Barcode, Status.Bez AS Status, Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, ViewArtikel.ArtikelNr, ViewArtikel.ArtikelBez, ArtGroe.Groesse, Kunden.KdNr, Kunden.Name1, Kunden.Name2, Kunden.Name3, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa
FROM Teile, Traeger, Vsa, Kunden, ViewArtikel, ArtGroe, Status
WHERE Teile.TraegerID = Traeger.ID
	AND Teile.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Teile.ArtikelID = ViewArtikel.ID
	AND Teile.ArtGroeID = ArtGroe.ID
	AND Teile.Status = Status.Status
	AND Status.Tabelle = 'TEILE'
	AND Kunden.ID = $ID$
	AND Teile.Status IN ('S', 'T', 'U', 'V', 'W')
	AND ViewArtikel.LanguageID = $LANGUAGE$
ORDER BY VsaNr, Traeger.Traeger, ViewArtikel.ArtikelNr, ArtGroe.Groesse;