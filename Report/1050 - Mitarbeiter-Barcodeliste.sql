SELECT Mitarbei.Name, Mitarbei.Barcode AS MABarcode
FROM Mitarbei
WHERE Mitarbei.Funktion = 'Containerverheiratung'
  AND Mitarbei.FirmaID IN ($1$)
ORDER BY Mitarbei.Name ASC;