TRY
	DROP TABLE #TmpLs;
	DROP TABLE #TmpLsBer;
CATCH ALL END;

SELECT Ls.LsNr, Ls.Datum, KdArti.KdBerID, Vsa.StandKonID, Kunden.KdNr, TRIM(IIF(Kunden.Name1 IS NULL,'',Kunden.Name1))+' '+TRIM(IIF(Kunden.Name2 IS NULL,'',Kunden.Name2))+' '+TRIM(IIF(Kunden.Name3 IS NULL,'',Kunden.Name3)) AS Kunde
INTO #TmpLs
FROM (
	SELECT LsKo.ID, LsKo.LsNr, LsKo.VsaID, LsKo.Datum, COUNT(LsPo.ID) AS Pos
	FROM LsKo
	LEFT JOIN LsCont
	ON LsKo.ID = LsCont.LsKoID
	LEFT JOIN LsPo
	ON LsKo.ID = LsPo.LsKoID
	WHERE LsCont.LsKoID IS NULL
	AND LsKo.Datum BETWEEN $1$ AND $2$
	GROUP BY LsKo.ID, LsKo.LsNr, LsKo.VsaID, LsKo.Datum
	HAVING Pos > 0
) Ls, LsPo, KdArti, Vsa, Kunden
WHERE Ls.ID = LsPo.LsKoID
	AND LsPo.KdArtiID = KdArti.ID
	AND Vsa.ID = Ls.VsaID
	AND Vsa.KundenID = Kunden.ID
GROUP BY 1,2,3,4,5,6;

SELECT Ls.LsNr, Ls.Datum, StandBer.BereichID, StandBer.ProduktionID, StandBer.ExpeditionID, Ls.KdNr, Ls.Kunde
INTO #TmpLsBer
FROM #TmpLs Ls, KdBer, Bereich, StandBer
WHERE Ls.KdBerID = KdBer.ID
	AND KdBer.BereichID = Bereich.ID
	AND Bereich.ID = StandBer.BereichID
	AND StandBer.StandKonID = Ls.StandKonID
GROUP BY Ls.LsNr, Ls.Datum, StandBer.BereichID, StandBer.ProduktionID, StandBer.ExpeditionID, Ls.KdNr, Ls.Kunde;

SELECT LsBer.LsNr, LsBer.Datum, LsBer.KdNr, LsBer.Kunde, Bereich.Bez AS Bereich, Prod.Bez AS Produktion, Expedit.Bez AS Expedition
FROM #TmpLsBer LsBer, Bereich, Standort Prod, Standort Expedit
WHERE LsBer.BereichID = Bereich.ID
	AND LsBer.ProduktionID = Prod.ID
	AND LsBer.ExpeditionID = Expedit.ID
	AND LsBer.BereichID IN ($3$)
	AND LsBer.ProduktionID IN ($4$)
	AND LsBer.ExpeditionID IN ($5$)
ORDER BY LsNr;