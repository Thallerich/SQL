SELECT Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.VsaNr,
  Vsa.SuchCode AS [Vsa-Stichwort],
  Vsa.Bez AS [Vsa-Bezeichnung],
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  ArtGroe.Groesse,
  IIF(VsaAnf.Liefern1 = 0, NULL, VsaAnf.Liefern1) AS [Liefermenge Montag],
  IIF(VsaAnf.Liefern2 = 0, NULL, VsaAnf.Liefern2) AS [Liefermenge Dienstag],
  IIF(VsaAnf.Liefern3 = 0, NULL, VsaAnf.Liefern3) AS [Liefermenge Mittwoch],
  IIF(VsaAnf.Liefern4 = 0, NULL, VsaAnf.Liefern4) AS [Liefermenge Donnerstag],
  IIF(VsaAnf.Liefern5 = 0, NULL, VsaAnf.Liefern5) AS [Liefermenge Freitag],
  IIF(VsaAnf.Liefern6 = 0, NULL, VsaAnf.Liefern6) AS [Liefermenge Samstag],
  IIF(VsaAnf.NormMenge = 0, NULL, VsaAnf.NormMenge) AS [Norm-Liefermenge],
  IIF(VsaAnf.SollPuffer = 0, NULL, VsaAnf.SollPuffer) AS SollPuffer,
  IIF(VsaAnf.Durchschnitt = 0, NULL, VsaAnf.Durchschnitt) AS Durchschnitt,
  VsaAnf.IstDatum AS [letzte Inventur],
  Kunden.ID AS KundenID
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