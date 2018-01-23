SELECT [Set-Typ], [5] AS [05:00], [6] AS [06:00], [7] AS [07:00], [8] AS [08:00], [9] AS [09:00], [10] AS [10:00], [11] AS [11:00], [12] AS [12:00], [13] AS [13:00], [14] AS [14:00], [15] AS [15:00], [16] AS [16:00], [17] AS [17:00], [18] AS [18:00], [19] AS [19:00], [20] AS [20:00], [21] AS [21:00], [22] AS [22:00], [23] AS [23:00], [99] AS [Summe]
FROM (
  SELECT ISNULL(IIF(ProdHier.LagerKategorie IN (N'Lami', N'Mäntel'), ProdHier.LagerKategorie, N'Sonstige Sets'), N'Summe') AS [Set-Typ], ISNULL(DATEPART(hour, OPEtiKo.PackZeitpunkt), 99) AS Stunde, COUNT(DISTINCT OPEtiKo.ID) AS Anzahl
  FROM OPEtiKo
  JOIN Artikel ON OPEtiKo.ArtikelID = Artikel.ID
  JOIN ProdHier ON Artikel.ProdHierID = ProdHier.ID
  WHERE OPEtiKo.PackZeitpunkt IS NOT NULL
    AND CAST(OPEtiKo.PackZeitpunkt AS date) = CAST(GETDATE() AS date)
    AND OPEtiKo.PackMitarbeiID = (SELECT MitarbeiID FROM #AdvSession)
    AND OPEtiKo.ProduktionID = 2 -- Enns
  GROUP BY CUBE (IIF(ProdHier.LagerKategorie IN (N'Lami', N'Mäntel'), ProdHier.LagerKategorie, N'Sonstige Sets'), DATEPART(hour, OPEtiKo.PackZeitpunkt))
) AS BDEData
PIVOT (
  SUM(Anzahl)
  FOR Stunde IN ([5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [99])
) AS BDE
ORDER BY 
  CASE WHEN [Set-Typ] = N'Summe' THEN 1 ELSE 0 END, 
  [Set-Typ]