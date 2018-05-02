SELECT CAST(BKo.Anlage_ AS date) AS Anlagedatum,
  BKo.BestNr AS Bestellnummer,
  BKoArt.BKoArtBez AS [Bestell-Art],
  Lief.LiefNr AS Lieferantennummer,
  Lief.Name1 AS Lieferant,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS Artikelbezeichnung,
  ArtGroe.Groesse,
  Abc.AbcBez$LAN$ AS [ABC-Klasse],
  BPo.Menge AS [bestellte Menge],
  BPo.Einzelpreis,
  Standort.Bez AS Lagerstandort,
  BPo.Menge * BPo.Einzelpreis AS Gesamtpreis
FROM BPo
JOIN BKo ON BPo.BKoID = BKo.ID
JOIN Lief ON BKo.LiefID = Lief.ID
JOIN ArtGroe ON BPo.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Abc ON Artikel.AbcID = Abc.ID
JOIN Standort ON BKo.LagerID = Standort.ID
JOIN BKoArt ON BKo.BKoArtID = BKoArt.ID
WHERE BKo.Status = N'A'
  AND BKo.Anlage_ BETWEEN $1$ AND $2$
ORDER BY Bestellnummer, [bestellte Menge];