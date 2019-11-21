SELECT Menge, Artikelbezeichnung, ArtikelNr, VPE, [definierter Bestand], [durchschn. Liefermenge]
FROM
(
  SELECT N'Kunde/Station: ' + CAST(Kunden.KdNr AS nvarchar(20)) + N'/' + Vsa.SuchCode AS Menge, NULL AS Artikelbezeichnung, NULL AS ArtikelNr, NULL AS VPE, NULL AS [definierter Bestand], NULL AS [durchschn. Liefermenge], 1 AS OrderNum
  FROM Vsa
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  WHERE Vsa.ID = $ID$

  UNION ALL

  SELECT Vsa.Bez AS Menge, NULL AS Artikelbezeichnung, NULL AS ArtikelNr, NULL AS VPE, NULL AS [definierter Bestand], NULL AS [durchschn. Liefermenge], 2 AS OrderNum
  FROM Vsa
  WHERE Vsa.ID = $ID$

  UNION ALL

  SELECT N'Anforderung für __.__.____' AS Menge, NULL AS Artikelbezeichnung, NULL AS ArtikelNr, NULL AS VPE, NULL AS [definierter Bestand], NULL AS [durchschn. Liefermenge], 3 AS OrderNum

  UNION ALL

  SELECT N'Bestellt am __.__.____ durch _____________' AS Menge, NULL AS Artikelbezeichnung, NULL AS ArtikelNr, NULL AS VPE, NULL AS [definierter Bestand], NULL AS [durchschn. Liefermenge], 4 AS OrderNum

  UNION ALL

  SELECT N'' AS Menge, NULL AS Artikelbezeichnung, NULL AS ArtikelNr, NULL AS VPE, NULL AS [definierter Bestand], NULL AS [durchschn. Liefermenge], 5 AS OrderNum

  UNION ALL

  SELECT N'Menge' AS Menge, N'Artikelbezeichnung' AS Artikelbezeichnung, N'ArtikelNr' AS ArtikelNr, N'VPE' AS VPE, N'definierter Bestand' AS [definierter Bestand], N'durchschn. Liefermenge' AS [durchschn. Liefermenge], 6 AS OrderNum

  UNION ALL

  SELECT NULL AS Menge, Artikel.ArtikelBez AS Artikelbezeichnung, Artikel.ArtikelNr, CAST(Artikel.PackMenge AS nvarchar(4)) AS VPE, CAST(VsaAnf.Bestand AS nvarchar(10)) AS [definierter Bestand], CAST(VsaAnf.Durchschnitt AS nvarchar(10)) AS [durchschn. Liefermenge], ROW_NUMBER() OVER (ORDER BY Bereich.Bereich, Artikel.ArtikelNr, KdArti.Variante) + 10 AS OrderNum
  FROM VsaAnf
  JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN VsaBer ON VsaBer.KdBerID = KdBer.ID AND VsaBer.VsaID = VsaAnf.VsaID
  JOIN Bereich ON KdBer.BereichID = Bereich.ID
  WHERE VsaAnf.VsaID = $ID$
    AND VsaBer.Status = 'A'
    AND VsaAnf.Status < 'E'
) AS x
ORDER BY OrderNum;