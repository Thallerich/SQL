DECLARE @jahrvon date, @jahrbis date;

SELECT @jahrvon = DATEADD(month, DATEDIFF(month, 0, GETDATE())-12, 0), 
  @jahrbis = DATEADD(month, DATEDIFF(month, -1, GETDATE())-1, -1);

DROP TABLE IF EXISTS #JahrLiefermenge;

SELECT KdArti.ArtikelID, CAST(IIF(Firma.Land = N'AT', 1, 0) AS bit) AS IsAT, SUM(LsPo.Menge) AS Liefermenge
INTO #JahrLiefermenge
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Vsa ON LsKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
WHERE LsKo.Datum BETWEEN @jahrvon AND @jahrbis
GROUP BY KdArti.ArtikelID, CAST(IIF(Firma.Land = N'AT', 1, 0) AS bit);

GO

WITH Artikelstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'ARTIKEL'
)
SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Artikelstatus.StatusBez AS [Status Artikel], Bereich.BereichBez AS Produktbereich, CAST(ROUND(x.LiefmengeAT, 0) AS bigint) AS [Liefermenge AT], CAST(ROUND(x.LiefermengeCEE, 0) AS bigint) AS [Liefermenge CEE/SEE]
FROM Artikel
JOIN Artikelstatus ON Artikel.[Status] = Artikelstatus.[Status]
JOIN Bereich ON Artikel.BereichID = Bereich.ID
LEFT JOIN (
  SELECT ArtikelID, [1] AS LiefmengeAT, [0] AS LiefermengeCEE
  FROM (
    SELECT ArtikelID, IsAt, Liefermenge
    FROM #JahrLiefermenge
  ) AS JL
  PIVOT (
    SUM(Liefermenge)
    FOR IsAT IN ([1], [0])
  ) AS pvt
) AS x ON Artikel.ID = x.ArtikelID
WHERE Artikel.ArtiTypeID = 1 /* textile Artikel */
  AND Artikel.ID > 0;

GO