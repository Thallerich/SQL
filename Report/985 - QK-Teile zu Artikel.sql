DROP TABLE IF EXISTS #TmpOPTeileQK;

SELECT [Actions].ActionsBez$LAN$ AS [Status], OPTeile.Code, OPTeile.Code2, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, MAX(OPScans.ID) AS LastOPScansID
INTO #TmpOPTeileQK
FROM Artikel, [Actions], OPTeile
LEFT OUTER JOIN OPScans ON OPScans.OPTeileID = OPTeile.ID
WHERE OPTeile.ArtikelID = Artikel.ID
  AND OPTeile.LastActionsID = [Actions].ID
  AND Artikel.ID = $ID$
  AND [Actions].ID = 109  --QK passiert
GROUP BY [Actions].ActionsBez$LAN$, OPTeile.Code, OPTeile.Code2, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$;

SELECT OPTeileQK.[Status], OPTeileQK.Code, OPTeileQK.Code2, OPTeileQK.ArtikelNr, OPTeileQK.Artikelbezeichnung, OPScans.Zeitpunkt AS ScanZeitpunkt, ZielNr.ZielNrBez$LAN$ AS ScanOrt, Mitarbei.UserName AS Benutzer, Mitarbei.Name
FROM #TmpOPTeileQK AS OPTeileQK
LEFT OUTER JOIN OPScans ON OPScans.ID = OPTeileQK.LastOPScansID
LEFT OUTER JOIN ZielNr ON OPScans.ZielNrID = ZielNr.ID
LEFT OUTER JOIN Mitarbei ON OPScans.AnlageUserID_ = Mitarbei.ID;