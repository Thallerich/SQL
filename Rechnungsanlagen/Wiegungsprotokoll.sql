BEGIN TRY
  DROP TABLE #TmpWieg;
  DROP TABLE #TmpWiegung1;
  DROP TABLE #TmpWiegung2;
  DROP TABLE #TmpWiegungList;
END TRY
BEGIN CATCH
END CATCH;

SELECT Wiegung.VsaID, Wiegung.Netto, Wiegung.Zeitpunkt, RechKo.RechNr, RechKo.RechDat, LsPo.KdArtiID
INTO #TmpWieg
FROM Wiegung, LsPo, RechPo, RechKo
WHERE Wiegung.LsPoID = LsPo.ID
  AND LsPo.RechPoID = RechPo.ID
  AND RechPo.RechKoID = RechKo.ID
  AND RechKo.ID = $RECHKOID$;

SELECT Kunden.KdNr, Kunden.SuchCode, Vsa.SuchCode AS VsaNr, Vsa.Bez AS Vsa, Wieg.RechNr, Wieg.RechDat, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, Wieg.Netto AS GewichtKG, DATEPART(weekday, Wieg.Zeitpunkt) AS Wochentag, KdArti.KdBerID AS KdBerID, Vsa.StandKonID
INTO #TmpWiegung1
FROM #TmpWieg Wieg, Kunden, Vsa, KdArti, Artikel
WHERE Wieg.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND Wieg.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID;

SELECT Wiegung1.KdNr, Wiegung1.SuchCode, Wiegung1.VsaNr, Wiegung1.Vsa, Wiegung1.RechNr, Wiegung1.RechDat, Wiegung1.ArtikelNr, Wiegung1.ArtikelBez, SUM(Wiegung1.GewichtKG) AS GewichtKG, Wiegung1.Wochentag, Standort.Bez AS Expedition
INTO #TmpWiegung2
FROM #TmpWiegung1 Wiegung1, KdBer, StandBer, Standort
WHERE Wiegung1.KdBerID = KdBer.ID
  AND KdBer.BereichID = StandBer.BereichID
  AND StandBer.StandKonID = Wiegung1.StandKonID
  AND StandBer.ExpeditionID = Standort.ID
GROUP BY Wiegung1.KdNr, Wiegung1.SuchCode, Wiegung1.VsaNr, Wiegung1.Vsa, Wiegung1.RechNr, Wiegung1.RechDat, Wiegung1.ArtikelNr, Wiegung1.ArtikelBez, Wiegung1.Wochentag, Standort.Bez;

SELECT w.Expedition, w.KdNr, w.SuchCode, w.VsaNr, w.Vsa, w.RechNr, w.RechDat, w.ArtikelNr, w.ArtikelBez,
  CONVERT(float, 0) AS Montag,
  CONVERT(float, 0) AS Dienstag,
  CONVERT(float, 0) AS Mittwoch,
  CONVERT(float, 0) AS Donnerstag,
  CONVERT(float, 0) AS Freitag,
  CONVERT(float, 0) AS Samstag,
  CONVERT(float, 0) AS Sonntag
INTO #TmpWiegungList
FROM #TmpWiegung2 w
GROUP BY w.Expedition, w.KdNr, w.SuchCode, w.VsaNr, w.Vsa, w.RechNr, w.RechDat, w.ArtikelNr, w.ArtikelBez;

UPDATE wl SET wl.Montag = w.GewichtKG
FROM #TmpWiegungList wl, #TmpWiegung2 w
WHERE wl.ArtikelNr = w.ArtikelNr
  AND wl.Expedition = w.Expedition
  AND w.Wochentag = 2;

UPDATE wl SET wl.Dienstag = w.GewichtKG
FROM #TmpWiegungList wl, #TmpWiegung2 w
WHERE wl.ArtikelNr = w.ArtikelNr
  AND wl.Expedition = w.Expedition
  AND w.Wochentag = 3;

UPDATE wl SET wl.Mittwoch = w.GewichtKG
FROM #TmpWiegungList wl, #TmpWiegung2 w
WHERE wl.ArtikelNr = w.ArtikelNr
  AND wl.Expedition = w.Expedition
  AND w.Wochentag = 4;

UPDATE wl SET wl.Donnerstag = w.GewichtKG
FROM #TmpWiegungList wl, #TmpWiegung2 w
WHERE wl.ArtikelNr = w.ArtikelNr
  AND wl.Expedition = w.Expedition
  AND w.Wochentag = 5;

UPDATE wl SET wl.Freitag = w.GewichtKG
FROM #TmpWiegungList wl, #TmpWiegung2 w
WHERE wl.ArtikelNr = w.ArtikelNr
  AND wl.Expedition = w.Expedition
  AND w.Wochentag = 6;

UPDATE wl SET wl.Samstag = w.GewichtKG
FROM #TmpWiegungList wl, #TmpWiegung2 w
WHERE wl.ArtikelNr = w.ArtikelNr
  AND wl.Expedition = w.Expedition
  AND w.Wochentag = 7;

UPDATE wl SET wl.Sonntag = w.GewichtKG
FROM #TmpWiegungList wl, #TmpWiegung2 w
WHERE wl.ArtikelNr = w.ArtikelNr
  AND wl.Expedition = w.Expedition
  AND w.Wochentag = 1;

SELECT * FROM #TmpWiegungList;