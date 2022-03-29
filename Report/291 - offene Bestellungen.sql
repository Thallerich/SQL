WITH BKoStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'BKO'
)
SELECT BKo.ID AS BKoID, BKo.BestNr, BKo.Datum, IIF(Kunden.ID < 0, NULL, Kunden.KdNr) AS KdNr, IIF(Kunden.KdNr < 0, NULL, Kunden.SuchCode) AS Kunde, BKoArt.BKoArtBez$LAN$ AS Bestellart, BKoStatus.StatusBez AS Bestellstatus, LagerArt.LagerArtBez$LAN$ AS Lagerart, Standort.Bez AS [Lager-Standort], Lief.LiefNr AS Lieferantennummer, Lief.Name1 AS Lieferant, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, LiefAbKo.ABNr, LiefAbKo.Datum AS [AB-Datum], BPo.Menge AS Bestellmenge, BPo.LiefMenge AS [bereits geliefert], KdGf.KurzBez AS [bestellt für Geschäftsbereich]
FROM BKo
JOIN Lief ON BKo.LiefID = Lief.ID
JOIN BPo ON BPo.BKoID = BKo.ID
JOIN ArtGroe ON BPo.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN GroePo ON Artikel.GroeKoID = GroePo.GroeKoID AND ArtGroe.Groesse = GroePo.Groesse
JOIN BKoArt ON BKo.BKoArtID = BKoArt.ID
JOIN BKoStatus ON BKo.[Status] = BKoStatus.[Status]
JOIN LagerArt ON BKo.LagerArtID = LagerArt.ID
JOIN Standort ON LagerArt.LagerID = Standort.ID
JOIN Kunden ON BKo.KundenID = Kunden.ID
JOIN LiefAbKo ON BPo.LatestLiefABKoID = LiefAbKo.ID
JOIN KdGf ON BPo.KdGfID = KdGf.ID
WHERE BKoStatus.ID IN ($1$)
  AND Standort.ID IN ($2$)
ORDER BY BKo.BestNr, Artikel.ArtikelNr, GroePo.Folge;