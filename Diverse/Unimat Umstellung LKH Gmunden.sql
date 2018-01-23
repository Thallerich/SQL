/*
UPDATE t SET TraegerID = IIF(Vsa.Bez = 'Unimat1', 6530084, 6530085)
FROM Kunden, VSA, Teile t
WHERE Kunden.ID = Vsa.KundenID
	AND VSA.ID = t.VSAID
	AND Kunden.KdNr = 7240
	AND Vsa.Bez IN ('Unimat1', 'Unimat2');	
	
UPDATE ta SET TraegerID = IIF(Vsa.Bez = 'Unimat1', 6530084, 6530085)
FROM Kunden, VSA, TraeArti ta
WHERE Kunden.ID = VSA.KundenID
	AND VSA.ID = ta.VSAID
	AND Kunden.KdNr = 7240
	AND VSA.Bez IN ('Unimat1', 'Unimat2');
*/

--Pool 1

UPDATE Teile SET TraegerID = 6530084
FROM Teile, Vsa, Kunden
WHERE Teile.Barcode IN (/*Liste*/)
 AND Teile.VsaID = Vsa.ID
 AND Vsa.KundenID = Kunden.ID
 AND Kunden.KdNr = 7240
 AND Vsa.Bez = 'Unimat1'

Bei Teile von Träger POOL1:
Funktionen -> Mehrfachfunktionen -> alles auf einen Träger

--Pool 2
	
UPDATE Teile SET TraegerID = 6530085
FROM Teile, Vsa, Kunden
WHERE Teile.Barcode IN (/*Liste*/)
	AND Teile.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Kunden.KdNr = 7240
	AND Vsa.Bez = 'Unimat2'

Bei Teile von Träger POOL2:
Funktionen -> Mehrfachfunktionen -> alles auf einen Träger

--Pool Überschuss

UPDATE Teile SET TraegerID = 6561672
FROM Teile, Vsa, Kunden
WHERE Teile.Barcode NOT IN (/*Liste*/)
	AND Teile.VsaID = Vsa.ID
	AND Vsa.KundenID = Kunden.ID
	AND Kunden.KdNr = 7240
	AND Vsa.Bez IN ('Unimat2', 'Unimat1')
	AND Teile.TraegerID NOT IN (6530084, 6530085)
	
Bei Teile von Träger Gmunden Poolüberschuß:
Funktionen -> Mehrfachfunktionen -> alles auf einen Träger