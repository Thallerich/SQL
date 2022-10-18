WITH Artikelstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'ARTIKEL'
)
SELECT Artikelstatus.StatusBez AS Artikelstatus, Artikel.ArtikelNr AS ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, IIF(Farbe1.ID < 0, NULL, Farbe1.FarbeBez$LAN$) AS Farbe1, IIF(Farbe2.ID < 0, NULL, Farbe2.FarbeBez$LAN$) AS Farbe2, Coalesce(ArtGroe.BestNr, Artikel.BestNr) AS [ArtikelNr Lieferant], ArtGroe.Groesse AS Größe, ArtGroe.EKPreis, ME.MEBez$LAN$ AS Mengeneinheit, IIF(Lief.ID > 0, Lief.LiefNr, Lief2.LiefNr) AS Lieferantennummer, IIF(Lief.ID > 0, Lief.Name1, Lief2.Name1) AS Lieferantenname, ArtMisch.ArtMischBez$LAN$ AS Gewebe, Artikel.StueckGewicht AS [Artikelgewicht (kg/Stück)]
FROM Artikel
JOIN ArtGroe ON ArtGroe.ArtikelID = Artikel.ID
JOIN ME ON Artikel.MeID = ME.ID
JOIN Lief ON ArtGroe.LiefID = Lief.ID
JOIN Lief AS Lief2 ON Artikel.LiefID = Lief2.ID
JOIN ArtMisch ON Artikel.ArtMischID = ArtMisch.ID
JOIN Artikelstatus ON Artikel.[Status] = Artikelstatus.[Status]
JOIN Farbe AS Farbe1 ON Artikel.FarbeID = Farbe1.ID
JOIN Farbe AS Farbe2 ON Artikel.Farbe2ID = Farbe2.ID
WHERE Artikel.BereichID IN ($1$)
  AND Artikelstatus.ID IN ($2$)
  AND EXISTS (
    SELECT KdArti.ID
    FROM KdArti
    JOIN Kunden ON KdArti.KundenID = Kunden.ID
    JOIN KdGf ON Kunden.KdGfID = KdGf.ID
    WHERE KdArti.ArtikelID = Artikel.ID
      AND KdGf.ID IN ($3$)
      AND Kunden.StandortID IN ($4$)
  )
ORDER BY Artikel.ArtikelNr;