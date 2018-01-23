SELECT WegGrund.Bez AS Grund, Teile.Barcode, Status.Bez AS Status, Teile.ErstWoche, Teile.AusDienstDat, Artikel.ArtikelNr, Artikel.ArtikelBez, Artikel.EKPreis, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Kunden.KdNr, Kunden.SuchCode AS Kunde, KdGf.KurzBez AS SGF, 'Prod' AS SchrottOrt
FROM Teile, Vsa, Kunden, Status, ViewArtikel Artikel, WegGrund, KdGf
WHERE Teile.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Kunden.KdGfID = KdGf.ID
	AND Teile.Status = Status.Status
	AND Status.Tabelle = 'TEILE'
	AND Teile.ArtikelID = Artikel.ID
	AND Teile.Status = 'Y'
	AND Teile.WegGrundID = WegGrund.ID
	AND Teile.AusDienstDat BETWEEN $1$ AND $2$
	AND Artikel.BereichID = 100 -- BK
	AND Artikel.LanguageID = $LANGUAGE$

UNION

SELECT WegGrund.Bez AS Grund, TeileLag.Barcode, Status.Bez AS Status, TeileLag.ErstWoche, TeileLag.AusDienstDat, Artikel.ArtikelNr, Artikel.ArtikelBez, Artikel.EKPreis, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Kunden.KdNr, Kunden.SuchCode AS Kunde, KdGf.KurzBez AS SGF, 'Lager' AS SchrottOrt
FROM TeileLag, Status, ArtGroe, ViewArtikel Artikel, WegGrund, Traeger, Vsa, Kunden, KdGf
WHERE TeileLag.Status = Status.Status
	AND Status.Tabelle = 'TEILELAG'
	AND TeileLag.Status = 'Y'
	AND TeileLag.ArtGroeID = ArtGroe.ID
	AND ArtGroe.ArtikelID = Artikel.ID
	AND Artikel.BereichID = 100 -- BK
	AND Artikel.LanguageID = $LANGUAGE$
	AND TeileLag.WegGrundID = WegGrund.ID
	AND TeileLag.AusDienstDat BETWEEN $1$ AND $2$
	AND TeileLag.TraegerID = Traeger.ID
	AND Traeger.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Kunden.KdGfID = KdGf.ID
ORDER BY Kdnr, VsaNr, ArtikelNr;