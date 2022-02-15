WITH Bestellstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'BKO')
)
SELECT BKo.Datum, BKo.BestNr AS Bestellnummer, Bestellstatus.StatusBez AS [Status der Bestellung], BKoArt.BKoArtBez$LAN$ AS Bestellart, Lief.LiefNr AS Lieferantennummer, Lief.Name1 AS Lieferant, Lagerstandort.Bez AS Lagerstandort, LagerArt.LagerArtBez$LAN$ AS Lagerart, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse AS Größe, Bereich.BereichBez$LAN$ AS Produktbereich, LiefAbKo.ABNr AS [AB-Nr.], LiefAbKo.Datum AS [AB-Datum], SUM(BPo.Menge) AS Bestellmenge, SUM(BPo.BestMenge) AS [ursprünglich bestellte Menge], SUM(BPo.LiefMenge) AS [geliefert], BPo.Einzelpreis, SUM(BPo.Menge * BPo.Einzelpreis) AS [Summe der Kosten], BKo.MemoIntern AS [interner Vermerk]
FROM BPo
JOIN BKo ON BPo.BKoID = BKo.ID
JOIN Lief ON BKo.LiefID = Lief.ID
JOIN ArtGroe ON BPo.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN Bestellstatus ON BKo.Status = Bestellstatus.Status
JOIN LagerArt ON BKo.LagerArtID = LagerArt.ID
JOIN Standort AS Lagerstandort ON BKo.LagerID = Lagerstandort.ID
JOIN BKoArt ON BKo.BKoArtID = BKoArt.ID
JOIN LiefAbKo ON BPo.LatestLiefABKoID = LiefAbKo.ID
WHERE BKo.Datum BETWEEN $STARTDATE$ AND $ENDDATE$
  AND LagerArt.SichtbarID IN ($SICHTBARIDS$)
GROUP BY BKo.Datum, BKo.BestNr, Bestellstatus.StatusBez, BKoArt.BKoArtBez$LAN$, Lief.LiefNr, Lief.Name1, Lagerstandort.Bez, LagerArt.LagerartBez$LAN$, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, ArtGroe.Groesse, Bereich.BereichBez$LAN$, LiefAbKo.ABNr, LiefAbKo.Datum, BPo.Einzelpreis, BKo.MemoIntern
ORDER BY BKo.Datum, Lieferant, ArtikelNr, Größe;