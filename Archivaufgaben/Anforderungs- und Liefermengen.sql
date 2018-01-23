SELECT AnfKo.Lieferdatum AS Datum, Kunden.ID AS KundenID, Vsa.ID AS VsaID, Artikel.ID AS ArtikelID, SUM(AnfPo.Angefordert) AS Angefordert, SUM(AnfPo.UrAngefordert) AS UrAngefordert, SUM(IIF(KdArti.ErsatzFuerKdArtiID > 0, 0, AnfPo.Geliefert)) AS Geliefert, SUM(IIF(KdArti.ErsatzFuerKdArtiID < 0, 0, AnfPo.Geliefert)) AS ErsatzGeliefert 
FROM AnfPo
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN Vsa ON AnfKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE AnfKo.Lieferdatum = CAST(GETDATE() AS date)
  AND AnfKo.Status >= N'I'
GROUP BY AnfKo.Lieferdatum, Kunden.ID, Vsa.ID, Artikel.ID
HAVING SUM(AnfPo.Angefordert) > 0 OR SUM(AnfPo.UrAngefordert) > 0 OR SUM(AnfPo.Geliefert) > 0;