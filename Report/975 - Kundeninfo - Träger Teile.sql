/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ PrepareData                                                                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DROP TABLE IF EXISTS #TmpKdInfo;

SELECT KdGf.KurzBez AS SGF,
  Standort.SuchCode AS Hauptstandort,
  Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Kundenservice = (
    SELECT TOP 1 Mitarbei.Name
    FROM KdBer
    JOIN Mitarbei ON KdBer.ServiceID = Mitarbei.ID
    WHERE KdBer.KundenID = Kunden.ID
    GROUP BY Mitarbei.Name
    ORDER BY COUNT(KdBer.ID) DESC
  ),
  Betreuer = (
    SELECT TOP 1 Mitarbei.Name
    FROM KdBer
    JOIN Mitarbei ON KdBer.BetreuerID = Mitarbei.ID
    WHERE KdBer.KundenID = Kunden.ID
    GROUP BY Mitarbei.Name
    ORDER BY COUNT(KdBer.ID) DESC
  ),
  Abteil.ID AS AbteilID,
  Abteil.Abteilung AS Kostenstelle,
  Abteil.Bez AS Kostenstellenbezeichnung,
  CAST(0 AS int) AS [Anzahl Träger],
  CAST(0 AS int) AS [Anzahl Teile],
  CAST(0 AS int) AS [Anzahl Pool-Träger], 
  CAST(0 AS int) AS [Anzahl Pool-Teile]
INTO #TmpKdInfo
FROM Kunden
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN Abteil ON Abteil.KundenID = Kunden.ID
WHERE Kunden.ID IN ($2$);
  
UPDATE KdInfo SET KdInfo.[Anzahl Träger] = TraeData.AnzTrae, KdInfo.[Anzahl Teile] = TraeData.AnzTeil
FROM #TmpKdInfo AS KdInfo, (
  SELECT Kunden.KdNr, Traeger.AbteilID, COUNT(DISTINCT Traeger.ID) AS AnzTrae, COUNT(DISTINCT EinzHist.ID) AS AnzTeil
  FROM #TmpKdInfo AS KdInfo, EinzTeil, EinzHist, Traeger, Vsa, Kunden
  WHERE EinzTeil.CurrEinzHistID = EinzHist.ID
    AND EinzHist.TraegerID = Traeger.ID
    AND Traeger.VsaID = Vsa.ID
    AND Vsa.KundenID = Kunden.ID
    AND Kunden.KdNr = KdInfo.KdNr
    AND EinzHist.Status IN ('Q', 'S')
    AND Traeger.Status <> 'I'
    AND EinzHist.PoolFkt = 0
    AND EinzHist.EinzHistTyp = 1
    AND UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) NOT LIKE '%POOL%' 
    AND UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) NOT LIKE '%GRÖßENSATZ%' 
    AND UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) NOT LIKE '%RESERVE%'
    AND UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) NOT LIKE '%OVERALL%'
    AND UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) NOT LIKE '%ÜBERSTIEFEL%'
    AND UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) NOT LIKE '%HAUBE%'
    AND UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) NOT LIKE '%RR%'
    AND UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) NOT LIKE '%ABDECKUNG%'
    AND UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) NOT LIKE '%T-SHIRT%'
    AND UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) NOT LIKE '%STERIL%'
    AND UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) NOT LIKE '%STERILFÄLLUNG%'
    AND UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) NOT LIKE '%STUDIE%'
    AND UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) NOT LIKE '%BEREICH%'
    AND UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) NOT LIKE '%EW%'
    AND UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) NOT LIKE '%BESUCHER%'
    AND UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) NOT LIKE '%MOP%'
  GROUP BY Kunden.KdNr, Traeger.AbteilID
) AS TraeData
WHERE TraeData.KdNr = KdInfo.KdNr
  AND TraeData.AbteilID = KdInfo.AbteilID;

UPDATE KdInfo SET KdInfo.[Anzahl Pool-Träger] = TraeData.AnzTrae, KdInfo.[Anzahl Pool-Teile] = TraeData.AnzTeil
FROM #TmpKdInfo AS KdInfo, (
  SELECT Kunden.KdNr, Traeger.AbteilID, COUNT(DISTINCT Traeger.ID) AS AnzTrae, COUNT(DISTINCT EinzHist.ID) AS AnzTeil
  FROM #TmpKdInfo AS KdInfo, EinzTeil, EinzHist, Traeger, Vsa, Kunden
  WHERE EinzTeil.CurrEinzHistID = EinzHist.ID
    AND EinzHist.TraegerID = Traeger.ID
    AND Traeger.VsaID = Vsa.ID
    AND Vsa.KundenID = Kunden.ID
    AND Kunden.KdNr = KdInfo.KdNr
    AND EinzHist.Status IN ('Q', 'S')
    AND Traeger.Status <> 'I'
    AND EinzHist.PoolFkt = 0
    AND EinzHist.EinzHistTyp = 1
    AND (UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) LIKE '%POOL%'          OR 
         UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) LIKE '%GRÖßENSATZ%'    OR 
         UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) LIKE '%RESERVE%'       OR 
         UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) LIKE '%OVERALL%'       OR 
         UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) LIKE '%ÜBERSTIEFEL%'   OR 
         UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) LIKE '%HAUBE%'         OR 
         UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) LIKE '%RR%'            OR 
         UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) LIKE '%ABDECKUNG%'     OR 
         UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) LIKE '%T-SHIRT%'       OR 
         UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) LIKE '%STERIL%'        OR 
         UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) LIKE '%STERILFÄLLUNG%' OR 
         UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) LIKE '%STUDIE%'        OR 
         UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) LIKE '%BEREICH%'       OR 
         UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) LIKE '%EW%'            OR 
         UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) LIKE '%BESUCHER%'      OR 
         UPPER(Coalesce(Vorname, '')) + UPPER(Coalesce(Nachname, '')) LIKE '%MOP%')
  GROUP BY Kunden.KdNr, Traeger.AbteilID
) AS TraeData
WHERE TraeData.KdNr = KdInfo.KdNr
  AND TraeData.AbteilID = KdInfo.AbteilID;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Reportdaten                                                                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @showksst bit = $3$;

IF @showksst = 0
BEGIN
  SELECT SGF, Hauptstandort, KdNr, Kunde, Kundenservice, Betreuer, SUM([Anzahl Träger]) AS [Anzahl Träger], SUM([Anzahl Teile]) AS [Anzahl Teile], SUM([Anzahl Pool-Träger]) AS [Anzahl Pool-Träger], SUM([Anzahl Pool-Teile]) AS [Anzahl Pool-Teile]
  FROM #TmpKdInfo
  GROUP BY SGF, Hauptstandort, KdNr, Kunde, Kundenservice, Betreuer
  ORDER BY SGF, KdNr;
END
ELSE
BEGIN
  SELECT SGF, Hauptstandort, KdNr, Kunde, Kundenservice, Betreuer, Kostenstelle, Kostenstellenbezeichnung, [Anzahl Träger], [Anzahl Teile], [Anzahl Pool-Träger], [Anzahl Pool-Teile]
  FROM #TmpKdInfo
  ORDER BY SGF, KdNr;
END;