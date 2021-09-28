SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Traeger.Traeger AS [Träger-Nr], Traeger.Nachname, Traeger.Vorname, Traeger.Hinweise
FROM Traeger
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND StandBer.BereichID = 100
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
WHERE Traeger.Status != N'I'
  AND Vsa.Status != N'I'
  AND Kunden.Status != N'I'
  AND Produktion.SuchCode = N'SA22'
  AND Traeger.Hinweise IS NOT NULL;