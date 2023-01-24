DROP TABLE IF EXISTS #PartsPerLocation;

GO

CREATE TABLE #PartsPerLocation (
  LocationID int,
  SizeID int,
  AmountOfParts int
);

GO

INSERT INTO #PartsPerLocation
SELECT LastScanLocation, ArtGroeID, COUNT(*) AS AmountOfParts
FROM (
  SELECT LastScanLocation = (
    SELECT TOP 1 COALESCE(IIF(ZielNr.ProduktionsID < 0, NULL, ZielNr.ProduktionsID), IIF(ArbPlatz.StandortID < 0, NULL, ArbPlatz.StandortID)) AS StandortID
    FROM Scans
    JOIN ZielNr ON Scans.ZielNrID = ZielNr.ID
    JOIN ArbPlatz ON Scans.ArbPlatzID = ArbPlatz.ID
    WHERE (ZielNr.ProduktionsID > 0 OR ArbPlatz.StandortID > 0)
      AND Scans.EinzTeilID = EinzTeil.ID
    ORDER BY Scans.[DateTime] DESC
  ), EinzTeil.ArtGroeID
  FROM EinzTeil
  JOIN ArtGroe ON EinzTeil.ArtGroeID = ArtGroe.ID
  JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
  WHERE Artikel.ArtikelNr IN (N'U41', N'U4K', N'U32')
    AND EinzTeil.[Status] <= N'Q'
    AND ISNULL(EinzTeil.LastScanTime, N'1980-01-01 12:00:00') >= DATEADD(year, -1, GETDATE())
) x
WHERE LastScanLocation = (SELECT ID FROM Standort WHERE SuchCode = N'SAWR')
GROUP BY LastScanLocation, ArtGroeID;

GO

SELECT Standort.SuchCode AS Produktion, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, ArtGroe.Groesse, #PartsPerLocation.AmountOfParts AS [Anzahl Teile]
FROM #PartsPerLocation
JOIN ArtGroe ON #PartsPerLocation.SizeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Standort ON #PartsPerLocation.LocationID = Standort.ID;

GO