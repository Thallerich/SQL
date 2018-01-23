-- Pipeline Rueckstand
SELECT Kunden.KdNr, Kunden.Name1, Kunden.Name2, Kunden.Name3, Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, ViewArtikel.ArtikelNr, ViewArtikel.ArtikelBez, ArtGroe.Groesse, Teile.Barcode, Teile.Eingang1, Teile.Ausgang1
FROM Kunden, Vsa, Traeger, Teile, ViewArtikel, ArtGroe
WHERE Teile.TraegerID = Traeger.ID
	AND Teile.ArtikelID = ViewArtikel.ID
	AND Teile.ArtGroeID = ArtGroe.ID
	AND Teile.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND ViewArtikel.LanguageID = $LANGUAGE$
	AND Kunden.KdNr NOT IN (2527750, 2580275, 2500002)
	AND Teile.Eingang1 > IFNULL(Teile.Ausgang1, CONVERT('01.01.1980', SQL_DATE))
	AND Teile.Eingang1 <= $1$
	AND Teile.AltenheimModus = 0
	AND Teile.Status = 'Q'
ORDER BY Kunden.KdNr, Traeger.Traeger, ViewArtikel.ArtikelNr;

-- Pipeline Rueckstand_Summe
SELECT Kunden.KdNr, Kunden.Name1, Kunden.Name2, Kunden.Name3, ViewArtikel.ArtikelNr, ViewArtikel.ArtikelBez, COUNT(Teile.ID) AS Anzahl
FROM Kunden, Vsa, Teile, ViewArtikel
WHERE Teile.ArtikelID = ViewArtikel.ID
	AND Teile.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Kunden.KdNr NOT IN (2527750, 2580275, 2500002)
	AND ViewArtikel.LanguageID = $LANGUAGE$
	AND Teile.Eingang1 > IFNULL(Teile.Ausgang1, CONVERT('01.01.1980', SQL_DATE))
	AND Teile.Eingang1 <= $1$
	AND Teile.AltenheimModus = 0
	AND Teile.Status = 'Q'
GROUP BY Kunden.KdNr, Kunden.Name1, Kunden.Name2, Kunden.Name3, ViewArtikel.ArtikelNr, ViewArtikel.ArtikelBez
ORDER BY ViewArtikel.ArtikelNr;