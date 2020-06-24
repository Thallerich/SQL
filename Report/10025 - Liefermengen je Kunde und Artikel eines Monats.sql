DECLARE @Monat nchar(7) = $2$;
DECLARE @DateFrom date = CAST(@Monat + N'-01' AS date);
DECLARE @DateTo date = DATEADD(day, -1, DATEADD(month, 1, @DateFrom));

SELECT KdNr, Kunde, ArtikelNr, Artikelbezeichnung, [1] AS [Tag 1], [2] AS [Tag 2], [3] AS [Tag 3], [4] AS [Tag 4], [5] AS [Tag 5], [6] AS [Tag 6], [7] AS [Tag 7], [8] AS [Tag 8], [9] AS [Tag 9], [10] AS [Tag 10], [11] AS [Tag 11], [12] AS [Tag 12], [13] AS [Tag 13], [14] AS [Tag 14], [15] AS [Tag 15], [16] AS [Tag 16], [17] AS [Tag 17], [18] AS [Tag 18], [19] AS [Tag 19], [20] AS [Tag 20], [21] AS [Tag 21], [22] AS [Tag 22], [23] AS [Tag 23], [24] AS [Tag 24], [25] AS [Tag 25], [26] AS [Tag 26], [27] AS [Tag 27], [28] AS [Tag 28], [29] AS [Tag 29], [30] AS [Tag 30], [31] AS [Tag 31],
  Gesamt = ISNULL([1], 0) + ISNULL([2], 0) + ISNULL([3], 0) + ISNULL([4], 0) + ISNULL([5], 0) + ISNULL([6], 0) + ISNULL([7], 0) + ISNULL([8], 0) + ISNULL([9], 0) + ISNULL([10], 0) + ISNULL([11], 0) + ISNULL([12], 0) + ISNULL([13], 0) + ISNULL([14], 0) + ISNULL([15], 0) + ISNULL([16], 0) + ISNULL([17], 0) + ISNULL([18], 0) + ISNULL([19], 0) + ISNULL([20], 0) + ISNULL([21], 0) + ISNULL([22], 0) + ISNULL([23], 0) + ISNULL([24], 0) + ISNULL([25], 0) + ISNULL([26], 0) + ISNULL([27], 0) + ISNULL([28], 0) + ISNULL([29], 0) + ISNULL([30], 0) + ISNULL([31], 0)
FROM (
  SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, DATEPART(day, LsKo.Datum) AS Tag, ROUND(SUM(LsPo.Menge), 0) AS Liefermenge
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN Vsa ON LsKo.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN Fahrt ON LsKo.FahrtID = Fahrt.ID
  JOIN Standort AS Expedition ON Fahrt.ExpeditionID = Expedition.ID
  WHERE LsKo.Datum BETWEEN @DateFrom AND @DateTo
    AND Expedition.ID IN ($1$)
  GROUP BY Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, DATEPART(day, LsKo.Datum)
) AS PivoData
PIVOT (SUM(Liefermenge) FOR Tag IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28], [29], [30], [31])) AS LiefermengenPivot
ORDER BY KdNr, ArtikelNr;