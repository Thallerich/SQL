SELECT EinzHist.Barcode,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS Artikelbezeichnung,
  ArtGroe.Groesse AS Größe,
  ArtiType.ArtiTypeBez AS Applikationstyp,
  ApplArtikel.ArtikelBez AS Applikation,
  Platz.PlatzBez1 AS Platzierung,
  Lagerort.Lagerort
FROM EinzHist
JOIN Lagerart ON EinzHist.LagerArtID = Lagerart.ID
JOIN Lagerort ON EinzHist.LagerOrtID = Lagerort.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
LEFT JOIN TeilAppl ON TeilAppl.EinzHistID = EinzHist.ID
LEFT JOIN Artikel AS ApplArtikel ON TeilAppl.ApplArtikelID = ApplArtikel.ID
LEFT JOIN ArtiType ON TeilAppl.ArtiTypeID = ArtiType.ID
LEFT JOIN Platz ON TeilAppl.PlatzID = Platz.ID
WHERE EinzHist.IsCurrEinzHist = 1
  AND EinzHist.EinzHistTyp = 2
  AND Lagerart.LagerArt = N'WOENBKGC';