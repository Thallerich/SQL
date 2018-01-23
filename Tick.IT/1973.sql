DECLARE @von TIMESTAMP;
DECLARE @bis TIMESTAMP;

@von = CONVERT($1$ + ' 00:00:00', SQL_TIMESTAMP);
@bis = CONVERT($2$ + ' 23:59:59', SQL_TIMESTAMP);

TRY
  DROP TABLE #TmpScans;
CATCH ALL END;

SELECT Scans.*
INTO #TmpScans
FROM Scans
WHERE Scans.Menge = 1
  AND Scans.DateTime BETWEEN @von AND @bis
  AND Scans.LsPoID < 0;

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Artikel.ArtikelNr, Artikel.ArtikelBez, COUNT(Scans.ID) AS [Anzahl Eingänge]
FROM #TmpScans Scans, Teile, Vsa, Kunden, ViewArtikel Artikel
WHERE Scans.TeileID = Teile.ID
  AND Teile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Teile.ArtikelID = Artikel.ID
  AND Artikel.ID = $ID$
GROUP BY KdNr, Kunde, VsaNr, Vsa, ArtikelNr, ArtikelBez;