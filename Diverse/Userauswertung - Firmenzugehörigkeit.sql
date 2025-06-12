SELECT Firma.Bez AS Firma, Standort.Bez AS Standort, COUNT(Mitarbei.ID) AS [Anzahl User]
FROM Mitarbei
JOIN Firma ON Mitarbei.FirmaID = Firma.ID
JOIN Standort ON Mitarbei.StandortID = Standort.ID
WHERE Mitarbei.IsAdvanTexUser = 1
  AND Mitarbei.[Status] = N'A'
  AND Mitarbei.LastLogin >= N'2025-01-01'
GROUP BY Firma.Bez, Standort.Bez;

GO

SELECT Firma.Bez AS Firma, Standort.Bez AS Standort, Mitarbei.[Name], Mitarbei.MitarbeiUser AS Benutzername
FROM Mitarbei
JOIN Firma ON Mitarbei.FirmaID = Firma.ID
JOIN Standort ON Mitarbei.StandortID = Standort.ID
WHERE Mitarbei.IsAdvanTexUser = 1
  AND Mitarbei.[Status] = N'A'
  AND Mitarbei.LastLogin >= N'2025-01-01';

GO