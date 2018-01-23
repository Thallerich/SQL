USE Wozabal
GO

SELECT Kunden.KdNr, 
       Kunden.SuchCode AS Kunde, 
	   Vsa.VsaNr AS [VSA-Nr], 
	   Vsa.SuchCode AS [VSA-Stichwort], 
	   Vsa.Bez AS VSA, 
	   OPTeile.Code AS Chipcode,
	   Status.Status AS Teilestatus, 
	   Artikel.ArtikelNr, 
	   Artikel.ArtikelBez AS Artikelbezeichnung,
	   FORMAT(OPTeile.LastScanTime, 'G', 'de-AT') AS [letzter Scan-Zeitpunkt],
	   FORMAT(OPTeile.LastScanToKunde, 'G', 'de-AT') AS [letzter Ausgangs-Scan],
	   FORMAT(OPTeile.EKGrundAkt, 'C', 'de-AT') AS [EK-Preis],
	   OPTeile.AlterInfo AS [Alter in Wochen],
	   FORMAT(IIF(OPTeile.AusDRestwert > 0, OPTeile.AusDRestwert, OPTeile.RestwertInfo), 'C', 'de-AT') AS Restwert
FROM OPTeile
JOIN Vsa ON OPTeile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
JOIN Status ON OPTeile.Status = Status.Status AND Status.Tabelle = N'OPTEILE'
WHERE OPTeile.Status IN (N'R', N'W')
AND Holding.Holding = N'SENECU'
ORDER BY Kunden.KdNr, [VSA-Nr], Artikel.ArtikelNr, [Alter in Wochen]

GO