SELECT N'ADV' AS [System], Vsa.ID, Vsa.PLZ, Vsa.Ort, REPLACE(Vsa.Strasse, N';', N',') AS Strasse
FROM Vsa
WHERE Vsa.Status = N'A'
  AND Vsa.ID > 0
  AND Vsa.PLZ IS NOT NULL
  AND Vsa.Ort IS NOT NULL
  AND Vsa.Strasse IS NOT NULL;