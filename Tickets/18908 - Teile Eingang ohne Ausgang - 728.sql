SELECT Teile.Barcode, Teile.Eingang1, Teile.Ausgang1, Artikel.ArtikelNr, ArtGroe.Groesse, Artikel.ArtikelBez, Traeger.Vorname, Traeger.Nachname, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Kunden.Kdnr, Kunden.SuchCode
FROM Teile, Traeger, Vsa, Kunden, ViewArtikel Artikel, ArtGroe, Bereich
WHERE Teile.TraegerID = Traeger.ID
	AND Traeger.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Teile.ArtikelID = Artikel.ID
	AND Artikel.BereichID = Bereich.ID
	AND Teile.ArtGroeID = ArtGroe.ID
	AND IIF(Teile.Eingang1 IS NULL, CONVERT('01.01.1900', SQL_DATE), Teile.Eingang1) > IIF(Teile.Ausgang1 IS NULL, CONVERT('01.01.2099', SQL_DATE), Teile.Ausgang1)
	AND Teile.Eingang1 < $1$
	AND Teile.Status = 'Q'
	AND Kunden.ID = $ID$
	AND Bereich.Bereich NOT IN ('CT')
	AND Artikel.LanguageID = $LANGUAGE$
ORDER BY Kunden.KdNr, VsaNr, Traeger.Nachname;