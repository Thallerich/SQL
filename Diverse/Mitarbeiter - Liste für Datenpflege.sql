SELECT Mitarbei.ID AS MitarbeiID, Mitarbei.Nachname, Mitarbei.Vorname, Mitarbei.Titel, Mitarbei.Strasse, Mitarbei.Land, Mitarbei.PLZ, Mitarbei.Ort, Mitarbei.Telefon, Mitarbei.Mobil, Mitarbei.eMail, IIF(Standort.ID = -1, NULL, Standort.Bez) AS Standort, IIF(Firma.ID = -1, NULL, Firma.Bez) AS Firma, IIF(MitarAbt.ID = -1, NULL, MitarAbt.MitarAbtBez) AS Abteilung
FROM Mitarbei
JOIN Standort ON Mitarbei.StandortID = Standort.ID
JOIN Firma ON Mitarbei.FirmaID = Firma.ID
JOIN MitarAbt ON Mitarbei.MitarAbtID = MitarAbt.ID
WHERE Mitarbei.Status = N'A'
  AND Mitarbei.IsAdvanTexUser = 1
  AND Mitarbei.LastLogin > N'2022-06-01'
  AND Mitarbei.Geschlecht IN (N'M', N'W');