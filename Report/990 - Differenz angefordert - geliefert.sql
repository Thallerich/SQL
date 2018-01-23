BEGIN TRY
  DROP TABLE #TmpDiffLs;
END TRY
BEGIN CATCH
END CATCH

SELECT DISTINCT KundenID, VsaID, KdBerID, VsaBerID, LsNr, AuftragsNr, Datum, ArtikelNr, Artikelbezeichnung, Variante, Angefordert, Geliefert, KdArtiID, FromLsPo
INTO #TmpDiffLs
FROM (
  SELECT Kunden.ID AS KundenID, Vsa.ID AS VsaID, KdBer.ID AS KdBerID, VsaBer.ID AS VsaBerID, Lsko.LsNr, AnfKo.AuftragsNr, LsKo.Datum, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdArti.Variante, 0 AS Angefordert, 0 AS Geliefert, KdArti.ID AS KdArtiID, CONVERT(bit, 0) AS FromLsPo
  FROM LsPo, LsKo, KdArti, Artikel, AnfKo, Vsa, Kunden, KdBer, VsaBer
  WHERE LsPo.LsKoID = LsKo.ID
    AND LsPo.KdArtiID = KdArti.ID
    AND KdArti.ArtikelID = Artikel.ID
    AND AnfKo.LskoID = LsKo.ID
    AND LsKo.VsaID = Vsa.ID
    AND Vsa.KundenID = Kunden.ID
    AND KdArti.KdBerID = KdBer.ID
    AND VsaBer.KdBerID = KdBer.ID
    AND VsaBer.VsaID = Vsa.ID
    AND LsKo.LsNr = $1$

  UNION

  SELECT Kunden.ID AS KundenID, Vsa.ID AS VsaID, KdBer.ID AS KdBerID, VsaBer.ID AS VsaBerID, LsKo.LsNr, AnfKo.AuftragsNr, LsKo.Datum, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, KdArti.Variante, 0 AS Angefordert, 0 AS Geliefert, KdArti.ID AS KdArtiID, COnVERT(bit, 0) AS FromLsPo
  FROM AnfPo, AnfKo, KdArti, Artikel, LsKo, Vsa, Kunden, KdBer, VsaBer
  WHERE AnfPo.AnfKoID = AnfKo.ID
    AND AnfPo.KdArtiID = KdArti.ID
    AND KdArti.ArtikelID = Artikel.ID
    AND AnfKo.LsKoID = LsKo.ID
    AND AnfKo.VsaID = Vsa.ID
    AND Vsa.KundenID = Kunden.ID
    AND KdArti.KdBerID = KdBer.ID
    AND VsaBer.KdBerID = KdBer.ID
    AND VsaBer.VsaID = Vsa.ID
    AND LsKo.LsNr = $1$
) LsData;

UPDATE DiffLs SET Geliefert = LsPo.Menge, FromLsPo = 1
FROM #TmpDiffLs AS DiffLs, LsPo, LsKo
WHERE LsPo.LsKoID = LsKo.ID
  AND LsPo.KdArtiID = DiffLs.KdArtiID
  AND LsKo.LsNr = DiffLs.LsNr;

UPDATE DiffLs SET Angefordert = AnfPo.Angefordert
FROM #TmpDiffLs AS DiffLs, AnfPo, AnfKo
WHERE AnfPo.AnfKoID = AnfKo.ID
  AND AnfPo.KdArtiID = DiffLs.KdArtiID
  AND AnfKo.AuftragsNr = DiffLs.AuftragsNr
  AND AnfPo.Angefordert <> 0;

SELECT KundenID, VsaID, KdBerID, VsaBerID, LsNr, AuftragsNr, Datum, ArtikelNr, Artikelbezeichnung, Variante, Angefordert, Geliefert
FROM [#TmpDiffLs]
WHERE Angefordert <> 0
  OR Geliefert <> 0
  OR FromLsPo = 1;