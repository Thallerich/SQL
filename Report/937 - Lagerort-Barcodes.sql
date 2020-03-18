SELECT Lagerort.Lagerort, Lagerort.Barcode
FROM Lagerort
WHERE Lagerort.LagerID = $1$
  AND Lagerort.Barcode IS NOT NULL
ORDER BY Lagerort.Lagerort ASC;