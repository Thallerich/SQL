SELECT Standort.SuchCode AS Hauptstandort,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  KdArti.Variante,
  KdArti.VariantBez AS Variantenbezeichnung,
  KdArti.Umlauf AS Umlaufmenge,
  PsaArt.ArtikelBez$LAN$ AS [Bezeichnung PSA-Art],
  KdArPSA.StartWaeschen AS [ab Wäschen],
  KdArPSA.StopWaeschen AS [bis Wäschen]
FROM KdArPSA
JOIN KdArti ON KdArPSA.KdArtiID = KdArti.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Artikel AS PsaArt ON KdArPSA.SoFaArtikelID = PsaArt.ID
WHERE Kunden.SichtbarID IN ($SICHTBARIDS$)
  AND Kunden.[Status] = N'A'
  AND KdArti.[Status] = N'A'
  AND Kunden.AdrArtID = 1;