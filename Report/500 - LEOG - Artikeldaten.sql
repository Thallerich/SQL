DECLARE @StandortID int = (SELECT ID FROM Standort WHERE SuchCode = N'LEOG');

DECLARE @Vsa TABLE (
  VsaID int
);

INSERT INTO @Vsa
SELECT DISTINCT VsaID
FROM VsaTour
JOIN Vsa ON VsaTour.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Touren ON VsaTour.TourenID = Touren.ID
JOIN KdBer ON VsaTour.KdBerID = KdBer.ID
WHERE Touren.ExpeditionID = @StandortID
  AND KdBer.BereichID IN (SELECT ID FROM Bereich WHERE Bereich IN (N'FW', N'LW'))
  AND Vsa.Status = N'A'
  AND Kunden.Status = N'A'
  AND CAST(GETDATE() AS date) BETWEEN VsaTour.VonDatum AND VsaTour.BisDatum;

SELECT KdNr, VerteilstellenID, Verteilstellenbezeichnung, [1] AS [Artikel 1], [2] AS [Artikel 2], [3] AS [Artikel 3], [4] AS [Artikel 4], [5] AS [Artikel 5], [6] AS [Artikel 6], [7] AS [Artikel 7], [8] AS [Artikel 8], [9] AS [Artikel 9], [10] AS [Artikel 10], [11] AS [Artikel 11], [12] AS [Artikel 12], [13] AS [Artikel 13], [14] AS [Artikel 14], [15] AS [Artikel 15], [16] AS [Artikel 16], [17] AS [Artikel 17], [18] AS [Artikel 18], [19] AS [Artikel 19], [20] AS [Artikel 20], [21] AS [Artikel 21], [22] AS [Artikel 22], [23] AS [Artikel 23], [24] AS [Artikel 24], [25] AS [Artikel 25], [26] AS [Artikel 26], [27] AS [Artikel 27], [28] AS [Artikel 28], Durchschnitt
FROM (
  SELECT Kunden.KdNr, Vsa.ID AS VerteilstellenID, Vsa.Bez AS Verteilstellenbezeichnung, Artikel.ArtikelBez AS Artikelbezeichnung, VsaAnf.Durchschnitt, ROW_NUMBER() OVER (PARTITION BY Vsa.ID ORDER BY Artikel.ArtikelBez ASC) AS SortNumber
  FROM VsaAnf
  JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
  JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  WHERE Vsa.ID IN (SELECT VsaID FROM @Vsa)
    AND KdBer.BereichID IN (SELECT ID FROM Bereich WHERE Bereich IN (N'FW', N'LW'))
    AND VsaAnf.Status = N'A'
) AS ArtiData
PIVOT (
  MAX(Artikelbezeichnung) FOR SortNumber IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12], [13], [14], [15], [16], [17], [18], [19], [20], [21], [22], [23], [24], [25], [26], [27], [28])
) AS ArtiPivot
ORDER BY KdNr, VerteilstellenID;