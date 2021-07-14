WITH Artikelstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'ARTIKEL')
)
SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Artikelstatus.StatusBez AS Artikelstatus, Artikel.IgnoreMinMax AS [in Min-/Max-Planung ausblenden?]
FROM Artikel
JOIN Artikelstatus ON Artikelstatus.[Status] = Artikel.[Status]
WHERE Artikel.IgnoreMinMax = 1
  AND EXISTS (
    SELECT KdArti.*
    FROM KdArti
    JOIN Kunden ON KdArti.KundenID = Kunden.ID
    JOIN KdGf ON Kunden.KdGfID = KdGf.ID
    WHERE KdGf.KurzBez = N'MED'
      AND KdArti.Status = N'A'
      AND Kunden.Status = N'A'
      AND KdArti.ArtikelID = Artikel.ID
  )
  AND Artikel.Status <= N'D'
ORDER BY ArtikelNr ASC;