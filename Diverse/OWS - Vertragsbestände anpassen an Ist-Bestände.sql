WITH OffeneAnf AS (
  SELECT AnfKo.VsaID, AnfPo.KdArtiID, (AnfPo.Angefordert - AnfPo.Geliefert) AS LiefOffen
  FROM AnfPo
  JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
  WHERE AnfKo.LieferDatum >= CAST(GETDATE() AS date)
    AND AnfPo.Angefordert <> 0
    AND AnfKo.Sonderfahrt = 0
    AND AnfKo.LsKoID < 0
    AND AnfKo.Status < N'L'
)
SELECT Vsa.VsaNr, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, VsaAnf.Bestand AS [Vertragsbestand aktuell], VsaAnf.BestandIst AS [Ist-Bestand aktuell], CAST(SUM(ISNULL(OffeneAnf.LiefOffen, 0)) AS int) AS [Offene angeforderte Menge]
FROM VsaAnf
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
LEFT OUTER JOIN OffeneAnf ON OffeneAnf.VsaID = VsaAnf.VsaID AND OffeneAnf.KdArtiID = VsAanf.KdArtiID
WHERE EXISTS (
  SELECT OPTeile.*
  FROM OPTeile
  WHERE OPTeile.Status = N'Q'
    AND OPTeile.LastActionsID = 102
    AND OPTeile.VsaID = Vsa.ID
    AND OPTeile.ArtikelID = Artikel.ID
  )
GROUP BY Vsa.VsaNr, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez, Vsaanf.Bestand, VsaAnf.BestandIst
ORDER BY Vsa.VsaNr, Artikel.ArtikelNr;