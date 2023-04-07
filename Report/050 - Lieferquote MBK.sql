DROP TABLE IF EXISTS #TmpFinal;

SELECT KdGf.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, StandBer.Metrik, 0 AS [Geplanter Ausgang], 0 AS [Tatsächlicher Ausgang], 0 AS Fehlteile, 0 AS [Nachwäsche], 0 AS Magazin, 0 AS [Reparatur Nähen], 0 AS Speicher, 0 AS Austausch, Vsa.ID AS VsaID
INTO #TmpFinal
FROM Vsa, Kunden, KdGf, StandKon, VsaTour, Touren, KdBer, (
  SELECT SdcDev.Bez AS Metrik, StandBer.BereichID, StandBer.StandKonID
  FROM StandBer, StBerSDC, SdcDev
  WHERE StBerSDC.SdcDevID = SdcDev.ID
    AND StBerSDC.StandBerID = StandBer.ID
    AND SdcDev.ID IN ($1$)
    AND StandBer.BereichID IN ($2$)
) StandBer
WHERE Vsa.KundenID = Kunden.ID
  AND Kunden.KdGfID = KdGf.ID
  AND Vsa.StandKonID = StandKon.ID
  AND StandBer.StandKonID = StandKon.ID
  AND VsaTour.VsaID = Vsa.ID
  AND VsaTour.TourenID = Touren.ID
  AND VsaTour.KdBerID = KdBer.ID
  AND KdBer.BereichID = StandBer.BereichID
  AND Touren.Wochentag = CONVERT(char(1), IIF(DATEPART(dw, GETDATE()) - 1 = 0, 6, DATEPART(dw, GETDATE()) - 1))
  AND VsaTour.Bringen = 1
GROUP BY KdGf.KurzBez, Kunden.KdNr, Kunden.SuchCode, StandBer.Metrik, Vsa.ID;

UPDATE Final SET Fehlteile = AnzTeileRueckstand
FROM #TmpFinal Final, (
  SELECT Vsa.ID AS VsaID, COUNT(Prod.EinzHistID) AS AnzTeileRueckstand
  FROM Prod, Vsa, EinzHist, KdArti, KdBer
  WHERE Prod.VsaID = Vsa.ID
    AND Prod.EinzHistID = EinzHist.ID
    AND Prod.KdArtiID = KdArti.ID
    AND KdArti.KdBerID = KdBer.ID
    AND KdBer.BereichID IN ($2$)
    AND EinzHist.Status IN ('M', 'N', 'Q') --gepatcht, Dauer-BC, aktiv
    AND Prod.AusDat <= GETDATE()
  GROUP BY Vsa.ID
) Rueckstand
WHERE Rueckstand.VsaID = Final.VsaID;

UPDATE Final SET [Nachwäsche] = AnzNachwaesche
FROM #TmpFinal Final, (
  SELECT Vsa.ID AS VsaID, COUNT(Prod.EinzHistID) AS AnzNachwaesche
  FROM Prod, Vsa, EinzHist, KdArti, KdBer
  WHERE Prod.VsaID = Vsa.ID
    AND Prod.EinzHistID = EinzHist.ID
    AND Prod.KdArtiID = KdArti.ID
    AND KdArti.KdBerID = KdBer.ID
    AND KdBer.BereichID IN ($2$)
    AND EinzHist.Status IN ('M', 'N', 'Q') --gepatcht, Dauer-BC, aktiv
    AND Prod.AusDat <= GETDATE()
    AND Prod.ZielNrID IN (
      SELECT ZielNr.ID
      FROM ZielNr
      WHERE ZielNr.LeitstandSpalte = 'Nachwäsche'
    )
  GROUP BY Vsa.ID
) Nachwaesche
WHERE Nachwaesche.VsaID = Final.VsaID;

UPDATE Final SET Magazin = AnzMagazin
FROM #TmpFinal Final, (
  SELECT Vsa.ID AS VsaID, COUNT(Prod.EinzHistID) AS AnzMagazin
  FROM Prod, Vsa, EinzHist, KdArti, KdBer
  WHERE Prod.VsaID = Vsa.ID
    AND Prod.EinzHistID = EinzHist.ID
    AND Prod.KdArtiID = KdArti.ID
    AND KdArti.KdBerID = KdBer.ID
    AND KdBer.BereichID IN ($2$)
    AND EinzHist.Status IN ('M', 'N', 'Q') --gepatcht, Dauer-BC, aktiv
    AND Prod.AusDat <= GETDATE()
    AND Prod.ZielNrID IN (1109003, 109003, 209003) -- Metrik Enns, Lenzing 1 und 2: Lager Magazin
  GROUP BY Vsa.ID
) Magazin
WHERE Magazin.VsaID = Final.VsaID;

UPDATE Final SET [Reparatur Nähen] = AnzReparatur
FROM #TmpFinal Final, (
  SELECT Vsa.ID AS VsaID, COUNT(Prod.EinzHistID) AS AnzReparatur
  FROM Prod, Vsa, EinzHist, KdArti, KdBer
  WHERE Prod.VsaID = Vsa.ID
    AND Prod.EinzHistID = EinzHist.ID
    AND Prod.KdArtiID = KdArti.ID
    AND KdArti.KdBerID = KdBer.ID
    AND KdBer.BereichID IN ($2$)
    AND EinzHist.Status IN ('M', 'N', 'Q') --gepatcht, Dauer-BC, aktiv
    AND Prod.AusDat <= GETDATE()
    AND Prod.ZielNrID IN (
      SELECT ZielNr.ID
      FROM ZielNr
      WHERE ZielNr.LeitstandSpalte = 'Reparatur'
    )
  GROUP BY Vsa.ID
) Reparatur
WHERE Reparatur.VsaID = Final.VsaID;

UPDATE Final SET Speicher = AnzSpeicher
FROM #TmpFinal Final, (
  SELECT Vsa.ID AS VsaID, COUNT(Prod.EinzHistID) AS AnzSpeicher
  FROM Prod, Vsa, EinzHist, KdArti, KdBer
  WHERE Prod.VsaID = Vsa.ID
    AND Prod.EinzHistID = EinzHist.ID
    AND Prod.KdArtiID = KdArti.ID
    AND KdArti.KdBerID = KdBer.ID
    AND KdBer.BereichID IN ($2$)
    AND EinzHist.Status IN ('M', 'N', 'Q') --gepatcht, Dauer-BC, aktiv
    AND Prod.AusDat <= GETDATE()
    AND Prod.ZielNrID IN (
      SELECT ZielNr.ID
      FROM ZielNr
      WHERE ZielNr.LeitstandSpalte = 'Speicher'
    )
  GROUP BY Vsa.ID
) Speicher
WHERE Speicher.VsaID = Final.VsaID;

UPDATE Final SET Austausch = AnzAustausch
FROM #TmpFinal Final, (
  SELECT Vsa.ID AS VsaID, COUNT(Prod.EinzHistID) AS AnzAustausch
  FROM Prod, Vsa, EinzHist, KdArti, KdBer
  WHERE Prod.VsaID = Vsa.ID
    AND Prod.EinzHistID = EinzHist.ID
    AND Prod.KdArtiID = KdArti.ID
    AND KdArti.KdBerID = KdBer.ID
    AND KdBer.BereichID IN ($2$)
    AND EinzHist.Status IN ('M', 'N', 'Q') --gepatcht, Dauer-BC, aktiv
    AND Prod.AusDat <= GETDATE()
    AND Prod.ZielNrID IN (109002, 209002, 1109002)  -- Lenzing 1 und 2, Enns - Austausch
  GROUP BY Vsa.ID
) Austausch
WHERE Austausch.VsaID = Final.VsaID;

UPDATE Final SET Final.[Tatsächlicher Ausgang] = Ausgang.Ausgang
FROM #TmpFinal Final, (
  SELECT Final.VsaID, KdBer.BereichID, COUNT(Scans.EinzHistID) AS Ausgang
  FROM #TmpFinal Final, LsKo, LsPo, Scans, KdArti, KdBer
  WHERE Final.VsaID = LsKo.VsaID
    AND LsPo.LsKoID = LsKo.ID
    AND Scans.LsPoID = LsPo.ID
    AND LsPo.KdArtiID = KdArti.ID
    AND KdArti.KdBerID = KdBer.ID
    AND LsKo.Datum = cast(GETDATE() as Date)
  GROUP BY Final.VsaID, KdBer.BereichID
) Ausgang
WHERE Final.VsaID = Ausgang.VsaID
  AND Ausgang.BereichID IN ($2$);

UPDATE #TmpFinal SET [Geplanter Ausgang] = [Tatsächlicher Ausgang] + Fehlteile;

SELECT SGF, KdNr, Kunde, Metrik, FORMAT(GETDATE(), 'dd.MM.yyyy', 'de-AT') AS Lieferdatum, SUM([Geplanter Ausgang]) AS [Geplanter Ausgang], SUM([Tatsächlicher Ausgang]) AS [Tatsächlicher Ausgang], SUM(Fehlteile) AS Fehlteile, SUM([Nachwäsche]) AS [Nachwäsche], SUM(Magazin) AS Magazin, SUM([Reparatur Nähen]) AS [Reparatur Nähen], SUM(Speicher) AS Speicher, SUM(Austausch) AS Austausch, SUM([Tatsächlicher Ausgang]) * 100 / IIF(SUM([Geplanter Ausgang]) = 0, 1, SUM([Geplanter Ausgang])) AS [Lieferquote (%)]
FROM #TmpFinal
WHERE [Geplanter Ausgang] <> 0
GROUP BY SGF, KdNr, Kunde, Metrik
ORDER BY [Lieferquote (%)] ASC;