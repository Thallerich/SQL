SELECT  Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS [Vsa-Stichwort], Vsa.Bez AS [Vsa-Bezeichnung], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, VsaAnf.Liefern1 AS [Liefermenge Montag], VsaAnf.Liefern2 AS [Liefermenge Dienstag], VsaAnf.Liefern3 AS [Liefermenge Mittwoch], VsaAnf.Liefern4 AS [Liefermenge Donnerstag], VsaAnf.Liefern5 AS [Liefermenge Freitag], VsaAnf.Liefern6 AS [Liefermenge Samstag], VsaAnf.Liefern7 AS [Liefermenge Sonntag], VsaAnf.NormMenge AS [Norm-Liefermenge], VsaAnf.SollPuffer, VsaAnf.Durchschnitt, VsaAnf.IstDatum AS [letzte Inventur], Kunden.ID AS KundenID
FROM VsaAnf
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Vsa.ID = $ID$
  AND (($1$ = 0 AND VsaAnf.MitInventur = 1) OR ($1$ = 1))
ORDER BY Artikel.ArtikelNr;