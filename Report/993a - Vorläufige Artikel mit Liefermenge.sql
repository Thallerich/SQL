SELECT Firma.Bez AS Firma, Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, SUM(LsPo.Menge) AS Liefermenge, KdArti.Vorlaeufig, KdArti.WaschPreis, KdArti.LeasPreis AS LeasingPreis, KdArti.ID AS KdArtiID
FROM LsPo
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
WHERE KdArti.Vorlaeufig = 1
  AND LsPo.Menge != 0
  AND LsKo.Status < N'W'
  AND Artikel.ID > 0
  AND Kunden.FirmaID IN ($1$)
GROUP BY Firma.Bez, Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez, KdArti.Vorlaeufig, KdArti.WaschPreis, KdArti.LeasPreis, KdArti.ID
ORDER BY Firma, KdNr;