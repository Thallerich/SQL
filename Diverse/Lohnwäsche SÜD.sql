WITH Liefermenge AS (
  SELECT LsPo.KdArtiID, SUM(LsPo.Menge) AS Menge
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  WHERE LsKo.Datum BETWEEN N'2022-01-01' AND GETDATE()
  GROUP BY LsPo.KdArtiID
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Kunden.Name1, Kunden.Name2, Kunden.Name3, Kunden.Strasse, Kunden.Land, Kunden.PLZ, Kunden.Ort, Bereich.BereichBez AS Produktbereich, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ISNULL(Liefermenge.Menge, 0) AS Menge
FROM Kunden
JOIN KdBer ON KdBer.KundenID = Kunden.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN KdArti ON KdArti.KdBerID = KdBer.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Liefermenge ON Liefermenge.KdArtiID = KdArti.ID
WHERE Firma.SuchCode = N'FA14'
  AND Standort.SuchCode IN (N'GRAZ', N'UKLU')
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1
  AND KdBer.Status = N'A'
  AND KdArti.Status = N'A'
  AND EXISTS (
    SELECT KdBer.*
    FROM KdBer
    WHERE KdBer.KundenID = Kunden.ID
      AND KdBer.BereichID = (SELECT ID FROM Bereich WHERE Bereich = N'LW')
      AND KdBer.Status = N'A'
      AND EXISTS (
        SELECT KdArti.*
        FROM KdArti
        WHERE KdArti.KdBerID = KdBer.ID
          AND KdArti.Status = N'A'
      )
  )
  AND EXISTS (
    SELECT Liefermenge.*
    FROM Liefermenge
    JOIN KdArti ON Liefermenge.KdArtiID = KdArti.ID
    JOIN KdBer ON KdArti.KdBerID = KdBer.ID
    JOIN Bereich ON KdBer.BereichID = Bereich.ID
    WHERE KdArti.KundenID = Kunden.ID
      AND Bereich.Bereich = N'LW'
      AND Liefermenge.Menge != 0
  )
ORDER BY Kunden.KdNr, Produktbereich, Artikel.ArtikelNr;