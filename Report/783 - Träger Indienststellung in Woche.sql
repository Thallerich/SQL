SELECT KdGf.KdGfBez$LAN$ AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, Traeger.Nachname, Traeger.Vorname, Traeger.Indienst, Traeger.SchrankInfo AS SchrankFach
FROM Traeger, Vsa, Kunden, KdGf
WHERE Traeger.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Kunden.KdGfID = KdGf.ID
	AND Traeger.Indienst >= $1$
	AND KdGf.ID IN ($2$)
ORDER BY SGF, Traeger.Indienst, Kunde, Traeger.Nachname, Traeger.Vorname;