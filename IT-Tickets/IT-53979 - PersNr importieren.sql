SELECT COUNT(*) FROM _persnrimport;
GO

--SELECT Traeger.Traeger, Traeger.Nachname, Traeger.Vorname, Traeger.PersNr, Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, _persnrimport.*
UPDATE Traeger SET PersNr = _persnrimport.PersNr
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON Traeger.AbteilID = Abteil.ID
JOIN _persnrimport ON UPPER(Traeger.Nachname + N' ' + Traeger.Vorname) COLLATE Latin1_General_CS_AS = UPPER(_persnrimport.Name)
WHERE Kunden.KdNr = 2511145
  AND Traeger.Status != N'I';
GO