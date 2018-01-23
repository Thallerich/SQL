SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Status.StatusBez$LAN$ AS Artikelstatus, Bereich.BereichBez$LAN$ AS Produktbereich, ArtGru.ArtGruBez$LAN$ AS Artikelgruppe, Lief.LiefNr AS LieferantNr, Lief.SuchCode AS Lieferant, Artikel.EKPreis, CONVERT(date, Artikel.Anlage_) AS Anlagedatum, ISNULL(Mitarbei.Name, N'(unbekannt)') AS [Angelegt von], COUNT(KdArti.ID) AS [Verwendet bei X Kunden], CONVERT(bit, IIF(COUNT(OPSets.ID) > 0, 1, 0)) AS [Set-Artikel?], Artikel.ID AS ArtikelID, Lief.ID AS LiefID
FROM Lief, Bereich, ArtGru, Status, Artikel
LEFT OUTER JOIN KdArti ON KdArti.ArtikelID = Artikel.ID
LEFT OUTER JOIN OPSets ON OPSets.ArtikelID = Artikel.ID
LEFT OUTER JOIN Mitarbei ON Artikel.AnlageUserID_ = Mitarbei.ID
WHERE Artikel.LiefID = Lief.ID
  AND Artikel.BereichID = Bereich.ID
  AND Artikel.ArtGruID = ArtGru.ID
  AND Artikel.Status  = Status.Status
  AND Status.Tabelle = 'ARTIKEL'
  AND Artikel.ID > 0
  AND Artikel.ArtiTypeID = 1 -- nur textile Artikel
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, Status.StatusBez$LAN$, Bereich.BereichBez$LAN$, ArtGru.ArtGruBez$LAN$, Lief.LiefNr, Lief.SuchCode, Artikel.EKPreis, CONVERT(date, Artikel.Anlage_), ISNULL(Mitarbei.Name, N'(unbekannt)'), Artikel.ID, Lief.ID
ORDER BY Artikel.ArtikelNr ASC;