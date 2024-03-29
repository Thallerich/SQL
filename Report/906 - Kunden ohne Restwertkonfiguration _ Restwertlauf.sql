SELECT Firma.SuchCode AS Firma, Kunden.KdNr, Kunden.SuchCode AS Kunde, Holding.Holding, KdGf.KurzBez AS Geschäftsbereich, RwConfig.RwConfigBez$LAN$ AS Restwertkonfiguration, RwLauf.RwLaufBez$LAN$ AS Restwertlauf, Kunden.FakFehlteil AS [Fehlteile abrechnen?], [Kundenservice-Mitarbeiter] = (
  SELECT TOP 1 Mitarbei.Name
  FROM KdBer
  JOIN Mitarbei ON KdBer.ServiceID = Mitarbei.ID
  WHERE KdBer.KundenID = Kunden.ID
    AND KdBer.Status = N'A'
    AND KdBer.ServiceID > 0
  GROUP BY Mitarbei.Name
  ORDER BY COUNT(KdBer.ID) DESC
)
FROM Kunden
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN RwConfig ON Kunden.RWConfigID = RwConfig.ID
JOIN RwLauf ON Kunden.RwLaufID = RwLauf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
WHERE Kunden.SichtbarID IN ($SICHTBARIDS$)
  AND Kunden.FirmaID IN ($1$)
  AND (($2$ = 1 AND Kunden.RWConfigID < 0) OR $2$ = 0)
  AND (($3$ = 1 AND Kunden.RWLaufID < 0) OR $2$ = 0)
  AND EXISTS (
    SELECT Traeger.*
    FROM Traeger
    JOIN Vsa ON Traeger.VsaID = Vsa.ID
    WHERE Vsa.KundenID = Kunden.ID
      AND Traeger.Altenheim = 0
  );