SELECT Teile.RentomatChip AS Chipcode, Artikel.ArtikelNr, ArtGroe.Groesse, Teile.PatchDatum AS Erstellungsdatum, CONVERT(integer, IIF(Vsa.VsaNr = 1024, 1, IIF(Vsa.VsaNr = 1025, 2, NULL))) AS Bereich, CONVERT(integer, IIF(Teile.Status <= 'Q', 1, 0)) AS Aktiv
FROM Teile, Artikel, ArtGroe, Vsa, Kunden
WHERE Teile.ArtikelID = Artikel.ID
  AND Teile.ArtGroeID = ArtGroe.ID
  AND Teile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Kunden.KdNr = 25005
  AND Vsa.RentomatID = 56
  AND Teile.PatchDatum IS NOT NULL;