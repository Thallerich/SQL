TRY
	DROP TABLE #TmpAufbuegeln;
	DROP TABLE #TmpNachwaesche;
	DROP TABLE #TmpAusgang;
	DROP TABLE #TmpRueckgabe;
	DROP TABLE #TmpReparatur;
CATCH ALL
END;

SELECT Vsa.KundenID, CONVERT(Scans.DateTime, SQL_DATE) AS Datum, COUNT(Scans.ID) AS Aufbuegeln
INTO #TmpAufbuegeln
FROM Scans, Teile, Vsa
WHERE Scans.ZielNrID IN (1101000, 1101001, 1101002, 1101003, 1101004, 1101005, 1101006)
	AND CONVERT(Scans.DateTime, SQL_DATE) BETWEEN $1$ AND $2$
	AND Scans.TeileID = Teile.ID
	AND Teile.VsaID = Vsa.ID
GROUP BY KundenID, Datum;

SELECT Vsa.KundenID, CONVERT(Scans.DateTime, SQL_DATE) AS Datum, COUNT(Scans.ID) AS Nachwaesche
INTO #TmpNachwaesche
FROM Scans, Teile, Vsa
WHERE Scans.ZielNrID IN (1104201)
	AND CONVERT(Scans.DateTime, SQL_DATE) BETWEEN $1$ AND $2$
	AND Scans.TeileID = Teile.ID
	AND Teile.VsaID = Vsa.ID
GROUP BY KundenID, Datum;

SELECT Vsa.KundenID, CONVERT(Scans.DateTime, SQL_DATE) AS Datum, COUNT(Scans.ID) AS Ausgang
INTO #TmpAusgang
FROM Scans, Teile, Vsa
WHERE Scans.ZielNrID IN (1108100, 1108051, 1108052)
	AND CONVERT(Scans.DateTime, SQL_DATE) BETWEEN $1$ AND $2$
	AND Scans.TeileID = Teile.ID
	AND Teile.VsaID = Vsa.ID
GROUP BY KundenID, Datum;

SELECT Vsa.KundenID, CONVERT(Scans.DateTime, SQL_DATE) AS Datum, COUNT(Scans.ID) AS Rueckgabe
INTO #TmpRueckgabe
FROM Scans, Teile, Vsa
WHERE Scans.ZielNrID = 1109001
	AND CONVERT(Scans.DateTime, SQL_DATE) BETWEEN $1$ AND $2$
	AND Scans.TeileID = Teile.ID
	AND Teile.VsaID = Vsa.ID
GROUP BY KundenID, Datum;

SELECT Vsa.KundenID, CONVERT(Scans.DateTime, SQL_DATE) AS Datum, COUNT(Scans.ID) AS Reparatur
INTO #TmpReparatur
FROM Scans, Teile, Vsa
WHERE Scans.ZielNrID = 1105001
	AND CONVERT(Scans.DateTime, SQL_DATE) BETWEEN $1$ AND $2$
	AND Scans.TeileID = Teile.ID
	AND Teile.VsaID = Vsa.ID
GROUP BY KundenID, Datum;

SELECT ta.Datum, Kunden.KdNr, TRIM(IIF(Kunden.Name1 IS NULL,'',Kunden.Name1))+' '+TRIM(IIF(Kunden.Name2 IS NULL,'',Kunden.Name2))+' '+TRIM(IIF(Kunden.Name3 IS NULL,'',Kunden.Name3)) AS Kunde, ta.Aufbuegeln, tn.Nachwaesche, tf.Reparatur, tr.Rueckgabe, tl.Ausgang, IIF(ta.Aufbuegeln IS NULL, 0, ta.Aufbuegeln) - IIF(tn.Nachwaesche IS NULL, 0, tn.Nachwaesche) - IIF(tf.Reparatur IS NULL, 0, tf.Reparatur) - IIF(tr.Rueckgabe IS NULL, 0, tr.Rueckgabe) - IIF(tl.Ausgang IS NULL, 0, tl.Ausgang) AS Ergebnis
FROM Kunden
JOIN #TmpAufbuegeln ta
	ON (ta.KundenID = Kunden.ID)
LEFT OUTER JOIN #TmpNachwaesche tn
	ON (tn.KundenID = Kunden.ID AND tn.Datum = ta.Datum)
LEFT OUTER JOIN #TmpAusgang tl
	ON (tl.KundenID = Kunden.ID AND tl.Datum = ta.Datum)
LEFT OUTER JOIN #TmpRueckgabe tr
	ON (tr.KundenID = Kunden.ID AND tr.Datum = ta.Datum)
LEFT OUTER JOIN #TmpReparatur tf
	ON (tf.KundenID = Kunden.ID AND tf.Datum = ta.Datum)
WHERE ta.Aufbuegeln IS NOT NULL
ORDER BY KdNr, ta.Datum;