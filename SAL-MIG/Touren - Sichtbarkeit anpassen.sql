UPDATE Touren SET Touren.SichtbarID = (SELECT ID FROM Sichtbar WHERE Bez = N'Grödig')
FROM Touren
JOIN Sichtbar ON Touren.SichtbarID = Sichtbar.ID
WHERE Touren.Tour LIKE N'_-32___'
  AND SUBSTRING(Touren.Tour, 6, 1) <> N'-';