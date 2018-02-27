SELECT Lief.LiefNr, Lief.SuchCode, ISNULL(Lief.Name1, '') AS Name1, ISNULL(Lief.Name2, '') AS Name2, ISNULL(Lief.Name3, '') AS Name3, ISNULL(Lief.Strasse, '') AS Strasse, ISNULL(Lief.Land, '') AS Land, ISNULL(Lief.PLZ, '') AS PLZ, ISNULL(Lief.Ort, '') AS Ort, ISNULL(Lief.LiefBed, '') AS Lieferbedingungen, IIF(Incoterm.ID < 0, '', Incoterm.IncotermBez) AS Incoterm, ZahlZiel.ZahlZielBez AS Zahlungsziel, ISNULL(Lief.UstIDNr, '') AS UstIDNr, ISNULL(Sachbear.Anrede, '') AS Anrede, ISNULL(Sachbear.Vorname, '') AS Vorname, ISNULL(Sachbear.Name, '') AS Nachname, ISNULL(Sachbear.Position, '') AS Position, ISNULL(Sachbear.Telefon, '') AS Telefon, ISNULL(Sachbear.Telefax, '') AS Telefax, ISNULL(Sachbear.Mobil, '') AS Mobil, ISNULL(Sachbear.eMail, '') AS eMail, ISNULL(Sachbear.SerienAnrede, '') AS SerienAnrede
FROM Lief
JOIN Incoterm ON Lief.IncotermID = Incoterm.ID
JOIN ZahlZiel ON Lief.ZahlZielID = ZahlZiel.ID
LEFT OUTER JOIN Sachbear ON Sachbear.TableID = Lief.ID AND Sachbear.TableName = N'LIEF'
WHERE Lief.Status = N'A'
  AND Lief.ID > 0