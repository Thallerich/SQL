SELECT LiefAbKo.ABNr AS Workorder, BKo.BestNr, BKo.Datum, Standort.SuchCode AS Lagerstandort, Lagerart.Lagerart, AnlageUser.Name AS [Erfasser], FreigabeUser.Name AS [Freigeber], BKo.FreigabeZeitpkt AS Freigabezeitpunkt, Artikel.ArtikelNr, ArtGroe.Groesse AS Größe, Artikel.ArtikelBez AS Artikelbezeichnung, BPo.Menge AS [bestellte Menge], BPo.LiefMenge AS [WE-gebuchte Menge]
FROM BKo
JOIN BPo ON BPo.BKoID = BKo.ID
JOIN ArtGroe ON BPo.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN LiefAbKo ON BPo.LatestLiefABKoID = LiefAbKo.ID
JOIN Standort ON BKo.LagerID = Standort.ID
JOIN Lagerart ON BKo.LagerartID = Lagerart.ID
JOIN Mitarbei AS FreigabeUser ON BKo.FreigabeMitarbeiID = FreigabeUser.ID
JOIN Mitarbei AS AnlageUser ON BPo.AnlageUserID_ = AnlageUser.ID
WHERE BPo.Menge > BPo.LiefMenge
  AND BKo.[Status] BETWEEN N'F' AND N'K'
  AND Artikel._IsHAWA = 1
  AND BKo.LiefID = (SELECT Lief.ID FROM Lief WHERE Lief.LiefNr = 100)
  AND LiefAbKo.ID > 0
ORDER BY Datum, BestNr, ArtikelNr;