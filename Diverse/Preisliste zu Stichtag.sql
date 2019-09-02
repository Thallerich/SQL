DECLARE @PrStichtag date = N'2019-06-30';

WITH KdArtiStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'KDARTI')
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, KdArti.VariantBez AS Variante, KdArtiStatus.StatusBez AS [Kundenartikel-Status aktuell], Bearbeitungspreis = (
  SELECT TOP 1 PrArchiv.WaschPreis
  FROM PrArchiv
  WHERE PrArchiv.KdArtiID = KdArti.ID
    AND PrArchiv.Datum <= @PrStichtag
  ORDER BY PrArchiv.Datum DESC
), Leasingpreis = (
  SELECT TOP 1 PrArchiv.LeasingPreis
  FROM PrArchiv
  WHERE PrArchiv.KdArtiID = KdArti.ID
    AND PrArchiv.Datum <= @PrStichtag
  ORDER BY PrArchiv.Datum DESC  
)
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdArtiStatus ON KdArti.[Status] = KdArtiStatus.[Status]
WHERE Kunden.KdNr IN (19000, 19001, 19009, 19010, 19013, 19024, 19030, 2511145)
  AND Artikel.ID > 0;