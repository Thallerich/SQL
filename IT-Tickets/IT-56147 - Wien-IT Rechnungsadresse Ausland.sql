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

GO

WITH Kundenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'KUNDEN'
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Kundenstatus.StatusBez AS [Status Kunde], Abteil.Abteilung AS Kostenstelle, Abteil.Bez AS Kostenstellenbezeichnung, RechAdr.Name1 AS [Adresszeile 1], RechAdr.Name2 AS [Adresszeile 2], RechAdr.Name3 AS [Adresszeile 3], RechAdr.Strasse, RechAdr.Land, RechAdr.PLZ, RechAdr.Ort, RKoOut.RkoOutBez AS Rechnungsausgabeart
FROM Abteil
JOIN Kunden ON Abteil.KundenID = Kunden.ID
JOIN Kundenstatus ON Kunden.Status = Kundenstatus.Status
JOIN RKoOut ON Kunden.RKoOutID = RKoOut.ID
JOIN RechAdr ON Abteil.RechAdrID = RechAdr.ID
WHERE Kunden.AdrArtID = 1
  AND Abteil.Code IN (N'R', N'S')
  AND RKoOut.VersandPath LIKE N'\\salshdsvm09_681.salres.com\advpapp_file\AdvanTex\Data\Export\WienIT\%'
  AND (RechAdr.Land != N'AT' OR RechAdr.Land IS NULL OR (RechAdr.Land = N'AT' AND LEN(RechAdr.PLZ) != 4));

GO

WITH Kundenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'KUNDEN'
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Kundenstatus.StatusBez AS [Status Kunde], Vsa.VsaNr AS [VSA-Nummer], Vsa.Name1 AS [Adresszeile 1], Vsa.Name2 AS [Adresszeile 2], Vsa.Name3 AS [Adresszeile 3], Vsa.Strasse, Vsa.Land, Vsa.PLZ, Vsa.Ort, RKoOut.RkoOutBez AS Rechnungsausgabeart
FROM Abteil
JOIN Kunden ON Abteil.KundenID = Kunden.ID
JOIN Kundenstatus ON Kunden.Status = Kundenstatus.Status
JOIN RKoOut ON Kunden.RKoOutID = RKoOut.ID
JOIN Vsa ON Abteil.VsaID = Vsa.ID
WHERE Kunden.AdrArtID = 1
  AND Abteil.Code = N'V'
  AND RKoOut.VersandPath LIKE N'\\salshdsvm09_681.salres.com\advpapp_file\AdvanTex\Data\Export\WienIT\%'
  AND (Vsa.Land != N'AT' OR Vsa.Land IS NULL OR (Vsa.Land = N'AT' AND LEN(Vsa.PLZ) != 4));

GO