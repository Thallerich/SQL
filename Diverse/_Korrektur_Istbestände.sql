SELECT VsaAnf.ID AS VsaAnfID, Kunden.KdNr, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Artikel.ArtikelNr, LangBez.Bez ArtikelBez, VsaAnf.Bestand, VsaAnf.BestandIst, COUNT(OPTeile.ID) AS TeileKd
INTO #TmpVsaKorr
FROM Opteile, Vsa, kdarti, kdber, vsaanf, Kunden, Artikel
LEFT OUTER JOIN LangBez ON (LangBez.TableName = 'ARTIKEL' AND LangBez.TableID = Artikel.ID AND LangBez.LanguageID = $LANGUAGE$)
WHERE OpTeile.status = 'R'
  AND Vsa.ID = OpTeile.VsaID
  AND Vsa.KundenID = KdBer.KundenID
  AND Kunden.ID = Vsa.KundenID
  AND KdArti.KdBerID = KdBer.ID
  AND Artikel.ID = KdArti.ArtikelID
  AND KdArti.ArtikelID = OpTeile.ArtikelID
  AND KdBer.IstBestandAnpass = TRUE
  AND VsaAnf.VsaID = Vsa.ID
  AND VsaAnf.KdArtiID = KdArti.ID
  AND OpTeile.VsaID > 0
  AND OpTeile.ArtGroeID = -1
GROUP BY 1, 2, 3, 4,5,6,7,8
HAVING COUNT(OpTeile.ID) <> VsaAnf.BestandIst;

UPDATE VsaAnf SET VsaAnf.BestandIst = VsaKorr.TeileKd
FROM VsaAnf, #TmpVsaKorr VsaKorr
WHERE VsaAnf.ID = VsaKorr.VsaAnfID;

DROP TABLE #TmpVsaKorr;