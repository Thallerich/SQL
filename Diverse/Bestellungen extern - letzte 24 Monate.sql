SELECT Lager.Bez AS Lagerstandort, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtiType.ArtiTypeBez AS Artikeltyp, Bereich.BereichBez AS Produktbereich, SUM(BPo.Menge) AS [bestellte Menge], MAX(BKo.Datum) AS [letzte Bestellung], Lief.LiefNr, Lief.SuchCode AS Lieferant, Lief.Name1 AS LieferantZeile1, Lief.Name2 AS LieferantZeile2, Lief.Name3 AS LieferantZeile3, Lief.Strasse, Lief.Land, Lief.PLZ, Lief.Ort, Artikel.EkPreis, Artikel.EkPreisSeit
FROM BPo
JOIN BKo ON BPo.BKoID = BKo.ID
JOIN ArtGroe ON BPo.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN Lief ON BKo.LiefID = Lief.ID
JOIN ArtiType ON Artikel.ArtiTypeID = ArtiType.ID
JOIN Standort AS Lager ON BKo.LagerID = Lager.ID
WHERE Lief.LiefNr NOT IN (39000, 250, 100)
  AND BKo.[Status] IN (N'F', N'J', N'M')
  AND BKo.Datum >= DATEADD(month, -24, CAST(GETDATE() AS date))
GROUP BY Lager.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez, ArtiType.ArtiTypeBez, Bereich.BereichBez, Lief.LiefNr, Lief.SuchCode, Lief.Name1, Lief.Name2, Lief.Name3, Lief.Strasse, Lief.Land, Lief.PLZ, Lief.Ort, Artikel.EkPreis, Artikel.EkPreisSeit;