UPDATE Artikel SET MaxWaschen = 50
FROM Artikel
WHERE EXISTS (
    SELECT OPSets.*
    FROM OPSets
    WHERE OPSets.Artikel1ID = Artikel.ID
      AND OPSets.ArtikelID IN (
        SELECT Artikel.ID
        FROM Artikel
        WHERE Artikel.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = N'CR')
      )
  )
  AND Artikel.MaxWaschen = 0;

GO

UPDATE KdArti SET MaxWaschen = Artikel.MaxWaschen
FROM Artikel
WHERE KdArti.ArtikelID = Artikel.ID
  AND EXISTS (
    SELECT OPSets.*
    FROM OPSets
    WHERE OPSets.Artikel1ID = Artikel.ID
      AND OPSets.ArtikelID IN (
        SELECT Artikel.ID
        FROM Artikel
        WHERE Artikel.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = N'CR')
      )
  )
  AND KdArti.MaxWaschen = 0;

GO