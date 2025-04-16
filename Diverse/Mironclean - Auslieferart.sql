SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, LiefArt.LiefArtBez AS [Auslieferungsart derzeit]
FROM KdArti
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN LiefArt ON KdArti.LiefArtID = LiefArt.ID
WHERE Kunden.[Status] = 'A'
  AND Kunden.AdrArtID = 1
  AND KdBer.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = 'CR')
  AND KdArti.LiefArtID != (SELECT LiefArt.ID FROM LiefArt WHERE LiefArt.LiefArt = 'S')