SELECT Status.Status + ' - ' + Status.StatusBez$LAN$ AS ArtikelStatus, Artikel.ArtikelNr AS [ArtikelNr Wozabal], Artikel.ArtikelBez$LAN$ AS [Artikelbezeichnung Wozabal], ISNULL(ArtGroe.BestNr, Artikel.BestNr) AS [ArtikelNr Lieferant], ArtGroe.Groesse, ArtGroe.EKPreis, ME.MEBez$LAN$ AS Mengeneinheit, IIF(Lief.ID > 0, Lief.LiefNr, Lief2.LiefNr) AS Lieferantennummer, IIF(Lief.ID > 0, Lief.Name1, Lief2.Name1) AS Lieferantenname, ArtMisch.ArtMischBez$LAN$ AS Gewebe, Artikel.StueckGewicht AS [Artikelgewicht (kg/Stück)]
FROM Artikel, ArtGroe, ME, Lief, Lief AS Lief2, ArtMisch, Status
WHERE ArtGroe.ArtikelID = Artikel.ID
  AND ArtGroe.LiefID = Lief.ID
  AND Artikel.LiefID = Lief2.ID
  AND Artikel.MEID = ME.ID
  AND Artikel.ArtMischID = ArtMisch.ID
  AND Artikel.Status = Status.Status
  AND Status.Tabelle = 'ARTIKEL'
  AND Artikel.BereichID IN ($1$)
  AND Status.ID IN ($2$)
ORDER BY Artikel.ArtikelNr;