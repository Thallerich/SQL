UPDATE Touren SET Touren.SichtbarID = (SELECT ID FROM Sichtbar WHERE Bez = N'Grödig'), Touren.ExpeditionID = (SELECT ID FROM Standort WHERE Bez LIKE N'BU SMS:%')
FROM Touren
JOIN Sichtbar ON Touren.SichtbarID = Sichtbar.ID
WHERE Touren.Tour LIKE N'_-32___'
  AND SUBSTRING(Touren.Tour, 6, 1) <> N'-'
  AND Touren.SichtbarID = x;   --ABS_MIG Sichtbarkeit

SELECT Touren.Tour, Touren.Bez AS TourBez, Sichtbar.Bez AS Sichtbarkeit, Standort.SuchCode AS StandortKurz, Standort.Bez AS Standort
FROM Touren
JOIN Sichtbar ON Touren.SichtbarID = Sichtbar.ID
JOIN Standort ON Touren.ExpeditionID = Standort.ID
WHERE Touren.Tour LIKE N'_-32___'
  AND SUBSTRING(Touren.Tour, 6, 1) <> N'-';