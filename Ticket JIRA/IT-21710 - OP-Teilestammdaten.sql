WITH OPTeileStatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'OPTEILE')
),
NachwaescheScan AS (
  SELECT OPScans.OPTeileID, COUNT(OPScans.ID) AS [NWScans]
  FROM OPScans
  JOIN ZielNr ON OPScans.ZielNrID = ZielNr.ID
  WHERE ZielNr.Funktion = N'N'
    AND OPScans.Zeitpunkt BETWEEN N'2018-10-01 00:00:00' AND N'2019-01-01 00:00:00'
  GROUP BY OPScans.OPTeileID
)
SELECT OPTeile.Code AS Barcode, OPTeileStatus.StatusBez AS [Status OP-Teil], Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, OPTeile.Erstwoche AS [Ersteinsatz-Woche], OPTeile.AnzWasch AS [Anzahl Wäschen], OPTeile.LastScanTime AS [Letzter Scan-Zeitpunkt], OPTeile.LastScanToKunde AS [Letzter Auslese-Scan], NachwaescheScan.NWScans AS [Nachwäsche-Scans]
FROM OPTeile
JOIN OPTeileStatus ON OPTeile.Status = OPTeileStatus.Status
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
LEFT OUTER JOIN NachwaescheScan ON NachwaescheScan.OPTeileID = OPTeile.ID
WHERE OPTeile.Status < N'W'
  AND Artikel.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = N'OP')
  AND OPTeile.LastScanTime > N'2014-01-01 00:00:00'
  AND Artikel.ArtikelNr NOT LIKE N'O%'
  AND OPTeile.ArtikelID NOT IN (SELECT OPSets.ArtikelID FROM OPSets);