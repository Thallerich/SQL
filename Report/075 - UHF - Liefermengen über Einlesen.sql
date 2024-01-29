DROP TABLE IF EXISTS #PreAnf;
DROP TABLE IF EXISTS #Anf;
DROP TABLE IF EXISTS #VsaTour;

DECLARE @prodid int = $2$;

SELECT Scans.EingAnfPoID, EinzTeil.ArtikelID, CAST(Scans.[DateTime] AS date) AS ScanTime, COUNT(Scans.ID) AS Menge
INTO #PreAnf
FROM Scans
JOIN EinzTeil ON Scans.EinzTeilID = EinzTeil.ID
WHERE Scans.ZielNrID IN (SELECT ZielNr.ID FROM ZielNr WHERE ZielNr.ProduktionsID = @prodid)
  AND Scans.[DateTime] BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Scans.EingAnfPoID > 0
GROUP BY Scans.EingAnfPoID, EinzTeil.ArtikelID, CAST(Scans.[DateTime] AS date);

SELECT Vsa.KundenID, AnfKo.VsaID, #PreAnf.ArtikelID, AnfPo.KdArtiID, KdArti.KdBerID, #PreAnf.ScanTime, IIF(DATEPART(weekday, #PreAnf.ScanTime) - 1 = 0, 7, DATEPART(weekday, #PreAnf.ScanTime) - 1) AS ScanWochentag, #PreAnf.Menge, CAST(NULL AS int) AS HolenWochenTag, [Week].VonDat AS ErsterTagWoche
INTO #Anf
FROM #PreAnf
JOIN AnfPo ON #PreAnf.EingAnfPoID = AnfPo.ID
JOIN AnfKo ON AnfPo.AnfKoID = AnfKo.ID
JOIN KdArti ON AnfPo.KdArtiID = KdArti.ID
JOIN Vsa ON AnfKo.VsaID = Vsa.ID
JOIN [Week] ON #PreAnf.ScanTime BETWEEN [Week].VonDat AND [Week].BisDat
WHERE AnfKo.ProduktionID = @prodid;

WITH ReportKunden AS (
  SELECT DISTINCT #Anf.KundenID
  FROM #Anf
)
SELECT HolenVsaTour.VsaID, HolenVsaTour.KdBerID, HolenTour.ID AS HolenTourID, HolenVsaTour.ID AS HolenVsaTourID, HolenTour.Wochentag AS HolenWochentag, HolenVsaTour.MinBearbTage, BringenTour.ID AS BringenTourID, BringenVsaTour.ID AS BringenVsaTourID, BringenTour.Wochentag AS BringenWochentag
INTO #VsaTour
FROM ReportKunden
CROSS APPLY funcViewVsaTour(ReportKunden.KundenID, -1, 0, CAST(GETDATE() AS date), 0) AS fVsaTour
JOIN VsaTour AS HolenVsaTour ON fVsaTour.VsaTourID = HolenVsaTour.ID
JOIN Touren AS HolenTour ON HolenVsaTour.TourenID = HolenTour.ID
JOIN VsaTour AS BringenVsaTour ON fVsaTour.LiefVsaTourID = BringenVsaTour.ID
JOIN Touren AS BringenTour ON BringenVsaTour.TourenID = BringenTour.ID;

UPDATE #Anf SET HolenWochenTag = (SELECT TOP 1 #VsaTour.HolenWochentag FROM #VsaTour WHERE #VsaTour.VsaID = #Anf.VsaID AND #VsaTour.KdBerID = #Anf.KdBerID AND #VsaTour.HolenWochentag <= #Anf.ScanWochentag ORDER BY #VsaTour.HolenWochentag DESC);

/* Alles was im ersten Schritt nicht zugeordnet werden kann, springt in die Vorwoche - daher verwenden wir hier fix Sonntag (Wochentag 7) anstatt den tatsächlichen Scan-Wochentag */
UPDATE #Anf SET HolenWochenTag = (SELECT TOP 1 #VsaTour.HolenWochentag FROM #VsaTour WHERE #VsaTour.VsaID = #Anf.VsaID AND #VsaTour.KdBerID = #Anf.KdBerID AND #VsaTour.HolenWochentag <= 7 ORDER BY #VsaTour.HolenWochentag DESC), ErsterTagWoche = DATEADD(day, -7, #Anf.ErsterTagWoche)
WHERE #Anf.HolenWochenTag IS NULL;

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, SUM(#Anf.Menge) AS [Menge eingelesen], DATEADD(day, #Anf.HolenWochenTag - 1, #Anf.ErsterTagWoche) AS [abgeholt am], Abholwochentag.WochtagBez$LAN$ AS [abgeholt am Wochentag], DATEADD(day, #Anf.HolenWochentag - 1 + #VsaTour.MinBearbTage, #Anf.ErsterTagWoche) AS [liefern am], Lieferwochentag.WochtagBez$LAN$ AS [liefern am Wochentag]
FROM #Anf
JOIN #VsaTour ON #Anf.VsaID = #VsaTour.VsaID AND #Anf.KdBerID = #VsaTour.KdBerID AND #Anf.HolenWochenTag = #VsaTour.HolenWochentag
JOIN Kunden ON #Anf.KundenID = Kunden.ID
JOIN Vsa ON #Anf.VsaID = Vsa.ID
JOIN Artikel ON #Anf.ArtikelID = Artikel.ID
JOIN Wochtag AS Abholwochentag ON #VsaTour.HolenWochentag = Abholwochentag.Wochentag
JOIN Wochtag AS Lieferwochentag ON #VsaTour.BringenWochentag = Lieferwochentag.Wochentag
GROUP BY Kunden.KdNr, Kunden.SuchCode, Vsa.VsaNr, Vsa.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, DATEADD(day, #Anf.HolenWochenTag - 1, #Anf.ErsterTagWoche), Abholwochentag.WochtagBez$LAN$, DATEADD(day, #Anf.HolenWochenTag -1 + #VsaTour.MinBearbTage, #Anf.ErsterTagWoche), Lieferwochentag.WochtagBez$LAN$
ORDER BY [abgeholt am];