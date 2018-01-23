SELECT ABC.ABC AS Klasse, Kunden.KdNr, Kunden.SuchCode, TRIM(Kunden.Name1) + ' ' + TRIM(IFNULL(Kunden.Name2, '')) + ' ' + TRIM(IFNULL(Kunden.Name3, '')) AS Name, Kunden.Strasse, Kunden.PLZ, Kunden.Ort, Kunden.Land, Holding.Holding, TRIM(Mitarbei.Nachname) + ' ' + TRIM(Mitarbei.Vorname) AS Vertrieb, Langbez.Bez AS Bereich
FROM Kunden, ABC, Holding, KdBer, Mitarbei, Bereich, Langbez
WHERE Kunden.ABCID = ABC.ID
	AND Kunden.HoldingID = Holding.ID
	AND Kunden.ID = KdBer.KundenID
	AND KdBer.VertreterID = Mitarbei.ID
	AND KdBer.BereichID = Bereich.ID
	AND Langbez.TableID = Bereich.ID
	AND Langbez.LanguageID = $LANGUAGE$
	AND Langbez.TableName = 'BEREICH'
	AND ABC.ID IN ($1$)
	AND Mitarbei.ID IN ($2$)
	AND Bereich.ID IN ($3$)
	AND Kunden.Status = 'A'
GROUP BY Klasse, Kunden.KdNr, Kunden.SuchCode, Name, Kunden.Strasse, Kunden.PLZ, Kunden.Ort, Kunden.Land, Holding.Holding, Vertrieb, Bereich
ORDER BY Klasse ASC, KdNr ASC