SELECT Mitarbei.Name, Mitarbei.Barcode AS MABarcode
FROM Mitarbei
WHERE Mitarbei.Funktion = 'Containerverheiratung'
  AND Mitarbei.FirmaID IN ($1$)
  AND Mitarbei.Status = N'A'
ORDER BY Mitarbei.Name ASC;