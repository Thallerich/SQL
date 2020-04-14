WITH Patchteile AS (
  SELECT Teile.ID AS TeileID, 
    Teile.PatchDatum,
    Teile.ArtikelID,
    Teile.LagerArtID,
    LastPatchScanID = (SELECT TOP 1 Scans.ID FROM Scans WHERE ActionsID = 23 AND Scans.TeileID = Teile.ID ORDER BY Anlage_ DESC)   -- ActionsID 23 -> Patchen
  FROM Teile
  WHERE Teile.PatchDatum BETWEEN $1$ AND $2$
    AND Teile.LagerArtID IN (
      SELECT LagerArt.ID
      FROM LagerArt
      WHERE LagerArt.LagerID IN ($3$)
    )
)
SELECT Patchteile.PatchDatum,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung,
  COUNT(Patchteile.TeileID) AS [Anzahl gepatcht],
  SUM(IIF(LagerArt.Neuwertig = 1, 1, 0)) AS [davon Neuware],
  SUM(IIF(Lagerart.Neuwertig = 0, 1, 0)) AS [davon Gebrauchtware],
  Mitarbei.Name AS Mitarbeiter
FROM Patchteile
JOIN Artikel ON Patchteile.ArtikelID = Artikel.ID
JOIN LagerArt ON Patchteile.LagerArtID = LagerArt.ID
JOIN Scans ON Patchteile.LastPatchScanID = Scans.ID
JOIN Mitarbei ON Scans.AnlageUserID_ = Mitarbei.ID
WHERE LagerArt.SichtbarID IN ($SICHTBARIDS$)
GROUP BY Patchteile.PatchDatum, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, Mitarbei.Name
ORDER BY PatchDatum, ArtikelNr, Mitarbeiter;