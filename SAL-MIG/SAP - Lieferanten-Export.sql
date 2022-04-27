SELECT Lief.LiefNr, Lief.SuchCode AS Stichwort, Lief.Name1, Lief.Name2, Lief.Name3, Lief.Strasse, Lief.Land, Lief.PLZ, Lief.Ort, Lief.[Status], Wae.Code AS Währung, Wae.IsoCode AS IsoWährung, Lief.KundenNr, ZahlZiel.ZahlZiel AS Zahlungsziel, ZahlZiel.ZahlZielBez AS Zahlungszielbezeichnung, Lief.UStIdNr, LiefType.LiefTypeBez AS Lieferantentyp, Incoterm.IncotermBez AS [Incoterm (Internationale Handelsklausel)], Lief.LiefBed AS Lieferbedingungen, Lief.ILN AS GLN, Lief.LieferantSeit
FROM Lief
JOIN Wae ON Lief.WaeID = Wae.ID
JOIN ZahlZiel ON Lief.ZahlZielID = ZahlZiel.ID
JOIN LiefType ON Lief.LiefTypeID = LiefType.ID
JOIN Incoterm ON Lief.IncotermID = Incoterm.ID
WHERE Lief.ID > 0
  AND Lief.Status = N'A';