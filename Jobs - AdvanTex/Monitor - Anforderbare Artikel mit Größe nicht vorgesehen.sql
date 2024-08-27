SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez, Bereich.BereichBez, VsaAnf.Anlage_, Mitarbei.Name + ISNULL(N' (' + Mitarbei.MitarbeiUser + N')', N'') AS AnlageUser
FROM VsaAnf
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Mitarbei ON VsaAnf.AnlageUserID_ = Mitarbei.ID
WHERE VsaAnf.ArtGroeID > -1
  AND Bereich.VsaAnfGroe = 0
  AND VsaAnf.Status < 'I'
  AND KdArti.Status = 'A'
  AND KdBer.Status = 'A'
  AND Kunden.Status = 'A'
  AND Vsa.Status = 'A';