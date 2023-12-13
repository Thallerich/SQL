UPDATE Vsa SET Name3 = ISNULL(Vsa.Name3 + N' - ', N'') + N'NH'
WHERE Vsa.StandKonID IN (SELECT StandKon.ID FROM StandKon WHERE StandKon.StandKonBez IN (N'Produktion GP Enns', N'Produktion GP Enns -  Lager Enns->Linz'))
  AND CHARINDEX(N'NH', Vsa.Name3) = 0
  AND LEN(ISNULL(Vsa.Name3 + N' - ', N'') + N'NH') <= 40;

GO

UPDATE Vsa SET Name3 = ISNULL(Vsa.Name3 + N' - ', N'') + N'SH'
WHERE Vsa.StandKonID IN (SELECT StandKon.ID FROM StandKon WHERE StandKon.StandKonBez IN (N'FW: Enns', N'FW: Enns - Lager Enns->Linz'))
  AND CHARINDEX(N'SH', Vsa.Name3) = 0
  AND LEN(ISNULL(Vsa.Name3 + N' - ', N'') + N'SH') <= 40;

GO

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Name1, Vsa.Name2, Vsa.Name3
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Vsa.StandKonID IN (SELECT StandKon.ID FROM StandKon WHERE StandKon.StandKonBez IN (N'Produktion GP Enns', N'Produktion GP Enns -  Lager Enns->Linz'))
  AND Vsa.[Status] = N'A'
  AND CHARINDEX(N'NH', Vsa.Name3) = 0
  AND LEN(ISNULL(Vsa.Name3 + N' - ', N'') + N'NH') > 40;

GO

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Name1, Vsa.Name2, Vsa.Name3
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
WHERE Vsa.StandKonID IN (SELECT StandKon.ID FROM StandKon WHERE StandKon.StandKonBez IN (N'FW: Enns', N'FW: Enns - Lager Enns->Linz'))
  AND Vsa.[Status] = N'A'
  AND CHARINDEX(N'SH', Vsa.Name3) = 0
  AND LEN(ISNULL(Vsa.Name3 + N' - ', N'') + N'SH') > 40;

GO