TRY
	DROP TABLE #TmpOpEtiKo;
CATCH ALL END;

SELECT *
INTO #TmpOpEtiKo
FROM OpEtiKo
WHERE CONVERT(AusleseZeitpunkt, SQL_DATE) BETWEEN $2$ AND $3$;

SELECT OpEtiKo.EtiNr, S1.Bez AS SetStatus, OpEtiKo.VerfallDatum, OpEtiKo.AusleseZeitpunkt, A1.ArtikelNr AS SetArtNr, A1.ArtikelBez AS SetBez, OpTeile.Code AS TeilBarcode, S2.Bez AS TeilStatus, A2.ArtikelNr AS TeilArtNr, A2.ArtikelBez AS TeilBez, Kunden.KdNr, Kunden.Name1, Kunden.Name2, Kunden.Name3, Vsa.ID, Vsa.SuchCode AS VSANr, Vsa.Bez AS VSABez
FROM #TmpOpEtiKo OpEtiKo, OpEtiPo, OpTeile, ViewArtikel A1, ViewArtikel A2, Vsa, Kunden, Status S1, Status S2
WHERE OpEtiPo.OpEtiKoID = OpEtiKo.ID
	AND OpEtiKo.ArtikelID = A1.ID
	AND A1.LanguageID = $LANGUAGE$
	AND OpEtiKo.Status = S1.Status
	AND S1.Tabelle = 'OPETIKO'
	AND OpEtiKo.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND OpEtiPo.OpTeileID = OpTeile.ID
	AND OpEtiKo.VsaID = OpTeile.VsaID
	AND OpTeile.ArtikelID = A2.ID
	AND A2.LanguageID = $LANGUAGE$
	AND OpTeile.Status = S2.Status
	AND S2.Tabelle = 'OPTEILE'
	AND Kunden.ID IN ($1$)
	AND S1.ID IN ($4$)
	AND S2.Status IN ('R')
ORDER BY Kunden.KdNr, OpEtiKo.EtiNr;