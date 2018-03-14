SELECT [Status].StatusBez$LAN$ AS Artikelstatus, Artikel.ArtikelNr AS [ArtikelNr Wozabal], Artikel.ArtikelBez$LAN$ AS [Artikelbezeichnung Wozabal], IIF(Farbe1.ID < 0, NULL, Farbe1.FarbeBez$LAN$) AS Farbe1, IIF(Farbe2.ID < 0, NULL, Farbe2.FarbeBez$LAN$) AS Farbe2, ISNULL(ArtGroe.BestNr, Artikel.BestNr) AS [ArtikelNr Lieferant], ArtGroe.Groesse, ArtGroe.EKPreis, ME.MEBez$LAN$ AS Mengeneinheit, IIF(Lief.ID > 0, Lief.LiefNr, Lief2.LiefNr) AS Lieferantennummer, IIF(Lief.ID > 0, Lief.Name1, Lief2.Name1) AS Lieferantenname, ArtMisch.ArtMischBez$LAN$ AS Gewebe, Artikel.StueckGewicht AS [Artikelgewicht (kg/Stück)]
FROM Artikel, ArtGroe, ME, Lief, Lief AS Lief2, ArtMisch, [Status], Farbe AS Farbe1, Farbe AS Farbe2
WHERE ArtGroe.ArtikelID = Artikel.ID
  AND ArtGroe.LiefID = Lief.ID
  AND Artikel.LiefID = Lief2.ID
  AND Artikel.MEID = ME.ID
  AND Artikel.ArtMischID = ArtMisch.ID
  AND Artikel.FarbeID = Farbe1.ID
  AND Artikel.Farbe2ID = Farbe2.ID
  AND Artikel.[Status] = [Status].[Status]
  AND [Status].Tabelle = 'ARTIKEL'
  AND Artikel.BereichID IN ($1$)
  AND [Status].ID IN ($2$)
  AND EXISTS (
    SELECT KdArti.ID
    FROM KdArti
    JOIN Kunden ON KdArti.KundenID = Kunden.ID
    JOIN KdGf ON Kunden.KdGfID = KdGf.ID
    WHERE KdArti.ArtikelID = Artikel.ID
      AND KdGf.ID IN ($3$)
  )
ORDER BY Artikel.ArtikelNr;