WITH FirstInScan AS (
  SELECT Scans.EinzHistID, MIN(Scans.ID) AS FirstInScanID
  FROM Scans
  WHERE Scans.ActionsID IN (1, 2)
  GROUP BY Scans.EinzHistID
)
SELECT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGroe.Groesse, COUNT(EinzHist.ID) AS [Anzahl Teile], AVG(DATEDIFF(day, EinzHist.Anlage_, Scans.[DateTime])) AS [durchschnittliche Liefertage]
FROM EinzHist
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON EinzHist.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Lagerart ON EinzHist.LagerartID = Lagerart.ID
JOIN FirstInScan ON FirstInScan.EinzHistID = EinzHist.ID
JOIN Scans ON FirstInScan.FirstInScanID = Scans.ID
WHERE EinzHist.AltenheimModus = 0
  AND Scans.DateTime BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Kunden.KdGFID IN ($2$)
  AND Lagerart.LagerID IN ($3$)
  AND ((EinzHist.Status BETWEEN N'M' AND N'W') OR EinzHist.Status = N'Z')
  AND DATEDIFF(week, Scans.[DateTime], EinzHist.IndienstDat) BETWEEN -2 AND 2
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez, ArtGroe.Groesse;