SELECT Benutzername, Mitarbeiter, Datum, [Set-Typ], [5] AS [05:00], [6] AS [06:00], [7] AS [07:00], [8] AS [08:00], [9] AS [09:00], [10] AS [10:00], [11] AS [11:00], [12] AS [12:00], [13] AS [13:00], [14] AS [14:00], [15] AS [15:00], [16] AS [16:00], [17] AS [17:00], [18] AS [18:00], [19] AS [19:00], [20] AS [20:00], [21] AS [21:00], [22] AS [22:00], [23] AS [23:00], [99] AS [Summe]
FROM (
  SELECT ISNULL(Mitarbei.MitarbeiUser, N'Summe:') AS Benutzername, Mitarbei.Name AS Mitarbeiter, IIF(ProdHier.LagerKategorie IN (N'Lami', N'Mäntel'), ProdHier.LagerKategorie, N'Sonstige Sets') AS [Set-Typ], CAST(OPEtiKo.PackZeitpunkt AS date) AS Datum, ISNULL(DATEPART(hour, OPEtiKo.PackZeitpunkt), 99) AS Stunde, COUNT(DISTINCT OPEtiKo.ID) AS Anzahl
  FROM OPEtiKo
  JOIN Artikel ON OPEtiKo.ArtikelID = Artikel.ID
  JOIN ProdHier ON Artikel.ProdHierID = ProdHier.ID
  JOIN Mitarbei ON OPEtiKo.PackMitarbeiID = Mitarbei.ID
  WHERE OPEtiKo.PackZeitpunkt IS NOT NULL
    AND CAST(OPEtiKo.PackZeitpunkt AS date) BETWEEN $1$ AND $2$
    AND OPEtiKo.ProduktionID = 4 -- Enns
  GROUP BY CUBE ((Mitarbei.MitarbeiUser, Mitarbei.Name, IIF(ProdHier.LagerKategorie IN (N'Lami', N'Mäntel'), ProdHier.LagerKategorie, N'Sonstige Sets'), CAST(OPEtiKo.PackZeitpunkt AS date)), DATEPART(hour, OPEtiKo.PackZeitpunkt))
) AS BDEData
PIVOT (
  SUM(Anzahl)
  FOR Stunde IN ([5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [99])
) AS BDE
ORDER BY 
  CASE WHEN Benutzername = N'Summe' THEN 1 ELSE 0 END,
  Benutzername,
  Datum,
  [Set-Typ]