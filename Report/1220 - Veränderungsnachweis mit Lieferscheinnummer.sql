DECLARE @KundenID int = $ID$;
DECLARE @VonWoche nchar(7) = $1$;
DECLARE @BisWoche nchar(7) = $2$

SELECT Abteilung, AbteilBez, ArtikelNr, Bez, Woche, Traeger, PersNr, TraegerName, Code,
  LsNr = STUFF(
    (
      SELECT ',' + CAST(LsKo.LsNr AS VARCHAR) LsNr
      FROM LsKo, LsPo, KdArti, Teile
      WHERE LsPo.LsKoID = LsKo.ID
        AND LsPo.KdArtiID = KdArti.ID
        AND LsPo.ID > 0
        AND CASE WHEN SUM(Daten.MengenDiff) > 0 THEN Teile.FirstLsPoID WHEN SUM(Daten.MengenDiff) < 0 THEN Teile.EinzugLsPoID END = LsPo.ID
        AND CASE WHEN SUM(Daten.MengenDiff) > 0 THEN Teile.Indienst WHEN SUM(Daten.MengenDiff) < 0 THEN Teile.Abmeldung END = Daten.Woche
        AND Teile.TraegerID = Daten.TraegerID
        AND KdArti.ArtikelID = Daten.ArtikelID
      GROUP BY LsKo.LsNr
      ORDER BY LsKo.LsNr
      FOR XML PATH(''), TYPE
    ).value('.', 'nvarchar(max)'), 1, 1, ''),
  SUM(MengenDiff) AS MengenDiff,
  SUM(WoPaDiff) AS WoPaDiff
FROM (
  SELECT Abteil.Abteilung, Abteil.Bez AS AbteilBez, Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ Bez, Wochen.Woche, Traeger.Traeger, Traeger.PersNr, IIf(Traeger.Nachname IS NULL, '', RTrim(Traeger.Nachname)) + IIf(Traeger.Vorname IS NULL, '', ', ' + RTrim(Traeger.Vorname)) AS TraegerName, DiffCode.DiffCodeBez$LAN$ AS Code, Traeger.ID TraegerID, Artikel.ID ArtikelID, LeasDiff.MengenDiff, LeasDiff.WoPaDiff
  FROM LeasDiff, Wochen, Traeger, DiffCode, Abteil, Artikel, KdArti
  WHERE Wochen.Woche BETWEEN @VonWoche AND @BisWoche
    AND LeasDiff.WochenID = Wochen.ID
    AND Abteil.KundenID = @KundenID
    AND LeasDiff.AbteilID = Abteil.ID
    AND LeasDiff.TraegerID = Traeger.ID
    AND LeasDiff.Code = DiffCode.ID
    AND LeasDiff.KdArtiID = KdArti.ID
    AND KdArti.ArtikelID = Artikel.ID
  ) AS Daten
  WHERE WoPaDiff != 0
    --AND AbteilBez = N'Plasmazentrum Salzburg C116922 2050'
GROUP BY Abteilung, AbteilBez, ArtikelNr, Bez, Woche, Traeger, PersNr, TraegerName, Code, TraegerID, ArtikelID
ORDER BY Abteilung, ArtikelNr, Woche;