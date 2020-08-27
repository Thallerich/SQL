SELECT Vsa.ID AS BlockID, N'VSA' AS BlockIDName, Kunden.KdNr, Kunden.Name1, Kunden.Name2, Kunden.Name3, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, VsaAnf.Liefern1 AS [Liefermenge Montag], VsaAnf.Liefern2 AS [Liefermenge Dienstag], VsaAnf.Liefern3 AS [Liefermenge Mittwoch], VsaAnf.Liefern4 AS [Liefermenge Donnerstag], VsaAnf.Liefern5 AS [Liefermenge Freitag], VsaAnf.Liefern6 AS [Liefermenge Samstag], VsaAnf.Liefern7 AS [Liefermenge Sonntag], VsaAnf.NormMenge AS [Norm-Liefermenge], VsaAnf.SollPuffer, VsaAnf.Durchschnitt, VsaAnf.IstDatum AS [letzte Inventur]
FROM VsaAnf
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Kunden.ID = " . $kundenID . "
  AND VsaAnf.Art = N'F'  -- feste Liefermenge
  AND Vsa.ID IN ($vsaids)
ORDER BY Vsa.VsaNr, Artikel.ArtikelNr;