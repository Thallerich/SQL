SELECT Standort.Bez AS [Lager-Standort], BKo.BestNr AS Bestellnummer, BKo.Datum AS [Bestell-Datum], BKo.BruttoWert, BKo.MWStBetrag, BKo.MWStSatz, BKo.NettoWert, Lief.LiefNr AS [Lieferanten-Nummer], Lief.SuchCode AS [Lieferanten-Stichwort], Lief.Name1, Lief.Name2, Lief.Name3, Lief.Strasse, Lief.Land, Lief.PLZ, Lief.Ort, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Artikel.BestNr AS [Bestellnummer Artikel], ArtGroe.Groesse AS Größe, ArtGroe.BestNr AS [Bestellnummer Größe], BPo.Menge, BPo.Reserviert, BPo.LiefMenge, BPo.Einzelpreis, BPo.LiefDat, BPo.ZusatzText, BPo.SollTermin, BPo.EAN13 AS GTIN
FROM BPo
JOIN BKo ON BPo.BKoID = BKo.ID
JOIN Lief ON BKo.LiefID = Lief.ID
JOIN ArtGroe ON BPo.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Standort ON BKo.LagerID = Standort.ID
WHERE BKo.[Status] IN (N'F', N'J')
  AND BKo.LiefID > 0
  AND (BPo.Menge > 0 OR BPo.LiefMenge > 0)
ORDER BY [Bestell-Datum], Bestellnummer;