WITH Kundenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'KUNDEN')
),
VsaStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'VSA')
),
VsaBerStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'VSABER')
)
SELECT Firma.Bez AS Firma,
  KdGf.Kurzbez AS Geschäftsbereich,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Kunden.Name1,
  Kunden.Name2,
  Kunden.Name3,
  Kunden.Strasse,
  Kunden.Land,
  Kunden.PLZ,
  Kunden.Ort,
  Kundenstatus.StatusBez AS Kundenstatus,
  Standort.Bez AS Hauptstandort,
  Kunden.UStIdNr,
  Vsa.VsaNr,
  Vsa.SuchCode AS [VSA-Stichwort],
  Vsa.Bez AS [VSA-Bezeichnung],
  Vsa.Strasse AS [VSA-Strasse],
  Vsa.Land AS [VSA-Land],
  Vsa.PLZ AS [VSA-PLZ],
  Vsa.Ort AS [VSA-Ort],
  VsaStatus.StatusBez AS [VSA-Status],
  Bereich.BereichBez$LAN$ AS Produktbereich,
  VsaBerStatus.StatusBez AS [VSA-Bereich Status],
  Betreuer.Name AS [Betreuer VSA-Bereich],
  Vertrieb.Name AS [Vertrieb VSA-Bereich],
  Kundenservice.Name AS [Kundenservice VSA-Bereich],
  Abc.ABC AS [ABC-Klasse],
  Sachbear.Name AS [Ansprechpartner VSA],
  Sachbear.Telefon,
  Sachbear.eMail,
  Sachbear.[Position],
  Rollen.RollenBez AS Rolle,
  StandKon.StandKonBez$LAN$ AS [Standort-Konfiguration]
FROM Kunden
JOIN Vsa ON Vsa.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
JOIN VsaBer ON VsaBer.VsaID = Vsa.ID
JOIN KdBer ON VsaBer.KdBerID = KdBer.ID
JOIN Mitarbei AS Betreuer ON VsaBer.BetreuerID = Betreuer.ID
JOIN Mitarbei AS Vertrieb ON VsaBer.VertreterID = Vertrieb.ID
JOIN Mitarbei AS Kundenservice ON VsaBer.ServiceID = Kundenservice.ID
JOIN Bereich ON kdBer.BereichID = Bereich.ID
JOIN Abc ON Kunden.AbcID = Abc.ID
JOIN Kundenstatus ON Kundenstatus.Status = Kunden.Status
JOIN Vsastatus ON Vsastatus.Status = Vsa.Status
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN VsaBerStatus ON VsaBer.Status = VsaBerStatus.Status
JOIN StandKon ON Vsa.StandKonID = StandKon.ID
LEFT JOIN Sachbear ON Sachbear.TableID = Vsa.ID AND Sachbear.TableName = N'VSA'
LEFT JOIN SachRoll ON SachRoll.SachbearID = Sachbear.ID
LEFT JOIN Rollen ON SachRoll.RollenID = Rollen.ID
WHERE KdGf.ID IN ($1$) 
  AND Kundenstatus.ID IN ($2$)
  AND VsaStatus.ID IN ($3$)
  AND Standort.ID IN ($4$)
  AND Bereich.ID IN ($5$)
  AND Kunden.AdrArtID = 1
  AND Kunden.SichtbarID IN ($SICHTBARIDS$);