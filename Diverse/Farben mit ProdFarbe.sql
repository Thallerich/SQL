WITH Farbstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'Farbe')
),
ArtiFarb AS (
  SELECT Artikel.FarbeID, COUNT(Artikel.ID) AS ArtikelAnzahl
  FROM Artikel
  WHERE Artikel.ArtiTypeID = 1
  GROUP BY Artikel.FarbeID
)
SELECT Farbe.Farbe AS [Farb-Code], Farbe.FarbeBez, Farbstatus.StatusBez AS [Status Farbe], ProdFarb.ProdFarbBez, ISNULL(ArtiFarb.ArtikelAnzahl, 0) AS [Anzahl Artikel mit dieser Farbe]
FROM Farbe
JOIN Farbstatus ON Farbe.[Status] = Farbstatus.[Status]
JOIN ProdFarb ON Farbe.ProdFarbID = ProdFarb.ID
LEFT JOIN ArtiFarb ON ArtiFarb.FarbeID = Farbe.ID
ORDER BY ProdFarb.ProdFarbBez, Farbe.FarbeBez;