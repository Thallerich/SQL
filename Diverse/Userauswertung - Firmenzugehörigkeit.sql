SELECT Firma =
  CASE
    WHEN Firma.ID < 0 AND Standort.ID < 0 THEN N'WOMI'
    WHEN Firma.ID < 0 AND Standort.SuchCode = N'BUDW' THEN 'SMBU'
    WHEN Firma.ID < 0 AND Standort.SuchCode = N'UKLU' THEN N'UKLU'
    WHEN Firma.ID < 0 AND Standort.SuchCode NOT IN (N'BUDW', N'UKLU') THEN N'WOMI'
    WHEN Firma.SuchCode = N'SAL' AND Standort.SuchCode = N'BUDW' THEN N'SMBU'
    WHEN Firma.SuchCode = N'SAL' AND Standort.SuchCode = N'UKLU' THEN N'UKLU'
    WHEN Firma.SuchCode = N'SAL' AND Standort.SuchCode NOT IN (N'BUDW', N'UKLU') THEN N'SAL'
    WHEN Firma.SuchCode = N'91' THEN N'WOMI'
    ELSE Firma.SuchCode
  END,
  COUNT(Mitarbei.ID) AS AnzahlMA
FROM Mitarbei
JOIN Firma ON Mitarbei.FirmaID = Firma.ID
JOIN Standort ON Mitarbei.StandortID = Standort.ID
WHERE Mitarbei.Status = N'A'
  AND Mitarbei.LastLogin >= N'2019-01-01 00:00:00'
GROUP BY
  CASE
    WHEN Firma.ID < 0 AND Standort.ID < 0 THEN N'WOMI'
    WHEN Firma.ID < 0 AND Standort.SuchCode = N'BUDW' THEN 'SMBU'
    WHEN Firma.ID < 0 AND Standort.SuchCode = N'UKLU' THEN N'UKLU'
    WHEN Firma.ID < 0 AND Standort.SuchCode NOT IN (N'BUDW', N'UKLU') THEN N'WOMI'
    WHEN Firma.SuchCode = N'SAL' AND Standort.SuchCode = N'BUDW' THEN N'SMBU'
    WHEN Firma.SuchCode = N'SAL' AND Standort.SuchCode = N'UKLU' THEN N'UKLU'
    WHEN Firma.SuchCode = N'SAL' AND Standort.SuchCode NOT IN (N'BUDW', N'UKLU') THEN N'SAL'
    WHEN Firma.SuchCode = N'91' THEN N'WOMI'
    ELSE Firma.SuchCode
  END;