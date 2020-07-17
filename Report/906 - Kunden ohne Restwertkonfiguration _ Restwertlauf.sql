SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Holding.Holding, KdGf.KurzBez AS Geschäftsbereich, RwConfig.RwConfigBez$LAN$ AS Restwertkonfiguration, RwLauf.RwLaufBez$LAN$ AS Restwertlauf, Kunden.FakFehlteil AS [Fehlteile abrechnen?]
FROM Kunden
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN RwConfig ON Kunden.RWConfigID = RwConfig.ID
JOIN RwLauf ON Kunden.RwLaufID = RwLauf.ID
WHERE Kunden.SichtbarID IN ($SICHTBARIDS$)
  AND (($1$ = 1 AND Kunden.RWConfigID < 0) OR $1$ = 0)
  AND (($2$ = 1 AND Kunden.RWLaufID < 0) OR $2$ = 0)
  AND EXISTS (
    SELECT Traeger.*
    FROM Traeger
    JOIN Vsa ON Traeger.VsaID = Vsa.ID
    WHERE Vsa.KundenID = Kunden.ID
      AND Traeger.Altenheim = 0
  );