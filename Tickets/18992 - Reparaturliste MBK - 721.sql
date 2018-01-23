SELECT Kunden.KdNr, Kunden.SuchCode, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Traeger.Traeger, Traeger.Vorname, Traeger.Nachname, RepDaten.Barcode, RepType.Bez AS Reparaturgrund, RepDaten.LastRepDate AS [Letzte Reparatur], RepDaten.RepAnz AS [Anzahl Reparaturen], RepDaten.Indienst
FROM Traeger, Vsa, Kunden, ViewRepType RepType, (
	SELECT Teile.TraegerID, Teile.Barcode, Teile.Indienst, TeileRep.RepTypeID, CONVERT(MAX(TeileRep.Zeitpunkt), SQL_DATE) AS LastRepDate, COUNT(TeileRep.ID) AS RepAnz
	FROM Teile, TeileRep
	WHERE TeileRep.TeileID = Teile.ID
		AND CONVERT(TeileRep.Zeitpunkt, SQL_DATE) BETWEEN $1$ AND $2$
	GROUP BY Teile.TraegerID, Teile.Barcode, Teile.Indienst, TeileRep.RepTypeID
) AS RepDaten
WHERE RepDaten.TraegerID = Traeger.ID
	AND Traeger.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND RepDaten.RepTypeID = RepType.ID
	AND RepType.LanguageID = $LANGUAGE$
ORDER BY KdNr, VsaNr, Traeger;

------------------------------------------------------------
SELECT RepType.Bez AS Reparaturgrund, SUM(RepDaten.RepAnz) AS [Anzahl Reparaturen]
FROM Traeger, Vsa, Kunden, ViewRepType RepType, (
	SELECT Teile.TraegerID, Teile.Barcode, Teile.Indienst, TeileRep.RepTypeID, CONVERT(MAX(TeileRep.Zeitpunkt), SQL_DATE) AS LastRepDate, COUNT(TeileRep.ID) AS RepAnz
	FROM Teile, TeileRep
	WHERE TeileRep.TeileID = Teile.ID
		AND CONVERT(TeileRep.Zeitpunkt, SQL_DATE) BETWEEN $1$ AND $2$
	GROUP BY Teile.TraegerID, Teile.Barcode, Teile.Indienst, TeileRep.RepTypeID
) AS RepDaten
WHERE RepDaten.TraegerID = Traeger.ID
	AND Traeger.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND RepDaten.RepTypeID = RepType.ID
	AND RepType.LanguageID = $LANGUAGE$
GROUP BY Reparaturgrund

UNION

SELECT '_Reparaturen Gesamt' AS Reparaturgrund, SUM(RepDaten.RepAnz) AS [Anzahl Reparaturen]
FROM Traeger, Vsa, Kunden, ViewRepType RepType, (
	SELECT Teile.TraegerID, Teile.Barcode, Teile.Indienst, TeileRep.RepTypeID, CONVERT(MAX(TeileRep.Zeitpunkt), SQL_DATE) AS LastRepDate, COUNT(TeileRep.ID) AS RepAnz
	FROM Teile, TeileRep
	WHERE TeileRep.TeileID = Teile.ID
		AND CONVERT(TeileRep.Zeitpunkt, SQL_DATE) BETWEEN $1$ AND $2$
	GROUP BY Teile.TraegerID, Teile.Barcode, Teile.Indienst, TeileRep.RepTypeID
) AS RepDaten
WHERE RepDaten.TraegerID = Traeger.ID
	AND Traeger.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND RepDaten.RepTypeID = RepType.ID
	AND RepType.LanguageID = $LANGUAGE$
ORDER BY Reparaturgrund;