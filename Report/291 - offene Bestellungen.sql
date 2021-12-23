SELECT BKo.BestNr, BKo.Datum, IIF(Kunden.ID < 0, NULL, Kunden.KdNr) AS KdNr, IIF(Kunden.KdNr < 0, NULL, Kunden.SuchCode) AS Kunde, BKoArt.BKoArtBez$LAN$ AS Bestellart, [Status].StatusBez$LAN$ AS Bestellstatus, LagerArt.LagerArtBez$LAN$ AS Lagerart, Standort.Bez AS [Lager-Standort], Lief.Name1 AS Lieferant, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Grö0e, LiefAbKo.ABNr, LiefAbKo.Datum AS [AB-Datum], BPo.Menge AS Bestellmenge, BPo.LiefMenge AS [bereits geliefert]
FROM BKo
JOIN Lief ON BKo.LiefID = Lief.ID
JOIN BPo ON BPo.BKoID = BKo.ID
JOIN ArtGroe ON BPo.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN GroePo ON Artikel.GroeKoID = GroePo.GroeKoID AND ArtGroe.Groesse = GroePo.Groesse
JOIN BKoArt ON BKo.BKoArtID = BKoArt.ID
JOIN [Status] ON BKo.[Status] = [Status].[Status] AND [Status].Tabelle = N'BKO'
JOIN LagerArt ON BKo.LagerArtID = LagerArt.ID
JOIN Standort ON LagerArt.LagerID = Standort.ID
JOIN Kunden ON BKo.KundenID = Kunden.ID
JOIN LiefAbKo ON BPo.LatestLiefABKoID = LiefAbKo.ID
WHERE [Status].ID IN ($1$)
  AND Standort.ID IN ($2$)
ORDER BY BKo.BestNr, Artikel.ArtikelNr, GroePo.Folge;