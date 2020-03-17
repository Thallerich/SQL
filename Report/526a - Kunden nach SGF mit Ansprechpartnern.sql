WITH Kundenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'KUNDEN')
),
Ansprechpartner AS (
  SELECT Sachbear.TableID AS KundenID, Sachbear.Anrede, Sachbear.Titel, Sachbear.Vorname, Sachbear.Name, Sachbear.SerienAnrede, Sachbear.eMail, Sachbear.Telefon
  FROM Sachbear
  WHERE Sachbear.TableName = N'KUNDEN'
    AND Sachbear.Status = N'A'

  UNION ALL

  SELECT Vsa.KundenID, Sachbear.Anrede, Sachbear.Titel, Sachbear.Vorname, Sachbear.Name, Sachbear.SerienAnrede, Sachbear.eMail, Sachbear.Telefon
  FROM Sachbear
  JOIN Vsa ON Sachbear.TableID = Vsa.ID
  WHERE Sachbear.TableName = N'VSA'
    AND Sachbear.Status = N'A'
)
SELECT DISTINCT KdGf.KurzBez AS SGF, Firma.Bez AS Firma, Standort.Bez AS Hauptstandort, Kundenstatus.StatusBez AS Kundenstatus, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kunden.Name1 AS Adresszeile1, Kunden.Name2 AS Adresszeile2, Kunden.Name3 AS Adresszeile3, Kunden.Strasse, Kunden.Land, Kunden.PLZ, Kunden.Ort, Ansprechpartner.Anrede, Ansprechpartner.Titel, Ansprechpartner.Vorname, Ansprechpartner.Name, Ansprechpartner.SerienAnrede, Ansprechpartner.eMail, Ansprechpartner.Telefon
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN Kundenstatus ON Kunden.Status = Kundenstatus.Status
JOIN Ansprechpartner ON Ansprechpartner.KundenID = Kunden.ID
WHERE Kunden.AdrArtID = 1
  AND Kundenstatus.ID IN ($3$)
  AND KdGf.ID IN ($1$)
  AND Kunden.StandortID IN ($2$)
ORDER BY Kunden.KdNr