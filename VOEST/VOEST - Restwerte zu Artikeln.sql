SELECT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, COUNT(EinzTeil.ID) AS [Anzahl Teile], SUM(CAST(EinzHist.RestwertInfo AS decimal(18,4))) AS Restwert
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Vsa ON EinzHist.VsaID = Vsa.ID
JOIN Kunden ON EinzHist.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
WHERE Holding.Holding = N'VOES'
  AND Artikel.ArtikelNr IN ('29V1', '29V3', '70V3', '70V4', '70V6', '45V3', '45V4', '45V5', '46V2', '44V2', '15V2', '41V2', '42V2', '46V5', '44V5', '41VB', '42VB', '45VL', '46VL', '44VL', '41VL', '04VC', '70VR', '05VT', '15VT', '04VT', '06VT', '01VT', '08VT', '05LT', '04LT', '01LT', '06LT')
  AND EinzHist.EinzHistTyp = 1
  AND EinzTeil.AltenheimModus = 0
  AND EinzHist.Kostenlos = 0
  AND ISNULL(EinzHist.Indienst, '1980/01') <= '2026/03'
  AND ISNULL(EinzHist.Ausdienst, '2099/52') > '2026/03'
  AND Traeger.Status NOT IN ('K', 'P')
  AND Vsa.Status = 'A'
GROUP BY Artikel.ArtikelNr, Artikel.ArtikelBez;