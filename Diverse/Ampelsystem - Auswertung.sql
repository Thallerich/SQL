DROP TABLE IF EXISTS #Result;

CREATE TABLE #Result (
  KdArtiID int,
  AnzSchrott int
);

DECLARE @CurrentWeek nchar(7) = (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat);
DECLARE @from datetime2 = DATEADD(MONTH, DATEDIFF(MONTH, 0, GETDATE())-1, 0), @to datetime2 = DATEADD(MONTH, DATEDIFF(MONTH, -1, GETDATE())-1, -1);
DECLARE @sqltext nvarchar(max);

SET @sqltext = N'
  INSERT INTO #Result (KdArtiID, AnzSchrott)
  SELECT KdArti.ID AS KdArtiID, COUNT(DISTINCT EinzHist.ID) AS AnzSchrott
  FROM TeilSoFa
  JOIN EinzHist ON TeilSoFa.EinzHistID = EinzHist.ID
  JOIN KdArti ON EinzHist.KdArtiID = KdArti.ID
  JOIN Kunden ON EinzHist.KundenID = Kunden.ID
  WHERE TeilSoFa.Zeitpunkt BETWEEN @from AND @to
    AND EinzHist.PoolFkt = 0
    AND Kunden.StandortID = (SELECT ID FROM Standort WHERE Standort.SuchCode = N''SAWR'')
    AND TeilSoFa.SoFaArt = N''R''
    AND (EinzHist.Status = N''Y'' OR (EinzHist.Status = N''S'' AND EinzHist.WegGrundID > 0))
    AND Kunden.KdNr NOT IN (10005396, 100151)
    AND NOT EXISTS (
      SELECT SoFaCheck.*
      FROM TeilSoFa SoFaCheck
      WHERE SoFaCheck.EinzHistID = EinzHist.ID
        AND SoFaCheck.SoFaArt = N''R''
        AND SoFaCheck.Zeitpunkt < CAST(@from AS datetime2)
        AND SoFaCheck.AlterWochen = TeilSoFa.AlterWochen
    )
  GROUP BY KdArti.ID;
';

EXEC sp_executesql @sqltext, N'@from date, @to date', @from, @to;

WITH UmlaufPerKdArti AS (
  SELECT KdArtiID, SUM(Umlauf) AS Umlauf
  FROM (
    SELECT VsaLeas.VsaID, - 1 AS TraegerID, VsaLeas.KdArtiID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, SUM(VsaLeas.Menge) AS Umlauf
    FROM VsaLeas
    JOIN Vsa ON VsaLeas.VsaID = Vsa.ID
    JOIN KdArti ON VsaLeas.KdArtiID = KdArti.ID
    LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID AND ArtGroe.Groesse = N'-'
    WHERE @CurrentWeek BETWEEN ISNULL(VsaLeas.Indienst, N'1980/01') AND ISNULL(VsaLeas.Ausdienst, N'2099/52')
    GROUP BY VsaLeas.VsaID, VsaLeas.KdArtiID, COALESCE(ArtGroe.ID, -1), KdArti.ArtikelID

    UNION ALL

    SELECT VsaAnf.VsaID, - 1 AS TraegerID, VsaAnf.KdArtiID, COALESCE(IIF(VsaAnf.ArtGroeID < 0, NULL, VsaAnf.ArtGroeID), ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, SUM(VsaAnf.Bestand) AS Umlauf
    FROM VsaAnf
    JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
    LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID AND ArtGroe.Groesse = N'-'
    WHERE VsaAnf.Bestand != 0
      AND VsaAnf.[Status] = N'A'
    GROUP BY VsaAnf.VsaID, VsaAnf.KdArtiID, COALESCE(IIF(VsaAnf.ArtGroeID < 0, NULL, VsaAnf.ArtGroeID), ArtGroe.ID, -1), KdArti.ArtikelID

    UNION ALL

    SELECT Strumpf.VsaID, - 1 AS TraegerID, Strumpf.KdArtiID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, COUNT(Strumpf.ID) AS Umlauf
    FROM Strumpf
    JOIN KdArti ON Strumpf.KdArtiID = KdArti.ID
    LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID AND ArtGroe.Groesse = N'-'
    WHERE Strumpf.[Status] != N'X'
      AND ISNULL(Strumpf.Indienst, N'1980/01') >= @CurrentWeek
      AND Strumpf.WegGrundID < 0
    GROUP BY Strumpf.VsaID, Strumpf.KdArtiID, COALESCE(ArtGroe.ID, -1), KdArti.ArtikelID
    
    UNION ALL

    SELECT Traeger.VsaID, TraeArti.TraegerID, TraeArti.KdArtiID, TraeArti.ArtGroeID, KdArti.ArtikelID, TraeArti.Menge AS Umlauf
    FROM TraeArti
    JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
    JOIN KdArti ON TraeArti.KdArtiID = KdArti.ID
    WHERE @CurrentWeek BETWEEN ISNULL(Traeger.Indienst, N'1980/01') AND ISNULL(Traeger.Ausdienst, N'2099/52')

    UNION ALL

    SELECT Traeger.VsaID, TraeArti.TraegerID, KdArti.ID AS KdArtiID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, TraeArti.Menge AS Umlauf
    FROM TraeArti
    JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
    JOIN KdArAppl ON TraeArti.KdArtiID = KdArAppl.KdArtiID
    JOIN KdArti ON KdArAppl.ApplKdArtiID = KdArti.ID
    LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID
    WHERE @CurrentWeek BETWEEN ISNULL(Traeger.Indienst, N'1980/01') AND ISNULL(Traeger.Ausdienst, N'2099/52')
      AND KdArAppl.ArtiTypeID = 3  --Emblem

    UNION ALL

    SELECT Traeger.VsaID, TraeArti.TraegerID, KdArti.ID AS KdArtiID, COALESCE(ArtGroe.ID, -1) AS ArtGroeID, KdArti.ArtikelID, TraeArti.Menge AS Umlauf
    FROM TraeArti
    JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
    JOIN KdArAppl ON TraeArti.KdArtiID = KdArAppl.KdArtiID
    JOIN KdArti ON KdArAppl.ApplKdArtiID = KdArti.ID
    LEFT JOIN ArtGroe ON KdArti.ArtikelID = ArtGroe.ArtikelID
    WHERE @CurrentWeek BETWEEN ISNULL(Traeger.Indienst, N'1980/01') AND ISNULL(Traeger.Ausdienst, N'2099/52')
      AND KdArAppl.ArtiTypeID = 2 --Namenschild
  ) AS x
  GROUP BY KdArtiID
),
LiefermPerKdArti AS (
  SELECT LsPo.KdArtiID, SUM(LsPo.Menge) AS Liefermenge
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  WHERE LsKo.Datum >= N'2024-08-01'
    AND LsKo.Datum <= N'2024-08-31'
  GROUP BY LsPo.KdArtiID
)
SELECT Kunden.KdNr,
  Kunden.SuchCode AS Kunde,
  Bereich.BereichBez AS Kundenbereich,
  Artikel.ArtikelNr,
  Artikel.ArtikelBez AS Artikelbezeichnung,
  SUM(ISNULL(UmlaufPerKdArti.Umlauf, 0)) AS Umlaufmenge,
  SUM(ISNULL(LiefermPerKdArti.Liefermenge, 0)) AS Liefermenge,
  SUM(ISNULL(#Result.AnzSchrott, 0)) AS [Austausch absolut]
FROM KdArti
LEFT JOIN UmlaufPerKdArti ON KdArti.ID = UmlaufPerKdArti.KdArtiID
LEFT JOIN LiefermPerKdArti ON KdArti.ID = LiefermPerKdArti.KdArtiID
LEFT JOIN #Result ON KdArti.ID = #Result.KdArtiID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
WHERE Kunden.StandortID = (SELECT ID FROM Standort WHERE Standort.SuchCode = N'SAWR')
  AND Kunden.KdNr NOT IN (10005396, 100151)
GROUP BY Kunden.KdNr, Kunden.SuchCode, Bereich.BereichBez, Artikel.ArtikelNr, Artikel.ArtikelBez;