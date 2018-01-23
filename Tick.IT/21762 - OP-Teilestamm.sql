USE Wozabal
GO

SELECT OPTeile.Code AS Barcode, Status.StatusBez AS Status, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, OPTeile.Erstwoche, OPTeile.AnzWasch AS [Anzahl Wäschen], OPTeile.LastScanTime, OPTeile.LastScanToKunde
FROM OPTeile
JOIN Status ON OPTeile.Status = Status.Status AND Status.Tabelle = N'OPTEILE'
JOIN Artikel ON OPTeile.ArtikelID = Artikel.ID
WHERE OPTeile.Status < N'W'
  AND Artikel.BereichID = (SELECT Bereich.ID FROM Bereich WHERE Bereich.Bereich = N'OP')
  AND OPTeile.LastScanTime > N'2014-01-01 00:00:00'
  AND Artikel.ArtikelNr NOT LIKE N'O%'
  AND OPTeile.ArtikelID NOT IN (SELECT OPSets.ArtikelID FROM OPSets)

GO