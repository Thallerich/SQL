SELECT Holding.Holding,
       Holding.Bez AS [Bezeichnung Holding],
       Kundenstatus.StatusBez AS [Status Kunde],
       Kunden.KdNr,
       Kunden.SuchCode AS Kunde,
       Kunden.Name1 AS [Kunde Adresszeile 1],
       Kunden.Name2 AS [Kunde Adresszeile 2],
       Kunden.Name3 AS [Kunde Adresszeile 3],
       Abteilstatus.StatusBez AS [Status Kostenstelle],
       Abteil.Abteilung AS Kostenstelle,
       Abteil.Bez AS Kostenstellenbezeichnung,
       CASE Abteil.Code
         WHEN 'K' THEN N'Sammelrechnung an Kundenadresse'
         WHEN 'A' THEN N'Einzelrechnung an Kundenadresse'
         WHEN 'V' THEN N'Sammelrechnung an eine Versandanschrift'
         WHEN 'R' THEN N'Sammelrechnung an separate Rechnungsanschrift'
         WHEN 'S' THEN N'Einzelrechnung an separate Rechnungsanschrift'
         ELSE N'(unknown)'
       END AS Rechnungsempfänger,
       RechAdr.Name1 AS [Rechnungsadresse Zeile 1],
       RechAdr.Name2 AS [Rechnungsadresse Zeile 2],
       RechAdr.Name3 AS [Rechnungsadresse Zeile 3]
FROM Abteil
JOIN Kunden ON Abteil.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'KUNDEN'
) AS Kundenstatus ON Kunden.[Status] = Kundenstatus.[Status]
JOIN (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'ABTEIL'
) AS Abteilstatus ON Abteil.[Status] = Abteilstatus.[Status]
LEFT JOIN RechAdr ON Abteil.RechAdrID = RechAdr.ID
WHERE Holding.Holding IN (N'HAND', N'HANDSM', N'HANDSB', N'HANDVL', N'HOGD', N'HOGDTK', N'HOGDSH', N'HOGDIT', N'HGP')
  AND Kunden.AdrArtID = 1;