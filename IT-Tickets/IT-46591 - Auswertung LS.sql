WITH PrArchivMig AS (
  SELECT PrArchiv.KdArtiID, PrArchiv.WaschPreis, PrArchiv.LeasingPreis
  FROM PrArchiv
  WHERE PrArchiv.Datum = N'2021-03-13'
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, LsKo.LsNr, LsKo.Datum, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, KdArti.Variante, KdArti.WaschPreis, LsPo.Menge, LsPo.Menge * KdArti.WaschPreis AS Betrag
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Holding ON KUnden.HoldingID = Holding.ID
JOIN PrArchivMig ON PrArchivMig.KdArtiID = KdArti.ID
JOIN LsPo ON LsPo.KdArtiID = KdArti.ID
JOIN LsKo ON LsPo.LsKoID = LsKo.ID
WHERE Holding.Holding IN (N'ADVK', N'SAL')
  AND Kunden.KdNr NOT IN (213386, 219958, 223800)
  AND EXISTS (
    SELECT PrArchiv.*
    FROM PrArchiv
    WHERE PrArchiv.KdArtiID = KdArti.ID
      AND PrArchiv.Datum = N'2021-03-14'
      AND PrArchiv.WaschPreis = 0
      AND PrArchiv.LeasingPreis = 0
  )
  AND LsKo.Status = N'W'
  AND LsPo.RechPoID < -1
  AND LsPo.EPreis = 0
ORDER BY KdNr, Datum, ArtikelNr;