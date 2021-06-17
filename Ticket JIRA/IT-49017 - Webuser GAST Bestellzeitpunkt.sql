SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, KdGf.KurzBez AS Geschäftsbereich, Standort.Bez AS Hauptstandort, WebUser.UserName, WebUser.FullName, WebUser.MaxBestellzeit AS [alt - spätester Bestellzeitpunkt], WebUser.MaxBestellTag AS [alt - spätester Bestell-Tag], N'11:00:00' AS [neu - spätester Bestellzeitpunkt], 1 AS [neu - spätester Bestell-Tag]
FROM WebUser
JOIN Kunden ON WebUser.KundenID = Kunden.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
WHERE Standort.SuchCode = N'UKLU'
  AND KdGf.KurzBez = N'GAST'
  AND (WebUser.MaxBestellzeit != N'11:00:00' OR WebUser.MaxBestellTag != 1)
  AND Kunden.Status = N'A'
  AND WebUser.Status = N'A';

GO

UPDATE WebUser SET MaxBestellzeit = CAST(N'11:00:00' AS time), MaxBestellTag = 1
WHERE ID IN (
  SELECT WebUser.ID
  FROM WebUser
  JOIN Kunden ON WebUser.KundenID = Kunden.ID
  JOIN Standort ON Kunden.StandortID = Standort.ID
  JOIN KdGf ON Kunden.KdGfID = KdGf.ID
  WHERE Standort.SuchCode = N'UKLU'
    AND KdGf.KurzBez = N'GAST'
    AND (WebUser.MaxBestellzeit != N'11:00:00' OR WebUser.MaxBestellTag != 1)
    AND Kunden.Status = N'A'
    AND WebUser.Status = N'A'
);

GO