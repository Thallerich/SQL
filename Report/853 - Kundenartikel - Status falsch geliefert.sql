SELECT Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS Artikelbezeichnung,
  KdArti.Variante,
  KdArti.WaschPreis AS Bearbeitungspreis,
  KdArti.LeasPreis AS Leasingpreis,
  KdArti.ID AS KdArtiID
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE Kunden.ID IN ($10$)
  AND (($11$ = 1 AND KdArti.WaschPreis = 0 AND KdArti.LeasPreis = 0) OR ($11$ = 0))
  AND KdArti.Status = N'F';