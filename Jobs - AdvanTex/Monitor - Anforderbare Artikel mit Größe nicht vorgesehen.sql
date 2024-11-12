SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Artikel.ArtikelNr, Artikel.ArtikelBez, Bereich.Bereich, VsaAnf.Anlage_, Mitarbei.MitarbeiUser AS AnlageUser, OhneGrößeVorhanden = CAST(IIF(EXISTS((
  SELECT v.*
  FROM VsaAnf AS v
  WHERE v.VsaID = VsaAnf.VsaID
    AND v.KdArtiID = VsaAnf.KdArtiID
    AND v.ArtGroeID = -1
    AND v.Status < N'I'
)), 1, 0) AS bit)
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
  AND VsaAnf.Status < 'E'
  AND KdArti.Status = 'A'
  AND KdBer.Status = 'A'
  AND Kunden.Status = 'A'
  AND Vsa.Status = 'A';