WITH Kundenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'KUNDEN')
),
Ansprechpartner AS (
  SELECT Sachbear.TableID AS KundenID, Sachbear.Anrede, Sachbear.Titel, Sachbear.Vorname, Sachbear.Name, Sachbear.SerienAnrede, Sachbear.eMail, Sachbear.Telefon, Sachbear.Abteilung, Sachbear.Position, Rollen.RollenBez$LAN$ AS Rolle
  FROM Sachbear
  LEFT JOIN SachRoll ON SachRoll.SachBearID = SachBear.ID
  LEFT JOIN Rollen ON SachRoll.RollenID = Rollen.ID
  WHERE Sachbear.Status = N'A'
    AND Sachbear.TableName = N'KUNDEN'

  UNION ALL

  SELECT Vsa.KundenID AS KundenID, Sachbear.Anrede, Sachbear.Titel, Sachbear.Vorname, Sachbear.Name, Sachbear.SerienAnrede, Sachbear.eMail, Sachbear.Telefon, Sachbear.Abteilung, Sachbear.Position, Rollen.RollenBez$LAN$ AS Rolle
  FROM Sachbear
  JOIN Vsa ON Sachbear.TableID = Vsa.ID
  LEFT JOIN SachRoll ON SachRoll.SachBearID = SachBear.ID
  LEFT JOIN Rollen ON SachRoll.RollenID = Rollen.ID
  WHERE Sachbear.Status = N'A'
    AND Sachbear.TableName = N'VSA'
)
SELECT DISTINCT KdGf.KurzBez AS Geschäftsbereich, Firma.Bez AS Firma, Standort.Bez AS Hauptstandort, Kundenstatus.StatusBez AS Kundenstatus, ABC.ABCBez AS Kundenklasse, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kunden.Name1 AS Adresszeile1, Kunden.Name2 AS Adresszeile2, Kunden.Name3 AS Adresszeile3, Kunden.Strasse, Kunden.Land, Kunden.PLZ, Kunden.Ort, Kunden.KundeSeit AS [Kunde seit], ZahlZiel.ZahlZielBez$LAN$ AS Zahlungsziel, Ansprechpartner.Anrede, Ansprechpartner.Titel, Ansprechpartner.Vorname, Ansprechpartner.Name, Ansprechpartner.SerienAnrede, Ansprechpartner.eMail, Ansprechpartner.Telefon, Ansprechpartner.Abteilung, Ansprechpartner.Position, Ansprechpartner.Rolle
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN Kundenstatus ON Kunden.Status = Kundenstatus.Status
JOIN ABC ON Kunden.ABCID = ABC.ID
JOIN ZahlZiel ON Kunden.ZahlZielID = ZahlZiel.ID
LEFT JOIN Ansprechpartner ON Ansprechpartner.KundenID = Kunden.ID
WHERE Kunden.AdrArtID = 1
  AND Kundenstatus.ID IN ($3$)
  AND KdGf.ID IN ($1$)
  AND Kunden.StandortID IN ($2$)
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
ORDER BY Kunden.KdNr, Ansprechpartner.Name;