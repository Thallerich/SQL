SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse AS [Artikelgröße], LiefLsPo.Menge AS [Menge Wareneingang], BPo.Einzelpreis, BPo.Einzelpreis * LiefLsPo.Menge AS Preis, BKo.BestNr AS Bestellnummer, BKo.Datum AS Bestelldatum, LiefLsKo.Datum AS [Lieferschein-Datum], LiefLsKo.LsNr AS [Lieferschein-Nummer], Lief.LiefNr, Lief.SuchCode AS Lieferant, ZahlZiel.ZahlZielBez AS Zahlungsziel
FROM LiefLsPo
JOIN LiefLsKo ON LiefLsPo.LiefLsKoID = LiefLsKo.ID
JOIN BPo ON LiefLsPo.BPoID = BPo.ID
JOIN BKo ON BPo.BKoID = BKo.ID
JOIN ArtGroe ON BPo.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Lief ON BKo.LiefID = Lief.ID
JOIN ZahlZiel ON Lief.ZahlZielID = ZahlZiel.ID
WHERE LiefLsKo.Datum BETWEEN N'2017-07-01' AND N'2017-08-31'
  AND LiefLsPo.Menge <> 0;