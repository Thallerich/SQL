SELECT Standort.Bez AS Expedit, WEEK(CONVERT(LsKo.Anlage_, SQL_DATE)) AS Woche, COUNT(LsKo.ID) AS Anzahl_Lieferscheine
FROM LsKo, Fahrt, Touren, Standort, (
	SELECT LsKo.ID, COUNT(LsPo.ID) AnzLsPos
		FROM LsKo, LsPo
		WHERE LsPo.LsKoID = LsKo.ID
		AND CONVERT(LsKo.Anlage_, SQL_DATE) BETWEEN $2$ AND $3$
		GROUP BY LsKo.ID
		HAVING AnzLsPos > 0
) HasLsPos
WHERE Standort.ID IN ($1$)
	AND CONVERT(LsKo.Anlage_, SQL_DATE) BETWEEN $2$ AND $3$
	--AND LsKo.TourenID = Touren.ID
	AND LsKo.FahrtID = Fahrt.ID
	AND Fahrt.TourenID = Touren.ID
	AND Touren.ExpeditionID = Standort.IDo
	AND LsKo.ID = HasLsPos.ID
GROUP BY Expedit, Woche
ORDER BY Expedit, Woche
