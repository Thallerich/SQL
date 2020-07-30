WITH FirstInScan AS (
  SELECT Scans.TeileID, MIN(Scans.ID) AS FirstInScanID
  FROM Scans
  WHERE Scans.ActionsID IN (1, 2)
  GROUP BY Scans.TeileID
)
SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, COUNT(Teile.ID) AS [Anzahl Teile], AVG(DATEDIFF(day, Teile.Anlage_, Scans.[DateTime])) AS [durchschnittliche Liefertage]
FROM Teile
JOIN Vsa ON Teile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Lagerart ON Teile.LagerartID = Lagerart.ID
JOIN FirstInScan ON FirstInScan.TeileID = Teile.ID
JOIN Scans ON FirstInScan.FirstInScanID = Scans.ID
WHERE Teile.AltenheimModus = 0
  AND Scans.DateTime BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Kunden.KdGFID IN ($2$)
  AND Lagerart.LagerID IN ($3$)
  AND (Teile.Status BETWEEN N'M' AND N'W' OR Teile.Status = N'Z')
  AND DATEDIFF(week, Scans.DateTime, Teile.IndienstDat) BETWEEN -2 AND 2
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse;