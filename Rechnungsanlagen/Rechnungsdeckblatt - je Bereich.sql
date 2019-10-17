DROP TABLE IF EXISTS #Final;

SELECT CONVERT(money, 0) AS BW, CONVERT(money, 0) AS BK, CONVERT(money, 0) AS SH, CONVERT(money, 0) AS EW, CONVERT(money, 0) AS IK, CONVERT(money, 0) AS OP, CONVERT(money, 0) AS TW, CONVERT(money, 0) AS BG, CONVERT(money, 0) AS MA, CONVERT(money, 0) AS Summe, Abteil.ID AS AbteilID, Abteil.Bez AS KsSt, Kunden.UStIDNr, Kunden.KdNr, Kunden.ID AS KundenID, RechKo.RechDat, RechKo.RechNr, RechKo.Art, RechKo.VonDatum, RechKo.BisDatum, RechKo.FaelligDat, RechKo.Nettowert, RechKo.Bruttowert, RechKo.MwStBetrag, RechKo.MwStSatz, TRIM(ZahlZiel.BezDruckMemo$LAN$) AS ZahlZielText
INTO #Final
FROM RechPo, RechKo, Kunden, Abteil, Bereich, ZahlZiel
WHERE RechPo.RechKoID = RechKo.ID
  AND RechPo.AbteilID = Abteil.ID
  AND RechKo.KundenID = Kunden.ID
  AND RechPo.BereichID = Bereich.ID
  AND RechKo.ZahlZielID = ZahlZiel.ID
  AND RechKo.ID = $RECHKOID$
GROUP BY Abteil.ID, Abteil.Bez, Kunden.UStIDNr, Kunden.KdNr, Kunden.ID, RechKo.RechDat, RechKo.RechNr, RechKo.Art, RechKo.VonDatum, RechKo.BisDatum, RechKo.FaelligDat, RechKo.Nettowert, RechKo.Bruttowert, RechKo.MwStBetrag, RechKo.MwStSatz, ZahlZiel.BezDruckMemo$LAN$;

UPDATE F SET BW = x.Summe
FROM #Final AS F, (
  SELECT RechPo.AbteilID, SUM(RechPo.GPreis) AS Summe
  FROM RechPo
  WHERE RechPo.RechKoID = $RECHKOID$
    AND RechPo.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = 'BK')
    AND RechPo.ArtGruID IN (SELECT ArtGru.ID FROM ArtGru WHERE ArtGru.Gruppe = N'OPK')
  GROUP BY RechPo.AbteilID
) AS x
WHERE F.AbteilID = x.AbteilID;

UPDATE F SET BK = x.Summe
FROM #Final AS F, (
  SELECT RechPo.AbteilID, SUM(RechPo.GPreis) AS Summe
  FROM RechPo
  WHERE RechPo.RechKoID = $RECHKOID$
    AND RechPo.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = 'BK')
    AND RechPo.ArtGruID NOT IN (SELECT ArtGru.ID FROM ArtGru WHERE ArtGru.Gruppe IN (N'BGP', N'OPK'))
  GROUP BY RechPo.AbteilID
) AS x
WHERE F.AbteilID = x.AbteilID;

UPDATE F SET SH = x.Summe
FROM #Final AS F, (
  SELECT RechPo.AbteilID, SUM(RechPo.GPreis) AS Summe
  FROM RechPo
  WHERE RechPo.RechKoID = $RECHKOID$
    AND RechPo.BereichID IN (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich IN (N'FW', N'FWL', N'SHC'))
  GROUP BY RechPo.AbteilID
) AS x
WHERE F.AbteilID = x.AbteilID;

UPDATE F SET EW = x.Summe
FROM #Final AS F, (
  SELECT RechPo.AbteilID, SUM(RechPo.GPreis) AS Summe
  FROM RechPo
  WHERE RechPo.RechKoID = $RECHKOID$
    AND RechPo.BereichID IN (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = N'LW')
  GROUP BY RechPo.AbteilID
) AS x
WHERE F.AbteilID = x.AbteilID;

UPDATE F SET IK = x.Summe
FROM #Final AS F, (
  SELECT RechPo.AbteilID, SUM(RechPo.GPreis) AS Summe
  FROM RechPo
  WHERE RechPo.RechKoID = $RECHKOID$
    AND RechPo.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = 'IK')
  GROUP BY RechPo.AbteilID
) AS x
WHERE F.AbteilID = x.AbteilID;

UPDATE F SET OP = x.Summe
FROM #Final AS F, (
  SELECT RechPo.AbteilID, SUM(RechPo.GPreis) AS Summe
  FROM RechPo
  WHERE RechPo.RechKoID = $RECHKOID$
    AND RechPo.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = 'ST')
  GROUP BY RechPo.AbteilID
) AS x
WHERE F.AbteilID = x.AbteilID;

UPDATE F SET TW = x.Summe
FROM #Final AS F, (
  SELECT RechPo.AbteilID, SUM(RechPo.GPreis) AS Summe
  FROM RechPo
  WHERE RechPo.RechKoID = $RECHKOID$
    AND RechPo.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = 'TW')
  GROUP BY RechPo.AbteilID
) AS x
WHERE F.AbteilID = x.AbteilID;

UPDATE F SET BG = x.Summe
FROM #Final AS F, (
  SELECT RechPo.AbteilID, SUM(RechPo.GPreis) AS Summe
  FROM RechPo
  WHERE RechPo.RechKoID = $RECHKOID$
    AND RechPo.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = 'BK')
    AND RechPo.ArtGruID = (SELECT ID FROM ArtGru WHERE ArtGru.Gruppe = N'BGP')
  GROUP BY RechPo.AbteilID
) AS x
WHERE F.AbteilID = x.AbteilID;

UPDATE F SET MA = x.Summe
FROM #Final AS F, (
  SELECT RechPo.AbteilID, SUM(RechPo.GPreis) AS Summe
  FROM RechPo
  WHERE RechPo.RechKoID = $RECHKOID$
    AND RechPo.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = 'MA')
  GROUP BY RechPo.AbteilID
) AS x
WHERE F.AbteilID = x.AbteilID;

UPDATE #Final SET Summe = BW + BK + SH + EW + IK + OP + TW + BG + MA;

SELECT * FROM #Final ORDER BY KsSt;