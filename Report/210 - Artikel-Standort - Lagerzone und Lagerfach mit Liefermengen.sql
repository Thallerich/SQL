SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Bereich.BereichBez$LAN$ AS Produktbereich, IIF(ArtiStan.PackMenge < 0, Artikel.PackMenge, ArtiStan.PackMenge) AS [VPE Menge], ME.MeBez AS VPE, Artikel.StueckGewicht AS [Gewicht pro Stk.], ISNULL(LsPoMenge.Liefermenge, 0) AS Liefermenge, ArtiStan.Lagerzone, ArtiStan.Lagerfach
FROM Artikel
JOIN ME ON Artikel.MeID = ME.ID
JOIN Bereich ON Artikel.BereichID = Bereich.ID
LEFT JOIN ArtiStan ON ArtiStan.ArtikelID = Artikel.ID AND ArtiStan.StandortID = $1$
LEFT JOIN (
  SELECT KdArti.ArtikelID, SUM(LsPo.Menge) AS Liefermenge
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN KdArti ON LsPo.KdArtiID = KdArti.ID
  WHERE LsKo.Datum >= DATEFROMPARTS(YEAR(GETDATE()) - 1, MONTH(GETDATE()), 1) /* Start des Monats vor einem Jahr (ergibt z.B. am 10. Februar 2025 als Startdatum den 01. Februar 2024) */
    AND LsKo.Datum <= EOMONTH(GETDATE(), -1) /* Ende des letzten Monats (ergibt z.B. am 10. Februar 2025 als Datum den 31. Jänner 2025) */
    AND LsPo.ProduktionID = $1$
  GROUP BY KdArti.ArtikelID
) AS LsPoMenge ON LsPoMenge.ArtikelID = Artikel.ID
WHERE Artikel.ArtiTypeID = 1
  AND Artikel.ID > 0
  AND (($2$ = 1 AND LsPoMenge.Liefermenge > 0 AND LsPoMenge.Liefermenge IS NOT NULL) OR ($2$ = 0));