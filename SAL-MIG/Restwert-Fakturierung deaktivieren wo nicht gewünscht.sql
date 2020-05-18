UPDATE Kunden SET RWnachWochen = 900
FROM Kunden
JOIN RwConfig ON Kunden.RWConfigID = RwConfig.ID
WHERE RwConfig.RueckVar = 1
  AND Kunden.FakFehlteil = 0;