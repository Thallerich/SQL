SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Standort.SuchCode AS Hauptstandort, Bereich.BereichBez AS Kundenbereich, Vertreter.Name AS [Vertreter aktuell], _IT53876.Nachname + ', ' + _IT53876.Vorname AS [Vertreter neu], Betreuer.Name AS [Betreuer aktuell], _IT53876.Nachname + ', ' + _IT53876.Vorname AS [Betreuer neu]
FROM KdBer
JOIN Kunden ON KdBer.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN Mitarbei AS Vertreter ON KdBer.VertreterID = Vertreter.ID
JOIN Mitarbei AS Betreuer ON KdBer.BetreuerID = Betreuer.ID
JOIN _IT53876 ON Kunden.PLZ = _IT53876.PLZ COLLATE Latin1_General_CS_AS
WHERE Firma.SuchCode = N'FA14'
  AND Kunden.AdrArtID = 1
  AND Kunden.Status = N'A';

-- TODO: KdBer updaten
-- TODO: VsaBer zu KdBer updaten - Output-Table verwenden!