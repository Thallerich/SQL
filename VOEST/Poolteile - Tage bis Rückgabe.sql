WITH PoolAusgabe AS (
  SELECT Scans.TeileID, Scans.[DateTime] AS Zeitpunkt, MIN(NextScan.ID) AS NextScanID
  FROM Scans
  LEFT JOIN Scans AS NextScan ON NextScan.TeileID = Scans.TeileID AND NextScan.[DateTime] > Scans.[DateTime] AND NextScan.ActionsID != 135
  WHERE Scans.ActionsID = 135
  GROUP BY Scans.TeileID, Scans.[DateTime]
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS VsaBezeichnung, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, Teile.Barcode, MIN(CAST(PoolAusgabe.Zeitpunkt AS date)) AS [Zeitpunkt Ausgabe an Träger], CAST(Scans.[DateTime] AS date) AS [Zeitpunkt Einlesen im Betrieb], DATEDIFF(day, MIN(PoolAusgabe.Zeitpunkt), Scans.[DateTime]) AS [Anzahl Tage bis Rückgabe]
FROM PoolAusgabe
LEFT JOIN Scans ON PoolAusgabe.NextScanID = Scans.ID
JOIN Teile ON PoolAusgabe.TeileID = Teile.ID
JOIN Vsa ON Teile.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN ArtGroe ON Teile.ArtGroeID = ArtGroe.ID
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
GROUP BY Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez, Teile.Barcode, CAST(Scans.[DateTime] AS date), Scans.[DateTime];

GO