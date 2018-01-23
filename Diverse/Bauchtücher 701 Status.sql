TRY
	DROP TABLE #TmpOpEti;
CATCH ALL END;

SELECT OpEtiKo.ID, Status.Bez, OpEtiKo.EtiNr, OpEtiPo.OpTeileID 
INTO #TmpOpEti
FROM OpEtiKo, OpEtiPo, Status
WHERE OpEtiKo.ID = OpEtiPo.OpEtiKoID
AND OpEtiKo.Status = Status.Status
AND Status.Tabelle = 'OPETIKO'
AND OpEtiKo.Status IN ('N','R');

SELECT OpTeile.Code, OpTeile.ErstWoche, opts.Bez AS Status, Artikel.SuchCode, toe.EtiNr AS SetEtikettNr, toe.Bez AS SetStatus
FROM Artikel, Status opts, OpTeile
LEFT JOIN #TmpOpEti toe ON toe.OpTeileID = OpTeile.ID
WHERE OpTeile.ArtikelID = Artikel.ID
	AND OpTeile.Status = opts.Status
	AND opts.Tabelle = 'OPTEILE'
	AND Artikel.ArtikelNr IN ('122207011001','122207011101','122207011201','124207011101','124207011201','129807011000')
	AND OpTeile.ErstWoche IN ('2010/38','2010/39','2010/40')
ORDER BY Code, ErstWoche ASC
