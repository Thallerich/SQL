USE Wozabal;
GO

DROP TABLE IF EXISTS #PreResult;
GO

WITH OPScans_Tunnel AS
(
  SELECT OPScans.Zeitpunkt, OPScans.OPTeileID
  FROM OPScans
  WHERE OPScans.Zeitpunkt BETWEEN N'2018-04-01 00:00:00' AND N'2018-06-15 23:59:59'
    AND OPScans.ZielNrID = 300 -- OP-Einlesen unrein (Tunnel)
)
SELECT OPTeile.Code, OPTeile.Code2, OPScans_Tunnel.Zeitpunkt AS [Einlese-Zeitpunkt], Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, (
  SELECT MAX(OPScans.ID)
  FROM OPScans
  WHERE OPScans.OPTeileID = OPScans_Tunnel.OPTeileID
    AND OPScans.Zeitpunkt < OPScans_Tunnel.Zeitpunkt
    AND OPScans.ActionsID = 102
) AS AusgangsScanID
INTO #PreResult
FROM OPScans_Tunnel
JOIN OPTeile ON OPScans_Tunnel.OPTeileID = OPTeile.ID
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID;

GO

SELECT PreResult.Code, PreResult.Code2, PreResult.[Einlese-Zeitpunkt], PreResult.ArtikelNr, PreResult.Artikelbezeichnung, Kunden.KdNr AS [letzte KdNr], Kunden.SuchCode AS [letzter Kunde], Vsa.VsaNr AS [letzte VSANr], Vsa.Bez AS [letzte VSA]
FROM #PreResult AS PreResult
JOIN OPScans ON PreResult.AusgangsScanID = OPScans.ID
JOIN AnfPo ON OPScans.AnfPoID = AnfPo.ID
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN Vsa ON AnfKo.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
ORDER BY [Einlese-Zeitpunkt] ASC;

GO