SELECT Firma.SuchCode AS Firma, KdGf.KurzBez AS Geschäftsbereich, [Zone].ZonenCode AS Vertriebszone, Kunden.KdNr, Kunden.SuchCode AS Kunde, DrLauf.Bez AS Drucklauf, BrLauf.BrLaufBez AS Bearbeitungsrechnungslauf, Artikel.ArtikelNr, Artikel.ArtikelBez, KdArti.Variante, Abteil.Abteilung AS KsSt, Abteil.Bez AS Kostenstelle, KdArti.LeasPreis, AbtKdArW.Menge, Wochen.Woche, KdArti.ID AS KdArtiID
FROM AbtKdArW
JOIN Wochen ON AbtKdArW.WochenID = Wochen.ID
JOIN Week ON Wochen.Woche = Week.Woche
JOIN KdArti ON AbtKdArW.KdArtiID = KdArti.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN FakFreq ON KdBer.FakFreqID = FakFreq.ID
JOIN FakPer ON FakFreq.FakPerID = FakPer.ID
JOIN Abteil ON AbtKdArW.AbteilID = Abteil.ID
JOIN Vsa ON AbtKdArW.VsaID = Vsa.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN DrLauf ON Kunden.DrLaufID = DrLauf.ID
JOIN BrLauf ON Kunden.BRLaufID = BrLauf.ID
WHERE Firma.ID = $2$
  AND Week.VonDat >= $STARTDATE$
  AND Week.BisDat <= $ENDDATE$
  AND KdGf.ID IN ($3$)
  AND DrLauf.ID IN ($4$)
  AND BrLauf.ID IN ($5$)
  AND AbtKdArW.RechPoID = -1
  AND AbtKdArW.EPreis * AbtKdArW.Menge != 0
  AND Kunden.KdNr NOT IN (2300, 6060) /* Ausnahme lt. SvobKu - Kunden mit Berufsgruppen-Faktura, Rechnung wird hier immer storniert! */
  AND NOT EXISTS (
    SELECT a.*
    FROM AbtKdArW AS a
    JOIN Wochen AS wo ON a.WochenID = wo.ID
    JOIN Week AS w ON wo.Woche = w.Woche
    WHERE a.AbteilID = AbtKdArW.AbteilID
      AND a.KdArtiID = AbtKdArW.KdArtiID
      AND w.VonDat >= $STARTDATE$
      AND w.BisDat <= $ENDDATE$
      AND a.RechPoID > 0
  )
  AND (
      (FakPer.ID = 1 AND EXISTS (
        SELECT a.*
        FROM AbtKdArW a
        JOIN Wochen AS w ON a.WochenID = w.ID
        WHERE a.AbteilID = AbtKdArW.AbteilID
        AND a.KdArtiID = AbtKdArW.KdArtiID
        AND w.Woche = (SELECT MAX(Week.Woche) FROM Week WHERE Week.VonDat >= $STARTDATE$ AND Week.BisDat <= $ENDDATE$)
      ))
    OR
      (FakPer.ID != 1)
  );