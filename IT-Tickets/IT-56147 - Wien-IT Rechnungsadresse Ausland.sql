WITH Kundenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'KUNDEN'
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Kundenstatus.StatusBez AS [Status Kunde], Kunden.Name1 AS [Adresszeile 1], Kunden.Name2 AS [Adresszeile 2], Kunden.Name3 AS [Adresszeile 3], Kunden.Strasse, Kunden.Land, Kunden.PLZ, Kunden.Ort, RKoOut.RkoOutBez AS Rechnungsausgabeart
FROM Kunden
JOIN Kundenstatus ON Kunden.Status = Kundenstatus.Status
JOIN RKoOut ON Kunden.RKoOutID = RKoOut.ID
WHERE Kunden.AdrArtID = 1
  AND RKoOut.VersandPath LIKE N'\\salshdsvm09_681.salres.com\advpapp_file\AdvanTex\Data\Export\WienIT\%'
  AND (Kunden.Land != N'AT' OR Kunden.Land IS NULL OR (Kunden.Land = N'AT' AND LEN(Kunden.PLZ) != 4));