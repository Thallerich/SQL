TRY
  DROP TABLE #TmpFinal;
CATCH ALL END;

SELECT KdGf.KurzBez AS SGF, Kunden.KdNr, Kunden.SuchCode AS Kunde, StandBer.Metrik, 0 AS [Geplanter Ausgang], 0 AS [Tatsächlicher Ausgang], 0 AS Fehlteile, 0 AS [Nachwäsche], 0 AS Magazin, 0 AS [Reparatur Nähen], 0 AS Speicher, 0 AS Austausch, Vsa.ID AS VsaID
INTO #TmpFinal
FROM Vsa, Kunden, KdGf, StandKon, VsaTour, Touren, KdBer, (
  SELECT SdcDev.Bez AS Metrik, StandBer.BereichID, StandBer.StandKonID
  FROM StandBer, SdcDev
  WHERE StandBer.SdcDevID = SdcDev.ID
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
  AND Touren.Wochentag = CONVERT(IIF(DAYOFWEEK(CURDATE()) - 1 = 0, 7, DAYOFWEEK(CURDATE()) - 1), SQL_CHAR)
  AND VsaTour.Bringen = TRUE
GROUP BY SGF, Kunden.KdNr, Kunde, Metrik, VsaID;

UPDATE Final SET Fehlteile = AnzTeileRueckstand
FROM #TmpFinal Final, (
  SELECT Vsa.ID AS VsaID, COUNT(Prod.TeileID) AS AnzTeileRueckstand
  FROM Prod, Vsa, Teile, KdArti, KdBer
  WHERE Prod.VsaID = Vsa.ID
    AND Prod.TeileID = Teile.ID
    AND Prod.KdArtiID = KdArti.ID
    AND KdArti.KdBerID = KdBer.ID
    AND KdBer.BereichID IN ($2$)
    AND Teile.Status IN ('M', 'N', 'Q') --gepatcht, Dauer-BC, aktiv
    AND Prod.AusDat <= CURDATE()
  GROUP BY VsaID
) Rueckstand
WHERE Rueckstand.VsaID = Final.VsaID;

UPDATE Final SET [Nachwäsche] = AnzNachwaesche
FROM #TmpFinal Final, (
  SELECT Vsa.ID AS VsaID, COUNT(Prod.TeileID) AS AnzNachwaesche
  FROM Prod, Vsa, Teile, KdArti, KdBer
  WHERE Prod.VsaID = Vsa.ID
    AND Prod.TeileID = Teile.ID
    AND Prod.KdArtiID = KdArti.ID
    AND KdArti.KdBerID = KdBer.ID
    AND KdBer.BereichID IN ($2$)
    AND Teile.Status IN ('M', 'N', 'Q') --gepatcht, Dauer-BC, aktiv
    AND Prod.AusDat <= CURDATE()
    AND Prod.ZielNrID IN (
      SELECT ZielNr.ID
      FROM ZielNr
      WHERE ZielNr.LeitstandSpalte = 'Nachwäsche'
    )
  GROUP BY VsaID
) Nachwaesche
WHERE Nachwaesche.VsaID = Final.VsaID;

UPDATE Final SET Magazin = AnzMagazin
FROM #TmpFinal Final, (
  SELECT Vsa.ID AS VsaID, COUNT(Prod.TeileID) AS AnzMagazin
  FROM Prod, Vsa, Teile, KdArti, KdBer
  WHERE Prod.VsaID = Vsa.ID
    AND Prod.TeileID = Teile.ID
    AND Prod.KdArtiID = KdArti.ID
    AND KdArti.KdBerID = KdBer.ID
    AND KdBer.BereichID IN ($2$)
    AND Teile.Status IN ('M', 'N', 'Q') --gepatcht, Dauer-BC, aktiv
    AND Prod.AusDat <= CURDATE()
    AND Prod.ZielNrID IN (1109003, 109003, 209003) -- Metrik Enns, Lenzing 1 und 2: Lager Magazin
  GROUP BY VsaID
) Magazin
WHERE Magazin.VsaID = Final.VsaID;

UPDATE Final SET [Reparatur Nähen] = AnzReparatur
FROM #TmpFinal Final, (
  SELECT Vsa.ID AS VsaID, COUNT(Prod.TeileID) AS AnzReparatur
  FROM Prod, Vsa, Teile, KdArti, KdBer
  WHERE Prod.VsaID = Vsa.ID
    AND Prod.TeileID = Teile.ID
    AND Prod.KdArtiID = KdArti.ID
    AND KdArti.KdBerID = KdBer.ID
    AND KdBer.BereichID IN ($2$)
    AND Teile.Status IN ('M', 'N', 'Q') --gepatcht, Dauer-BC, aktiv
    AND Prod.AusDat <= CURDATE()
    AND Prod.ZielNrID IN (
      SELECT ZielNr.ID
      FROM ZielNr
      WHERE ZielNr.LeitstandSpalte = 'Reparatur'
    )
  GROUP BY VsaID
) Reparatur
WHERE Reparatur.VsaID = Final.VsaID;

UPDATE Final SET Speicher = AnzSpeicher
FROM #TmpFinal Final, (
  SELECT Vsa.ID AS VsaID, COUNT(Prod.TeileID) AS AnzSpeicher
  FROM Prod, Vsa, Teile, KdArti, KdBer
  WHERE Prod.VsaID = Vsa.ID
    AND Prod.TeileID = Teile.ID
    AND Prod.KdArtiID = KdArti.ID
    AND KdArti.KdBerID = KdBer.ID
    AND KdBer.BereichID IN ($2$)
    AND Teile.Status IN ('M', 'N', 'Q') --gepatcht, Dauer-BC, aktiv
    AND Prod.AusDat <= CURDATE()
    AND Prod.ZielNrID IN (
      SELECT ZielNr.ID
      FROM ZielNr
      WHERE ZielNr.LeitstandSpalte = 'Speicher'
    )
  GROUP BY VsaID
) Speicher
WHERE Speicher.VsaID = Final.VsaID;

UPDATE Final SET Austausch = AnzAustausch
FROM #TmpFinal Final, (
  SELECT Vsa.ID AS VsaID, COUNT(Prod.TeileID) AS AnzAustausch
  FROM Prod, Vsa, Teile, KdArti, KdBer
  WHERE Prod.VsaID = Vsa.ID
    AND Prod.TeileID = Teile.ID
    AND Prod.KdArtiID = KdArti.ID
    AND KdArti.KdBerID = KdBer.ID
    AND KdBer.BereichID IN ($2$)
    AND Teile.Status IN ('M', 'N', 'Q') --gepatcht, Dauer-BC, aktiv
    AND Prod.AusDat <= CURDATE()
    AND Prod.ZielNrID IN (109002, 209002, 1109002)  -- Lenzing 1 und 2, Enns - Austausch
  GROUP BY VsaID
) Austausch
WHERE Austausch.VsaID = Final.VsaID;

UPDATE Final SET Final.[Tatsächlicher Ausgang] = Ausgang.Ausgang
FROM #TmpFinal Final, (
  SELECT Final.VsaID, KdBer.BereichID, COUNT(Scans.TeileID) AS Ausgang
  FROM #TmpFinal Final, LsKo, LsPo, Scans, KdArti, KdBer
  WHERE Final.VsaID = LsKo.VsaID
    AND LsPo.LsKoID = LsKo.ID
    AND Scans.LsPoID = LsPo.ID
    AND LsPo.KdArtiID = KdArti.ID
    AND KdArti.KdBerID = KdBer.ID
    AND LsKo.Datum = CURDATE()
  GROUP BY Final.VsaID, KdBer.BereichID
) Ausgang
WHERE Final.VsaID = Ausgang.VsaID
  AND Ausgang.BereichID IN ($2$);

UPDATE #TmpFinal SET [Geplanter Ausgang] = [Tatsächlicher Ausgang] + Fehlteile;
    
SELECT SGF, KdNr, Kunde, Metrik, CURDATE() AS Lieferdatum, SUM([Geplanter Ausgang]) AS [Geplanter Ausgang], SUM([Tatsächlicher Ausgang]) AS [Tatsächlicher Ausgang], SUM(Fehlteile) AS Fehlteile, SUM([Nachwäsche]) AS [Nachwäsche], SUM(Magazin) AS Magazin, SUM([Reparatur Nähen]) AS [Reparatur Nähen], SUM(Speicher) AS Speicher, SUM(Austausch) AS Austausch, SUM([Tatsächlicher Ausgang]) * 100 / IIF(SUM([Geplanter Ausgang]) = 0, 1, SUM([Geplanter Ausgang])) AS [Lieferquote (%)]
FROM #TmpFinal
WHERE [Geplanter Ausgang] <> 0
GROUP BY SGF, KdNr, Kunde, Metrik, Lieferdatum
ORDER BY [Lieferquote (%)] ASC;