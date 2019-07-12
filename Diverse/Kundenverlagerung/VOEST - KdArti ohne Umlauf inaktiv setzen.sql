UPDATE KdArti SET Status = N'I'
WHERE ID IN (
--SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, KdArti.Variante, KdArti.VariantBez AS Variantenbezeichnung, KdArti.WaschPreis, KdArti.LeasingPreis, KdArti.SonderPreis, KdArti.VkPreis, KdArti.Umlauf
SELECT KdArti.ID
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE Holding.Holding IN (N'VOES', N'VOESAN', N'VOESLE')
  AND Artikel.ArtiTypeID = 1
  AND NOT EXISTS (
    SELECT VsaAnf.*
    FROM VsaAnf
    WHERE VsaAnf.KdArtiID = KdArti.ID
  )
  AND NOT EXISTS (
    SELECT x.*
    FROM KdArti x
    WHERE x.FolgeKdArtiID = KdArti.ID
  )
  AND NOT EXISTS (
    SELECT x.*
    FROM KdArti x
    WHERE x.ErsatzFuerKdArtiID = KdArti.ID
  )
  AND NOT EXISTS (
    SELECT Schrank.*
    FROM Schrank
    WHERE Schrank.KdArtiID = KdArti.ID
  )
  AND NOT EXISTS (
    SELECT Teile.*
    FROM Teile
    WHERE Teile.KdArtiID = KdArti.ID
  )
  AND NOT EXISTS (
    SELECT Traeger.*
    FROM Traeger
    WHERE Traeger.BerufsgrKdArtiID = KdArti.ID
  )
  AND NOT EXISTS (
    SELECT VsaLeas.*
    FROM VsaLeas
    WHERE VsaLeas.KdArtiID = KdArti.ID
  )
);