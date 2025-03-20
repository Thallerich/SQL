DECLARE @firstweek nchar(7) = NULL,
  @lastweek nchar(7) = NULL,
  @useweeks bit = 0;

SELECT @useweeks = (SELECT IIF(RechKo.ErsteWo IS NOT NULL AND RechKo.MasterWochenID > 0, 1, 0) FROM RechKo WHERE RechKo.ID = $RECHKOID$);

IF @useweeks = 1
BEGIN
  SELECT @firstweek = (SELECT Wochen.Woche FROM Wochen, RechKo WHERE Wochen.Woche = RechKo.ErsteWo AND RechKo.ID = $RECHKOID$);
  SELECT @lastweek = (SELECT Wochen.Woche FROM Wochen, RechKo WHERE RechKo.MasterWochenID = Wochen.ID AND RechKo.ID = $RECHKOID$);
END
ELSE
BEGIN
  SELECT @firstweek = (SELECT Wochen.Woche FROM RechKo, [Week], Wochen WHERE RechKo.VonDatum BETWEEN Week.VonDat AND Week.BisDat AND Week.Woche = Wochen.Woche AND RechKo.ID = $RECHKOID$);
  SELECT @lastweek = (SELECT Wochen.Woche FROM RechKo, [Week], Wochen WHERE RechKo.BisDatum BETWEEN Week.VonDat AND Week.BisDat AND Week.Woche = Wochen.Woche AND RechKo.ID = $RECHKOID$);
END;

IF (@firstweek IS NOT NULL AND @lastweek IS NOT NULL)
BEGIN
  SELECT Abteil.Abteilung, Abteil.Bez AS AbteilBez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS ArtikelBez, Wochen.Woche, Traeger.Traeger, Traeger.PersNr, Coalesce(RTRIM(Traeger.Nachname), '') + IIF(Traeger.Vorname IS NULL, '', ', ' + RTRIM(Traeger.Vorname)) AS TraegerName, DiffCode.DiffCodeBez$LAN$ AS Code, SUM(LeasDiff.MengenDiff) AS MengenDiff, SUM(LeasDiff.WoPaDiff) AS WoPaDiff
  FROM LeasDiff, Wochen, Traeger, DiffCode, Abteil, Artikel, KdArti
  WHERE Wochen.Woche BETWEEN @firstweek AND @lastweek
    AND LeasDiff.WochenID = Wochen.ID
    AND Abteil.KundenID = $KUNDENID$
    AND LeasDiff.AbteilID = Abteil.ID
    AND LeasDiff.TraegerID = Traeger.ID
    AND Traeger.ID > 0
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
          AND Bereich.Altenheim = 0
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
END
ELSE
BEGIN
  SELECT TOP 0 NULL;
END;