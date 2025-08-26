SELECT DISTINCT Kunden.KdNr, 
  Kunden.SuchCode AS Kunde, 
  Vsa.VsaNr, 
  Vsa.Bez AS [VSA-Bezeichnung],
  VSA.Suchcode,
  ISNULL(VSA.Strasse,'') +' '+ ISNULL(VSA.PLZ,'') + ' ' + ISNULL(VSA.Ort,'')  as Adresse,
  Bereich.BereichBez$LAN$ AS Produktbereich, 
  Mitarbei.Name AS [Kundenservice-Mitarbeiter],
  Touren.Tour, 
  Touren.Bez AS Tourbezeichnung, 
  Wochentag = 
  CASE Touren.Wochentag
    WHEN 1 THEN N'Montag'
    WHEN 2 THEN N'Dienstag'
    WHEN 3 THEN N'Mittwoch'
    WHEN 4 THEN N'Donnerstag'
    WHEN 5 THEN N'Freitag'
    WHEN 6 THEN N'Samstag'
    WHEN 7 THEN N'Sonntag'
    ELSE N'unbekannt'
  END,
  VsaTour.Folge, 
  VsaTour.Holen, 
  VsaTour.Bringen, 
  VsaTour.MinBearbTage AS Bearbeitungstage, 
  Standort.Bez AS [Expedition]
FROM VsaTour
JOIN Touren ON VsaTour.TourenID = Touren.ID
JOIN Vsa ON VsaTour.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Standort ON Touren.ExpeditionID = Standort.ID
JOIN KdBer ON VsaTour.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN Mitarbei ON KdBer.ServiceID = Mitarbei.ID
WHERE VsaTour.ID > 0
AND VsaTour.VsaID > 0
AND Kunden.Status = N'A'
AND Vsa.Status = N'A'
AND VSATour.VonDatum <= GETDATE() 
AND VSATour.BisDatum >= GETDATE() 
AND Kunden.KdGfID IN ($1$)
AND Vsa.StandKonID IN ($2$);