SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS VsaNr, TRIM(Vsa.Name1)+ ' ' + TRIM(Vsa.Name2) AS Vsa, ViewArtikel.ArtikelNr, ViewArtikel.SuchCode, ViewArtikel.ArtikelBez, ArtGroe.Groesse, Teile.Barcode, Teile.RentomatChip, Status.Bez AS Status
FROM Teile, Vsa, Kunden, Status, ViewArtikel, ArtGroe
WHERE Teile.VsaID = Vsa.ID
AND Vsa.KundenID = Kunden.ID
AND Kunden.KdNr = 7240
AND Teile.Status = Status.Status
AND Status.Tabelle = 'TEILE'
AND Status.Status <> 'Y'
AND Teile.ArtikelID = ViewArtikel.ID
AND Teile.ArtGroeID = ArtGroe.ID
AND ViewArtikel.ArtikelBez IS NOT NULL