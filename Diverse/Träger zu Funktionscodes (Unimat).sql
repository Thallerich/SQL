SELECT RentoCod.Funktionscode, RentoCod.Bez AS Funktionsbezeichnung, Traeger.Titel, Traeger.Vorname, Traeger.Nachname
FROM Traeger, RentoCod
WHERE Traeger.RentoCodID = RentoCod.ID
	AND Traeger.Status <> 'I'
	AND RentoCod.ID IN ($1$)
	
	
SELECT Vsa.Bez, Traeger.Titel, Traeger.Vorname, Traeger.Nachname, RentomatKredit, RentomatKarte
FROM Traeger, Vsa, Kunden
WHERE Traeger.RentomatKredit = $1$
	AND Traeger.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Kunden.ID = 2462
	AND Traeger.RentoCodID > -1
	AND Traeger.Status <> 'I'