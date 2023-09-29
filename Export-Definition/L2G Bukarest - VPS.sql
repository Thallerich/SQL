SELECT VPSKo.ID AS STACKID, EinzTeil.Code AS EPC, VPSKo.Anlage_ AS [DATE]
FROM Scans
JOIN EinzTeil ON Scans.EinzTeilID = EinzTeil.ID
JOIN VPSPo ON Scans.VPSPoID = VPSPo.ID
JOIN VPSKo ON VPSPo.VPSKoID = VPSKo.ID
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
JOIN Mitarbei ON VPSKo.AnlageUserID_ = Mitarbei.ID
WHERE Artikel.ArtikelNr LIKE N'L2G%'
  AND VPSKo.Anlage_ >= DATEADD(minute, - 180, GETDATE())
  AND Mitarbei.StandortID = (SELECT ID FROM Standort WHERE SuchCode = N'BUKA');