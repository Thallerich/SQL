UPDATE Kunden SET RWnachWochen = 9999
WHERE Kunden.AdrArtID = 1
  AND Kunden.[Status] = N'A'
  AND Kunden.FakFehlteil = 0
  AND Kunden.RWnachWochen = 0
  AND Kunden.ID > 0;