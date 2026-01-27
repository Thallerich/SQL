DROP TABLE IF EXISTS #Muellscans;
GO

SELECT Scans.[DateTime] AS Zeitpunkt, EinzTeil.Code AS Chipcode, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, LastScanID = (SELECT TOP 1 LastScan.ID FROM Scans AS LastScan WHERE LastScan.EinzTeilID = Scans.EinzTeilID AND LastScan.ID < Scans.ID ORDER BY LastScan.ID DESC)
INTO #Muellscans
FROM Scans
JOIN EinzTeil ON Scans.EinzTeilID = EinzTeil.ID
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
WHERE Scans.[DateTime] >= '2026-01-20 00:00:00.000'
  AND Scans.[DateTime] <  '2026-01-24 00:00:00.000'
  AND Scans.ZielNrID = 100070218;

GO

SELECT [Erfassungs-Zeitpunkt Müllraum] = #Muellscans.Zeitpunkt,
       Chipcode =                        #Muellscans.Chipcode,
       ArtikelNr =                       #Muellscans.ArtikelNr,
       Artikelbezeichnung =              #Muellscans.Artikelbezeichnung,
       KdNr =                            IIF(Scans.Menge = -1 AND Scans.LsPoID > 0, Kunden.KdNr, NULL),
       Kunde =                           IIF(Scans.Menge = -1 AND Scans.LsPoID > 0, Kunden.SuchCode, '(unbekannt)'),
       [Kunden-Adresszeile 1] =          IIF(Scans.Menge = -1 AND Scans.LsPoID > 0, Kunden.Name1, NULL),
       VsaNr =                           IIF(Scans.Menge = -1 AND Scans.LsPoID > 0, Vsa.VsaNr, NULL),
       [Vsa-Bezeichnung] =               IIF(Scans.Menge = -1 AND Scans.LsPoID > 0, Vsa.Bez, NULL),
       [Letztes Auslesen] =              IIF(Scans.Menge = -1 AND Scans.LsPoID > 0 , Scans.[DateTime], NULL)
FROM #Muellscans
LEFT JOIN Scans ON #Muellscans.LastScanID = Scans.ID
LEFT JOIN Vsa ON Scans.VsaID = Vsa.ID
LEFT JOIN Kunden ON Vsa.KundenID = Kunden.ID;

GO