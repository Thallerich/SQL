SELECT Firma.Bez AS Firma, KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr AS [VSA-Nr.], Vsa.SuchCode AS [VSA-Stichwort], Vsa.Bez AS [VSA-Bezeichnung], Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, VsaAnf.Bestand AS Vertragsbestand, Vsa.ID AS VsaID
FROM VsaAnf
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE Artikel.ID = $ID$
  AND Kunden.AdrArtID = 1
  AND Kunden.Status = N'A'
  AND Vsa.Status = N'A'
  AND VsaAnf.Status = N'A'
  AND VsaAnf.Bestand > 0
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
  AND Vsa.SichtbarID IN ($SICHTBARIDS$)
ORDER BY Firma, Geschäftsbereich, KdNr, [VSA-Nr.];