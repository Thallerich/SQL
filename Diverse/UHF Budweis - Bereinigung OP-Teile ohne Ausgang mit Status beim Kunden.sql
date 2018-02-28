DROP TABLE IF EXISTS #TmpCleanup;

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS Vsa, OPTeile.Code, Artikel.ArtikelNr, Artikel.ArtikelBez, [Status].StatusBez AS Teilestatus, Actions.ActionsBez AS [Letzte Aktion], OPScans.Zeitpunkt AS [Auslese-Zeitpunkt], AnfKo.Lieferdatum, AnfKo.AuftragsNr AS [PZ-Nr], ZielNr.ZielNrBez AS [Letzter Reader], OPScans.Zeitpunkt AS [Scan-Zeitpunkt]
INTO #TmpCleanup
FROM (
  SELECT OPTeile.ID AS OPTeileID, (SELECT MAX(OPScans.ID) AS OPScansID FROM OPScans WHERE OPScans.OPTeileID = OPTeile.ID AND OPScans.InvPoID < 0) AS OPScansID
  FROM OPTeile
  JOIN Vsa ON OPTeile.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN Standort ON Kunden.StandortID = Standort.ID
  JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
  WHERE --Artikel.ArtikelNr = N'111228825501'
    Standort.Bez = N'Budweis'
    --AND Vsa.VsaNr = 1
    AND OPTeile.[Status] = N'Q'
    AND OPTeile.LastActionsID = 102
) AS OPData
JOIN OPScans ON OPData.OPScansID = OPScans.ID
JOIN OPTeile ON OPData.OPTeileID = OPTeile.ID
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
JOIN AnfPo ON OPScans.AnfPoID = AnfPo.ID
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN Vsa ON AnfKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Actions ON OPTeile.LastActionsID = Actions.ID
JOIN [Status] ON OPTeile.[Status] = [Status].[Status] AND [Status].Tabelle = N'OPTEILE'
JOIN ZielNr ON OPScans.ZielNrID = ZielNr.ID
WHERE Kunden.KdNr = 0;

UPDATE OPTeile SET LastActionsID = 100
FROM OPTeile
JOIN #TmpCleanup AS Cleanup ON Cleanup.Code = OPTeile.Code AND Cleanup.[Letzter Reader] LIKE N'Einlesen%'
WHERE OPTeile.LastActionsID = 102;