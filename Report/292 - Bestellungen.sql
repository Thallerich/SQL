WITH Bestellstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'BKO')
)
SELECT BKo.Datum, BKo.BestNr AS Bestellnummer, Bestellstatus.StatusBez AS [Status der Bestellung], Lief.LiefNr AS Lieferantennummer, Lief.Name1 AS Lieferant, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Bereich.BereichBez$LAN$ AS Produktbereich, SUM(BPo.BestMenge) AS Bestellmenge, BPo.Einzelpreis, SUM(BPo.BestMenge * BPo.Einzelpreis) AS [Summe der Kosten]
FROM BPo
JOIN BKo ON BPo.BKoID = BKo.ID
JOIN Lief ON BKo.LiefID = Lief.ID
JOIN ArtGroe ON BPo.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
JOIN Bestellstatus ON BKo.Status = Bestellstatus.Status
WHERE BKo.Datum BETWEEN $1$ AND $2$
GROUP BY BKo.Datum, BKo.BestNr, Bestellstatus.StatusBez, Lief.LiefNr, Lief.Name1, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, Bereich.BereichBez$LAN$, BPo.Einzelpreis
ORDER BY BKo.Datum, Lieferant, Artikelbezeichnung;