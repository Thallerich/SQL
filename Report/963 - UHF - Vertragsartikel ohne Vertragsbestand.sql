SELECT
  KdGf.KurzBez AS SGF,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.VsaNr,
  Vsa.SuchCode AS [VSA-Stichwort],
  Vsa.Bez AS [VSA-Bezeichnung],
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS Artikelbezeichnung,
  KdArti.Vertragsartikel,
  VsaAnf.Bestand AS Vertragsbestand,
  VsaAnf.BestandIst AS [Ist-Bestand]
FROM VsaAnf
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN VsaBer ON VsaBer.VsaID = VsaAnf.VsaID AND VsaBer.KdBerID = KdBer.ID
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
WHERE VsaAnf.Art IN (N'M', N'm')
  AND VsaAnf.Status IN (N'A', N'C')
  AND KdBer.BereichID IN ($2$)
  AND VsaAnf.Bestand = 0
  AND KdArti.Vertragsartikel = 1
  AND VsaAnf.BestandIst != 0
  AND Vsa.Status = N'A'
  AND Kunden.Status = N'A'
  AND (KdBer.AnfAusEpo > 0 OR VsaBer.AnfAusEpo > 0)
  AND Artikel.EAN IS NOT NULL
  AND KdGf.ID IN ($1$)
ORDER BY SGF, KdNr, VsaNr, ArtikelNr;