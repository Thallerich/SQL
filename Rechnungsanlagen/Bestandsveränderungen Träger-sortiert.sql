SELECT Abteil.Abteilung, Abteil.Bez AS AbteilBez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, Wochen.Woche, Traeger.Traeger, Traeger.PersNr, ISNULL(RTRIM(Traeger.Nachname), '') + IIF(Traeger.Vorname IS NULL, '', ', ' + RTRIM(Traeger.Vorname)) AS TraegerName, DiffCode.DiffCodeBez$LAN$ AS Code, SUM(LeasDiff.MengenDiff) AS MengenDiff, SUM(LeasDiff.WoPaDiff) AS WoPaDiff
FROM LeasDiff, Wochen, Traeger, DiffCode, Abteil, Artikel, KdArti
WHERE Wochen.ID IN (
  SELECT Wochen.ID
  FROM Wochen
  WHERE Wochen.ID >= (SELECT Wochen.ID FROM Wochen, RechKo WHERE Wochen.Woche = RechKo.ErsteWo AND RechKo.ID = $RECHKOID$)
    AND Wochen.ID <= (SELECT RechKo.MasterWochenID FROM RechKo WHERE RechKo.ID = $RECHKOID$)
)
  AND LeasDiff.WochenID = Wochen.ID
  AND Abteil.KundenID = $KUNDENID$
  AND LeasDiff.AbteilID = Abteil.ID
  AND LeasDiff.TraegerID = Traeger.ID
  AND LeasDiff.Code = DiffCode.ID
  AND LeasDiff.KdArtiID = KdArti.ID
  AND KdArti.ArtikelID = Artikel.ID
  AND KdArti.KdBerID IN (
    SELECT KdBer.ID
    FROM KdBer
    WHERE KdBer.BereichID IN (
      SELECT BereichID
      FROM RechPo, Bereich
      WHERE Bereich.ID = RechPo.BereichID
        AND Bereich.Altenheim = $FALSE$
        AND RechPo.RechKoID = $RECHKOID$
    )
  )
  AND Abteil.ID IN (
    SELECT RechPo.AbteilID
    FROM RechPO
    WHERE RechPo.RechKoID = $RECHKOID$
  )
GROUP BY Abteil.Abteilung, Abteil.Bez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$, Wochen.Woche, Traeger.Traeger, Traeger.PersNr, Traeger.Nachname, Traeger.Vorname, DiffCode.DiffCodeBez$LAN$
HAVING SUM(LeasDiff.MengenDiff) <> 0
ORDER BY Abteil.Abteilung, TraegerName, Wochen.Woche;