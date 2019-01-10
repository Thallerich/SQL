WITH Kundenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'KUNDEN')
),
Vsastatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'VSA')
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
  Vsastatus.StatusBez AS [VSA-Status],
  Bereich.BereichBez$LAN$ AS Produktbereich,
  ISNULL(BetreuerKdBer.Nachname + N', ', N'') + ISNULL(BetreuerKdBer.Vorname, N'') AS [Betreuer Kundenbereich],
  ISNULL(VertriebKdBer.Nachname + N', ', N'') + ISNULL(VertriebKdBer.Vorname, N'') AS [Vertrieb Kundenbereich],
  ISNULL(BetreuerVsaBer.Nachname + N', ', N'') + ISNULL(BetreuerVsaBer.Vorname, N'') AS [Betreuer VSA-Bereich],
  ISNULL(VertriebVsaBer.Nachname + N', ', N'') + ISNULL(VertriebVsaBer.Vorname, N'') AS [Vertrieb VSA-Bereich],
  Abc.ABC AS [ABC-Klasse]
FROM Kunden
JOIN Vsa ON Vsa.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGFID = KdGf.ID
JOIN KdBer oN KdBer.KundenID = Kunden.ID
JOIN Mitarbei AS BetreuerKdBer ON KdBer.BetreuerID = BetreuerKdBer.ID
JOIN Mitarbei AS VertriebKdBer ON KdBer.VertreterID = VertriebKdBer.ID
JOIN VsaBer ON VsaBer.VsaID = Vsa.ID AND VsaBer.KdBerID = KdBer.ID
JOIN Mitarbei AS BetreuerVsaBer ON KdBer.BetreuerID = BetreuerVsaBer.ID
JOIN Mitarbei AS VertriebVsaBer ON KdBer.VertreterID = VertriebVsaBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN Abc ON Kunden.AbcID = Abc.ID
JOIN Kundenstatus ON Kundenstatus.Status = Kunden.Status
JOIN Vsastatus ON Vsastatus.Status = Vsa.Status
JOIN Standort ON Kunden.StandortID = Standort.ID
WHERE KdGf.ID IN ($1$) 
  AND Kundenstatus.ID IN ($2$)
  AND Vsastatus.ID IN ($3$)
  AND Standort.ID IN ($4$)
  AND Bereich.ID IN ($5$)
  AND Kunden.AdrArtID = 1
  AND Kunden.SichtbarID IN ($SICHTBARIDS$);