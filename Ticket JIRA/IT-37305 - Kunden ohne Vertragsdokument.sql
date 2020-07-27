SELECT Kunden.KdNr, Kunden.SuchCode
FROM Kunden
JOIN Standort ON Kunden.StandortID = Standort.ID
WHERE Standort.SuchCode = N'SMS'
  AND NOT EXISTS (
    SELECT Document.*
    FROM Document
    WHERE Document.LinkTable = N'KUNDEN'
      AND Document.LinkID = Kunden.ID
      AND Document.ExternalFileName LIKE N'\\sal.co.at\daten\custcon\%'
  )
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1;