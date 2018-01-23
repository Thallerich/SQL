SELECT Kunden.ID AS KundenID, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.ID AS VsaID, Vsa.SuchCode AS [VSA-Stichwort], Vsa.Bez AS [VSA-Bezeichnung], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, VsaAnf.Bestand
FROM VsaAnf, Vsa, Kunden, KdArti, Artikel
WHERE VsaAnf.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND VsaAnf.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Kunden.ID = $ID$
  AND (($1$ = 0 AND VsaAnf.Bestand > 0) OR ($1$ = 1))
  AND VsaAnf.Status <> 'I'
  AND Vsa.Status = 'A'
ORDER BY Kunden.KdNr, VsaID,  Artikel.ArtikelNr;