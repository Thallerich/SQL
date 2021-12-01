SELECT  Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS [Vsa-Stichwort], Vsa.Bez AS [Vsa-Bezeichnung], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, VsaAnf.Liefern1 AS [Liefermenge Montag], VsaAnf.Liefern2 AS [Liefermenge Dienstag], VsaAnf.Liefern3 AS [Liefermenge Mittwoch], VsaAnf.Liefern4 AS [Liefermenge Donnerstag], VsaAnf.Liefern5 AS [Liefermenge Freitag], VsaAnf.Liefern6 AS [Liefermenge Samstag], VsaAnf.NormMenge AS [Norm-Liefermenge], VsaAnf.SollPuffer, VsaAnf.Durchschnitt, VsaAnf.IstDatum AS [letzte Inventur], Kunden.ID AS KundenID
FROM VsaAnf
JOIN ArtGroe ON VsaAnf.ArtGroeID = ArtGroe.ID
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.ID = $ID$
  AND (($1$ = 1 AND VsaAnf.MitInventur = 1) OR ($1$ = 0))
  AND (($2$ = 1 AND VsaAnf.Art = 'F') OR ($2$ = 0))
ORDER BY [Vsa-Stichwort], Artikel.ArtikelNr;