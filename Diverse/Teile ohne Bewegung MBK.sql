-- Pipeline Teile_ohne_Bewegung
SELECT Kunden.KdNr, Kunden.Name1, Kunden.Name2, Kunden.Name3, Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, ViewArtikel.ArtikelNr, ViewArtikel.ArtikelBez, ArtGroe.Groesse, Teile.Barcode, Teile.Eingang1, Teile.Ausgang1
FROM Kunden, Vsa, Traeger, Teile, ViewArtikel, ArtGroe
WHERE Teile.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Teile.TraegerID = Traeger.ID
	AND Teile.ArtikelID = ViewArtikel.ID
	AND Teile.ArtGroeID = ArtGroe.ID
	AND Kunden.ID = $ID$
	AND ViewArtikel.LanguageID = $LANGUAGE$
	AND (Teile.Eingang1 IS NULL OR Teile.Eingang1 <= $1$)
	AND (Teile.Ausgang1 IS NULL OR Teile.Ausgang1 <= $1$)
	AND Teile.Status = 'Q'
ORDER BY Kunden.KdNr, Traeger.Traeger, ViewArtikel.ArtikelNr;

-- Pipeline Teile_oB_Summe
SELECT ViewArtikel.ArtikelNr, ViewArtikel.ArtikelBez, COUNT(Teile.ID) AS Anzahl
FROM Teile, ViewArtikel, Vsa, Kunden
WHERE Teile.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Teile.ArtikelID = ViewArtikel.ID
	AND Kunden.ID = $ID$
	AND ViewArtikel.LanguageID = $LANGUAGE$
	AND (Teile.Eingang1 IS NULL OR Teile.Eingang1 <= $1$)
	AND (Teile.Ausgang1 IS NULL OR Teile.Ausgang1 <= $1$)
	AND Teile.Status = 'Q'
GROUP BY ViewArtikel.ArtikelNr, ViewArtikel.ArtikelBez
ORDER BY ViewArtikel.ArtikelNr;