SELECT KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr, Kunden.SuchCode AS [Kunden-Stichwort], Kunden.Name1 AS [Adresszeile 1], Kunden.Name2 AS [Adresszeile 2], Kunden.Name3 AS [Adresszeile 3], Kunden.Strasse, Kunden.Land, Kunden.PLZ, Kunden.Ort, Kunden.AnzKopienLS AS [Anzahl Lieferscheine-Exemplare]
FROM Kunden
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
WHERE Kunden.AdrArtID = 1
  AND Kunden.[Status] = N'A'
  AND Kunden.FirmaID = (SELECT Firma.ID FROM Firma WHERE Firma.SuchCode = N'BUDA')
  AND EXISTS (
    SELECT KdArti.*
    FROM KdArti
    JOIN KdBer ON KdArti.KdBerID = KdBer.ID
    WHERE KdBer.KundenID = Kunden.ID
      AND KdBer.BereichID IN (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich IN (N'MA', N'HW', N'BC'))
      AND KdArti.Umlauf != 0
  )
  AND NOT EXISTS (
    SELECT KdArti.*
    FROM KdArti
    JOIN KdBer ON KdArti.KdBerID = KdBer.ID
    WHERE KdBer.KundenID = Kunden.ID
      AND KdBer.BereichID NOT IN (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich IN (N'MA', N'HW', N'BC'))
      AND KdArti.Umlauf != 0
  );