SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, KdGf.KurzBez AS Geschäftsbereich, Standort.Bez AS Hauptstandort, WebUser.UserName, WebUser.FullName, WebUser.MaxBestellzeit AS [spätester Bestellzeitpunkt]
FROM WebUser
JOIN Kunden ON WebUser.KundenID = Kunden.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
WHERE Standort.SuchCode = N'UKLU'
  AND KdGf.KurzBez = N'GAST'
  AND WebUser.MaxBestellzeit != N'11:00:00'
  AND Kunden.Status = N'A'
  AND WebUser.Status = N'A';