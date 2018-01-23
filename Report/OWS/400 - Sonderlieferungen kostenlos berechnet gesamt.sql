IF object_id('tempdb..#TmpTblAnzLs400') IS NOT NULL
  DROP TABLE #TmpTblAnzLs400;

SELECT $1$ AS DatumVon, $2$ AS DatumBis, Vsa.VsaNr, Vsa.Bez AS Vsa, COUNT(LsKo.ID) AS LiefGesamt, 0 AS LiefBerechnet, 0 AS LiefKostenlos
INTO #TmpTblAnzLs400
FROM AnfKo, LsKo, Vsa
WHERE AnfKo.LsKoID = LsKo.ID
	AND LsKo.VsaID = Vsa.ID
	AND LsKo.Datum BETWEEN $1$ AND $2$
	AND AnfKo.Sonderfahrt = $TRUE$
GROUP BY Vsa.VsaNr, Vsa.Bez;

UPDATE AnzLs SET AnzLs.LiefKostenlos = a.Kostenlos
FROM #TmpTblAnzLs400 AnzLs, (
	SELECT Vsa.VsaNr, COUNT(DISTINCT LsKo.ID) AS Kostenlos
	FROM AnfKo, LsKo, LsPo, Vsa
	WHERE AnfKo.LsKoID = LsKo.ID
		AND LsPo.LsKoID = LsKo.ID
		AND LsKo.VsaID = Vsa.ID
		AND LsKo.Datum BETWEEN $1$ AND $2$
		AND LsPo.Kostenlos = $TRUE$
		AND AnfKo.Sonderfahrt = $TRUE$
	GROUP BY Vsa.VsaNr
) a
WHERE AnzLs.VsaNr = a.VsaNr;
  
UPDATE AnzLs SET AnzLs.LiefBerechnet = a.Berechnet
FROM #TmpTblAnzLs400 AnzLs, (
	SELECT Vsa.VsaNr, COUNT(DISTINCT LsKo.ID) AS Berechnet
	FROM AnfKo, LsKo, LsPo, Vsa
	WHERE AnfKo.LsKoID = LsKo.ID
		AND LsPo.LsKoID = LsKo.ID
		AND LsKo.VsaID = Vsa.ID
		AND LsKo.Datum BETWEEN $1$ AND $2$
		AND LsPo.Kostenlos = $FALSE$
		AND AnfKo.Sonderfahrt = $TRUE$
	GROUP BY Vsa.VsaNr
) a
WHERE AnzLs.VsaNr = a.VsaNr;
  
SELECT * FROM #TmpTblAnzLs400;
