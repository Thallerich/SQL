WITH Kundenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'KUNDEN')
)
--SELECT Firma.SuchCode AS Firma, KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kundenstatus.StatusBez AS Kundenstatus, RKoOut.RkoOutBez AS [Rechnungsausgabeart bisher]
UPDATE Kunden SET RKoOutID = 18
FROM Kunden
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN RKoOut ON Kunden.RKoOutID = RKoOut.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
JOIN Kundenstatus ON Kunden.[Status] = Kundenstatus.[Status]
WHERE RKoOut.PapierDruck = 1
  AND RKoOut.EMailVersand = 0
  AND Kunden.ID > 0
  AND KdGf.[Status] = N'A'
  AND KdGf.KurzBez <> N'INT'
  AND Firma.SuchCode IN (N'SMW', N'WOMI', N'UKLU');