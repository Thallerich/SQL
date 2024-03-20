WITH VsaStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'VSA'
),
Vertragstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'VERTRAG'
)
SELECT Firma.SuchCode AS Firma,
  KdGf.KurzBez AS Geschäftsbereich,
  [Zone].ZonenCode AS Vertriebszone,
  Holding.Holding,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Vsa.VsaNr,
  Vsa.Bez AS [VSA-Bezeichnung],
  Vsa.Name1 AS [Adresszeile 1],
  Vsa.Name2 AS [Adresszeile 2],
  Vsa.Name3 AS [Adresszeile 3],
  Vsa.Strasse,
  Vsa.Land,
  Vsa.PLZ,
  Vsa.Ort,
  VsaStatus.StatusBez AS [Status VSA],
  Standort.Bez AS [Hauptstandort Kunde],
  StandKon.StandKonBez$LAN$ AS [Standort-Konfiguration VSA],
  Sichtbar.Bez AS [Sichtbarkeit VSA],
  Bereich.BereichBez$LAN$ AS [VSA-Bereich],
  Kundenservice.Name AS Kundenservice,
  Betreuer.Name AS Kundenbetreuer,
  Vertreter.Name AS Vertrieb,
  Vertrag.VertragLfdNr AS [Laufende Nr. Vertrag],
  Vertragstatus.StatusBez AS [Status Vertrag],
  Vertrag.VertragAbschluss AS [Abschluss-Datum],
  Vertrag.VertragStart AS [Start-Datum],
  Vertrag.VertragEndeMoegl AS [nächstmögliches Ende],
  Vertrag.VertragEnde AS [reguläres Ende],
  Vertrag.VertragKuendEin AS [Vertrag-Kündingung eingangen am],
  Vertrag.VertragKuendZum AS [Vertrag-Kündigung zum],
  Vertrag.VertragLetzteAnl AS [nicht mehr beliefern ab],
  Vertrag.LetztePeDatum AS [letzte Preiserhöhung am],
  Vertrag.LetztePeProz AS [letzte Preiserhöhung Prozentsatz],
  Vsa._KuendZum AS [VSA gekündigt zum],
  Vsa.ID AS VsaID
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN StandKon ON Vsa.StandKonID = StandKon.ID
JOIN Sichtbar ON Vsa.SichtbarID = Sichtbar.ID
JOIN VsaBer ON VsaBer.VsaID = Vsa.ID
JOIN KdBer ON VsaBer.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN Mitarbei AS Kundenservice ON VsaBer.ServiceID = Kundenservice.ID
JOIN Mitarbei AS Betreuer ON VsaBer.BetreuerID = Betreuer.ID
JOIN Mitarbei AS Vertreter ON VsaBer.VertreterID = Vertreter.ID
JOIN Vertrag ON KdBer.VertragID = Vertrag.ID
JOIN Vertragstatus ON Vertrag.[Status] = Vertragstatus.[Status]
JOIN VsaStatus ON Vsa.[Status] = VsaStatus.[Status]
WHERE Kunden.[Status] = N'A'
  AND Kunden.AdrArtID = 1
  AND Firma.ID IN ($1$)
  AND KdGf.ID IN ($2$)
  AND [Zone].ID IN ($3$)
  AND Kunden.StandortID IN ($4$)
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
  AND Vsa._KuendZum IS NOT NULL
  AND Vsa._KuendZum >= $5$;