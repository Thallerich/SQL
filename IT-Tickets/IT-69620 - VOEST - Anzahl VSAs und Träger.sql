SELECT Holding.Holding, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kunden.AdressBlock, COUNT(DISTINCT Vsa.ID) AS [Anzahl VSAs], COUNT(DISTINCT Traeger.ID) AS [Anzahl Träger]
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
LEFT JOIN Traeger ON Traeger.VsaID = Vsa.ID
WHERE Holding.Holding IN (N'VOES', N'VOESAN', N'VOESLE')
  AND ISNULL(Traeger.Traeger, N'A') != N'I'
  AND Vsa.[Status] = N'A'
  AND Kunden.[Status] = N'A'
GROUP BY Holding.Holding, Kunden.KdNr, Kunden.SuchCode, Kunden.AdressBlock;

GO