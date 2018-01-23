SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, COUNT(TeileRep.ID) AS Reparaturen
FROM TeileRep, Teile, Traeger, Vsa, Kunden
WHERE TeileRep.TeileID = Teile.ID
	AND Teile.TraegerID = Traeger.ID
	AND Traeger.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND CONVERT(TeileRep.Zeitpunkt, SQL_DATE) BETWEEN $1$ AND $2$
	AND Kunden.ID = $ID$
GROUP BY KdNr, Kunde, Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, VsaNr, Vsa
ORDER BY VsaNr, Traeger.Traeger;