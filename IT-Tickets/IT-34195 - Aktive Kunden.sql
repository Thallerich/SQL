SELECT DISTINCT KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kunden.Name1 AS Adresszeile1, Kunden.Name2 AS Adresszeile2, Kunden.Name3 AS Adresszeile3, Kunden.Strasse, Kunden.Land, Kunden.PLZ, Kunden.Ort, Sachbear.Vorname AS [Ansprechpartner Vorname], Sachbear.Name AS [Ansprechpartner Nachname], Sachbear.SerienAnrede AS [Serienbrief-Anrede], Sachbear.Telefon, Sachbear.eMail, Bereich.Bereich AS Produktbereich, Expedition.SuchCode AS Expedition, Expedition.Bez AS Expeditionsstandort, Produktion.SuchCode AS Produktion, Produktion.Bez AS Produktionsstandort
FROM Vsa
JOIN VsaBer ON VsaBer.VsaID = Vsa.ID
JOIN KdBer ON VsaBer.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
JOIN Standort AS Expedition ON StandBer.ExpeditionID = Expedition.ID
JOIN Standort AS Produktion ON StandBer.ProduktionID = Produktion.ID
JOIN Sachbear ON Sachbear.TableID = Kunden.ID AND Sachbear.TableName = N'KUNDEN'
WHERE Kunden.Status = N'A'
  AND Vsa.Status = N'A'
  AND KdBer.Status = N'A'
  AND VsaBer.Status = N'A'
  AND KdGf.Status = N'A'
  AND Sachbear.Status = N'A'
  AND Kunden.SichtbarID != (SELECT ID FROM Sichtbar WHERE Bez = N'IT');