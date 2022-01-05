SELECT Firma.SuchCode AS Firma, [Zone].ZonenCode AS Vertriebszone, Standort.SuchCode AS Hauptstandort, Kunden.KdNr, Kunden.SuchCode AS Kunde, IIF(DrLauf.ID < 0, NULL, DrLauf.Bez) AS Drucklauf
FROM Kunden
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN DrLauf ON Kunden.DrLaufID = DrLauf.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN Standort ON Kunden.StandortID = Standort.ID
WHERE Firma.ID IN ($2$)
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
  AND (($1$ = 1 AND Kunden.DrLaufID < 0) OR $1$ = 0)
  AND EXISTS (
    SELECT KdBer.*
    FROM KdBer
    WHERE KdBer.KundenID = Kunden.ID
  );