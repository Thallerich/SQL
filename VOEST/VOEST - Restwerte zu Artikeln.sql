SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, COUNT(EinzTeil.ID) AS [Anzahl Teile], SUM(CAST(TeilSoFa.EPreis AS decimal(18,4))) AS Restwert
FROM TeilSoFa
JOIN EinzTeil ON TeilSoFa.EinzTeilID = EinzTeil.ID
JOIN EinzHist ON TeilSoFa.EinzHistID = EinzHist.ID
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON EinzHist.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
WHERE Holding.Holding = N'VOES'
  AND Artikel.ArtikelNr IN ('29V1', '29V3', '70V3', '70V4', '70V6', '45V3', '45V4', '45V5', '46V2', '44V2', '15V2', '41V2', '42V2', '46V5', '44V5', '41VB', '42VB', '45VL', '46VL', '44VL', '41VL', '04VC', '70VR', '05VT', '15VT', '04VT', '06VT', '01VT', '08VT', '05LT', '04LT', '01LT', '06LT')
  AND TeilSoFa.Zeitpunkt >= N'2025-01-01 00:00:00.000'
  AND TeilSoFa.Zeitpunkt <= N'2025-12-31 23:59:59.999'
  AND TeilSoFa.SoFaArt = N'R'
  AND TeilSoFa.[Status] >= N'H'
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez;