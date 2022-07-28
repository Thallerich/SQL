SELECT Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez, KdArti.Variante, KdArti.VariantBez, KdArti.Umlauf, ApplArtikel.ArtikelNr AS ApplikationsArtikelNr, ApplArtikel.ArtikelBez AS ApplikationsArtikelBez, ArtiType.ArtiTypeBez AS Applikationstyp, Platz.Code, Platz.PlatzBez
FROM KdArAppl
JOIN KdArti ON KdArAppl.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN KdArti AS ApplKdArti ON KdArAppl.ApplKdArtiID = ApplKdArti.ID
JOIN Artikel AS ApplArtikel ON ApplKdArti.ArtikelID = ApplArtikel.ID
JOIN ArtiType ON ApplArtikel.ArtiTypeID = ArtiType.ID
JOIN Platz ON KdArAppl.PlatzID = Platz.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
WHERE [Zone].ZonenCode = N'SÜD'
  AND Platz.Code = N'PN03';