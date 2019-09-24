WITH LiefStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'LIEF')
)
SELECT Lief.LiefNr, LiefStatus.StatusBez AS Lieferantenstatus, Lief.SuchCode AS Lieferant, Lief.Name1, Lief.Name2, Lief.Name3, Lief.Strasse, Lief.Land, Lief.PLZ, Lief.Ort, Lief.BankKonto, Lief.BankLZ, Lief.BankName
FROM Lief
JOIN LiefStatus ON Lief.[Status] = LiefStatus.[Status]
JOIN ZahlZiel ON Lief.ZahlZielID = ZahlZiel.ID
JOIN Incoterm ON Lief.IncotermID = Incoterm.ID
WHERE Lief.LiefNr IN (20, 31, 48, 68, 98, 106, 113, 161, 192, 266, 271, 280, 281, 306, 3328711, 3530185, 3530302, 3530400, 3530518, 3531405, 3532051, 3532176, 3532189, 3532201, 3532336, 3532409, 3533033, 3533402, 3534000, 3534017, 3534078, 3534155, 35358097, 35358098, 35358107, 35358154, 35358155, 35358156, 35358158, 35358159, 35358160, 35358161);