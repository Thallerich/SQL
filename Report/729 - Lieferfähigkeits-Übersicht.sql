BEGIN TRY
  DROP TABLE #TmpAnf;
END TRY
BEGIN CATCH
END CATCH;

SELECT AnfKo.Lieferdatum, AnfPo.Angefordert, AnfPo.Geliefert, AnfPo.KdArtiID, AnfKo.VsaID
INTO #TmpAnf
FROM AnfPo, AnfKo
WHERE AnfPo.AnfKoID = AnfKo.ID
  AND AnfKo.Lieferdatum BETWEEN $1$ AND $2$
  AND (AnfPo.Angefordert > 0 OR AnfPo.Geliefert > 0);

SELECT Anf.LieferDatum, Kunden.KdNr, Kunden.SuchCode, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, SUM(Anf.Angefordert) AS Angefordert, SUM(Anf.Geliefert) AS Geliefert, SUM(Anf.Angefordert - Anf.Geliefert) AS Differenz, ROUND(SUM(Anf.Geliefert) / SUM(IIF(Anf.Angefordert = 0, 1, Anf.Angefordert)) * 100, 2) AS Prozent
FROM #TmpAnf Anf, VSA, Kunden, KdArti, Artikel, Bereich
WHERE Anf.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Anf.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND Artikel.BereichID = Bereich.ID
  AND Bereich.ID IN ($3$)
  AND (($4$ = 1 AND Anf.Angefordert - Anf.Geliefert <> 0) OR ($4$ = 0))
  AND Kunden.FirmaID IN ($5$)
GROUP BY Anf.LieferDatum, Kunden.KdNr, Kunden.SuchCode, Vsa.SuchCode, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$
ORDER BY Artikel.ArtikelNr, Anf.LieferDatum;