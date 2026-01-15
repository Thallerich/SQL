DECLARE @LagerID int = $2$;
DECLARE @von date = $STARTDATE$;
DECLARE @bis date = DATEADD(day, 1, $ENDDATE$);  -- add one day to include all stock transactions on the last day; date is implicitly converted to "dd.mm.yyyy 00:00:00", which would exclude all transactions on this date!
DECLARE @vonWoche nchar(7) = (SELECT Week.Woche FROM Week WHERE @von BETWEEN Week.VonDat AND Week.BisDat);
DECLARE @bisWoche nchar(7) = (SELECT Week.Woche FROM Week WHERE @bis BETWEEN Week.VonDat AND Week.BisDat);

WITH BestandNeu AS (
  SELECT Bestand.ArtGroeID, SUM(CAST(LastLagerBew.BestandNeu AS bigint)) AS Bestand, MAX(Bestand.LetzteBewegung) AS LetzteBewegung
  FROM Bestand
  OUTER APPLY (
    SELECT TOP 1 LagerBew.Zeitpunkt, LagerBew.BestandNeu
    FROM LagerBew
    WHERE LagerBew.BestandID = Bestand.ID
      AND LagerBew.Zeitpunkt <= @bis
    ORDER BY LagerBew.Zeitpunkt DESC, LagerBew.ID DESC
  ) AS LastLagerBew
  JOIN Lagerart ON Bestand.LagerArtID = Lagerart.ID
  WHERE Lagerart.ID IN ($3$)
    AND Lagerart.Neuwertig = 1
  GROUP BY Bestand.ArtGroeID
),
BestandGebraucht AS (
  SELECT Bestand.ArtGroeID, SUM(CAST(LastLagerBew.BestandNeu AS bigint)) AS Bestand, MAX(Bestand.LetzteBewegung) AS LetzteBewegung
  FROM Bestand
  OUTER APPLY (
    SELECT TOP 1 LagerBew.Zeitpunkt, LagerBew.BestandNeu
    FROM LagerBew
    WHERE LagerBew.BestandID = Bestand.ID
      AND LagerBew.Zeitpunkt <= @bis
    ORDER BY LagerBew.Zeitpunkt DESC, LagerBew.ID DESC
  ) AS LastLagerBew
  JOIN Lagerart ON Bestand.LagerArtID = Lagerart.ID
  WHERE Lagerart.ID IN ($3$)
    AND Lagerart.Neuwertig = 0
  GROUP BY Bestand.ArtGroeID
),
LagerBewNeu AS (
  SELECT Bestand.ArtGroeID, SUM(CAST(LagerBew.Differenz AS bigint)) AS Lagerabgang
  FROM LagerBew
  JOIN Bestand ON LagerBew.BestandID = Bestand.ID
  JOIN Lagerart ON Bestand.LagerArtID = Lagerart.ID
  WHERE Lagerart.ID IN ($3$)
    AND Lagerart.Neuwertig = 1
    AND LagerBew.Zeitpunkt BETWEEN @von AND @bis
    AND LagerBew.Differenz < 0
  GROUP BY Bestand.ArtGroeID
),
LagerBewGebraucht AS (
  SELECT Bestand.ArtGroeID, SUM(CAST(LagerBew.Differenz AS bigint)) AS Lagerabgang
  FROM LagerBew
  JOIN Bestand ON LagerBew.BestandID = Bestand.ID
  JOIN Lagerart ON Bestand.LagerArtID = Lagerart.ID
  WHERE Lagerart.ID IN ($3$)
    AND Lagerart.Neuwertig = 0
    AND LagerBew.Zeitpunkt BETWEEN @von AND @bis
    AND LagerBew.Differenz < 0
  GROUP BY Bestand.ArtGroeID
),
Kundenstand AS (
  SELECT x.ArtGroeID, SUM(x.Umlauf) AS Umlauf
  FROM (
    SELECT VsaLeas.VsaID, - 1 AS TraegerID, VsaLeas.KdArtiID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, SUM(VsaLeas.Menge) AS Umlauf
    FROM VsaLeas
    JOIN Vsa ON VsaLeas.VsaID = Vsa.ID
    JOIN KdArti ON VsaLeas.KdArtiID = KdArti.ID
    LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID AND ArtGroe.Groesse = N'-'
    WHERE ISNULL(VsaLeas.InDienst, N'1980/01') <= @bisWoche
      AND ISNULL(VsaLeas.AusDienst, N'2099/52') >= @vonWoche
    GROUP BY VsaLeas.VsaID, VsaLeas.KdArtiID, COALESCE(ArtGroe.ID, -1), KdArti.ArtikelID

    UNION ALL

    SELECT VsaAnf.VsaID, -1 AS TraegerID, VsaAnf.KdArtiID, COALESCE(IIF(VsaAnf.ArtGroeID < 0, NULL, VsaAnf.ArtGroeID), ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, SUM(VsaAnf.Bestand - VsaAnfBestandDiff.Differenz) AS Umlauf
    FROM VsaAnf
    JOIN (
      SELECT VsaAnfHi.VsaID, VsaAnfHi.KdArtiID, VsaAnfHi.ArtGroeID, SUM(VsaAnfHi.VertragDiff) AS Differenz
      FROM VsaAnfHi
      WHERE VsaAnfHi.Zeitpunkt > @bis
        AND VsaAnfHi.VertragDiff != 0
      GROUP BY VsaAnfHi.VsaID, VsaAnfHi.KdArtiID, VsaAnfHi.ArtGroeID
    ) AS VsaAnfBestandDiff ON VsaAnf.VsaID = VsaAnfBestandDiff.VsaID AND VsaAnf.KdArtiID = VsaAnfBestandDiff.KdArtiID AND VsaAnf.ArtGroeID = VsaAnfBestandDiff.ArtGroeID
    JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
    LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID AND ArtGroe.Groesse = N'-'
    WHERE VsaAnf.Bestand - VsaAnfBestandDiff.Differenz != 0
    GROUP BY VsaAnf.VsaID, VsaAnf.KdArtiID, COALESCE(IIF(VsaAnf.ArtGroeID < 0, NULL, VsaAnf.ArtGroeID), ArtGroe.ID, -1), KdArti.ArtikelID

    UNION ALL

    SELECT Strumpf.VsaID, - 1 AS TraegerID, Strumpf.KdArtiID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, COUNT(Strumpf.ID) AS Umlauf
    FROM Strumpf
    JOIN KdArti ON Strumpf.KdArtiID = KdArti.ID
    LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID AND ArtGroe.Groesse = N'-'
    WHERE Strumpf.[Status] != N'X'
      AND Strumpf.Indienst <= @bisWoche
      AND Strumpf.WegGrundID < 0  -- eigentlich müsste hier der Schrott-Scan ausgewertet werden, TPS-Strümpfe sind aber so geringe Mengen dass das hier nicht relevant ist und ich mir den Aufwand fürs erste spare -- THALST 2021-10-28
    GROUP BY Strumpf.VsaID, Strumpf.KdArtiID, COALESCE(ArtGroe.ID, -1), KdArti.ArtikelID
    
    UNION ALL

    SELECT Traeger.VsaID, EinzHist.TraegerID, EinzHist.KdArtiID, EinzHist.ArtGroeID, KdArti.ArtikelID, COUNT(EinzHist.ID) AS Umlauf
    FROM EinzHist
    JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
    JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
    WHERE Traeger.Indienst <= @bisWoche
      AND ISNULL(Traeger.Ausdienst, N'2099/52') >= @vonWoche
      AND EinzHist.Indienst <= @bisWoche
      AND ISNULL(EinzHist.Ausdienst, N'2099/52') >= @vonWoche
      AND Einzhist.Status in ('Q','W') -- IT 66134 - CM
    GROUP BY Traeger.VsaID, EinzHist.TraegerID, EinzHist.KdArtiID, EinzHist.ArtGroeID, KdArti.ArtikelID

    UNION ALL

    SELECT Traeger.VsaID, EinzHist.TraegerID, KdArti.ID AS KdArtiID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, COUNT(TeilAppl.ID) AS Umlauf
    FROM EinzHist
    JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
    JOIN TeilAppl ON TeilAppl.EinzHistID = EinzHist.ID
    JOIN KdArti ON TeilAppl.ApplKdArtiID = KdArti.ID
    LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID
    WHERE Traeger.Indienst <= @bisWoche
      AND ISNULL(Traeger.Ausdienst, N'2099/52') >= @vonWoche
      AND EinzHist.Indienst <= @bisWoche
      AND ISNULL(EinzHist.Ausdienst, N'2099/52') >= @vonWoche
      AND TeilAppl.ArtiTypeID = 3  --Emblem
      AND TeilAppl.Bearbeitung = N'-' --erledigt, Emblem aufgebracht
      AND Einzhist.Status in ('Q','W') -- IT 66134 - CM
    GROUP BY Traeger.VsaID, EinzHist.TraegerID, KdArti.ID, COALESCE(ArtGroe.ID, -1), KdArti.ArtikelID

    UNION ALL

    SELECT Traeger.VsaID, EinzHist.TraegerID, KdArti.ID AS KdArtiID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, COUNT(TeilAppl.ID) AS Umlauf
    FROM EinzHist
    JOIN Traeger ON EinzHist.TraegerID = Traeger.ID
    JOIN TeilAppl ON TeilAppl.EinzHistID = EinzHist.ID
    JOIN KdArti ON TeilAppl.ApplKdArtiID = KdArti.ID
    LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID
    WHERE Traeger.Indienst <= @bisWoche
      AND ISNULL(Traeger.Ausdienst, N'2099/52') >= @vonWoche
      AND EinzHist.Indienst <= @bisWoche
      AND ISNULL(EinzHist.Ausdienst, N'2099/52') >= @vonWoche
      AND TeilAppl.ArtiTypeID = 2 --Namenschild
      AND TeilAppl.Bearbeitung = N'-' --ereledigt, Namenschild aufgebracht
      AND Einzhist.Status in ('Q','W') -- IT 66134 - CM
    GROUP BY Traeger.VsaID, EinzHist.TraegerID, KdArti.ID, COALESCE(ArtGroe.ID, -1), KdArti.ArtikelID
  ) AS x
  JOIN Vsa ON x.VsaID = Vsa.ID
  JOIN KdArti ON x.KdArtiID = KdArti.ID
  JOIN KdBer ON KdArti.KdBerID = KdBer.ID
  JOIN StandBer ON Vsa.StandKonID = StandBer.StandKonID AND KdBer.BereichID = StandBer.BereichID
  WHERE (($4$ = 0 AND ((StandBer.LagerID = @LagerID AND StandBer.LokalLagerID < 0) OR StandBer.LokalLagerID = @LagerID)) OR ($4$ = 1))
  GROUP BY x.ArtGroeID
),
Artikelstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = UPPER(N'Artikel')
)
SELECT Artikel.ArtikelNr, ArtGroe.Groesse AS Größe, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, ArtGru.Gruppe AS Artikelgruppe, Artikelstatus.StatusBez AS [Status Artikel], ABC.ABC, ABC.ABCBez$LAN$ AS [ABC-Bezeichnung], Bereich.Bereich, Artikel.Umlaufmenge, SUM(ISNULL(BestandNeu.Bestand, 0)) AS Neu, MAX(BestandNeu.LetzteBewegung) AS [Letzte Lagerbewegung Neu], SUM(ISNULL(BestandGebraucht.Bestand, 0)) AS Gebraucht, MAX(BestandGebraucht.LetzteBewegung) AS [Letzte Lagerbewegung Gebraucht], SUM(ISNULL(LagerBewNeu.Lagerabgang, 0)) AS [Lagerabgang Neu], SUM(ISNULL(LagerBewGebraucht.Lagerabgang, 0)) AS [Lagerabgang gebraucht], SUM(ISNULL(Kundenstand.Umlauf, 0)) AS [aktuell Kundenstand]
FROM ArtGroe
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
JOIN Bereich on Bereich.id = Artikel.BereichID
JOIN Artikelstatus ON Artikel.[Status] = Artikelstatus.[Status]
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
LEFT JOIN BestandNeu ON BestandNeu.ArtGroeID = ArtGroe.ID
LEFT JOIN BestandGebraucht ON BestandGebraucht.ArtGroeID = ArtGroe.ID
LEFT JOIN LagerBewNeu ON LagerBewNeu.ArtGroeID = ArtGroe.ID
LEFT JOIN LagerBewGebraucht ON LagerBewGebraucht.ArtGroeID = ArtGroe.ID
LEFT JOIN Kundenstand ON Kundenstand.ArtGroeID = ArtGroe.ID
JOIN ABC ON ABC.ID = Artikel.ABCID
WHERE Artikel.ID > 0
AND ARTGRU.ID IN ($5$) -- MEYECR IT-86239
AND (($6$ = 1 AND Kundenstand.Umlauf > 0) OR ($6$ = 0)) -- DOBR IT-95508
GROUP BY Artikel.ArtikelNr, ArtGroe.Groesse, Artikel.ArtikelBez$LAN$, ArtGru.Gruppe, Artikelstatus.StatusBez, ABC.ABC, ABC.ABCBez$LAN$, Bereich.Bereich, Artikel.Umlaufmenge;