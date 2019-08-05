SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.SuchCode AS [Vsa-Stichwort], Vsa.Bez AS [Vsa-Bezeichnung], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdArti.Variante, KdArti.VariantBez AS Variantenbezeichnung, ArtGroe.Groesse, VsaAnf.Durchschnitt AS [durchschnittliche Liefermenge], CAST(NULL AS int) AS [Menge]
FROM VsaAnf
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN VsaBer ON VsaBer.KdBerID = KdArti.KdBerID AND VsaBer.VsaID = Vsa.ID
LEFT OUTER JOIN ArtGroe ON VsaAnf.ArtGroeID = ArtGroe.ID
WHERE Vsa.ID = $ID$
  AND VsaAnf.[Status] < N'E'
  AND VsaBer.[Status] = N'A'
ORDER BY Bereich.Bereich, Artikel.ArtikelNr, KdArti.Variante;