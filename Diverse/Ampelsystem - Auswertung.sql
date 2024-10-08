DROP TABLE IF EXISTS #Result, #Final;

CREATE TABLE #Result (
  KdArtiID int,
  AnzSchrott int
);

DECLARE @CurrentWeek nchar(7) = (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat);
DECLARE @from datetime2 = DATEADD(month, DATEDIFF(month, 0, GETDATE())-1, 0), @to datetime2 = DATEADD(month, DATEDIFF(month, -1, GETDATE())-1, -1);
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
  SELECT _Umlauf.KdArtiID, SUM(_Umlauf.Umlauf) AS Umlauf
  FROM _Umlauf
  WHERE _Umlauf.Datum = (SELECT MAX(_Umlauf.Datum) FROM _Umlauf WHERE _Umlauf.Datum BETWEEN @from AND @to)
  GROUP BY _Umlauf.KdArtiID
),
LiefermPerKdArti AS (
  SELECT LsPo.KdArtiID, SUM(LsPo.Menge) AS Liefermenge
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  WHERE LsKo.Datum >= @from
    AND LsKo.Datum <= @to
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
INTO #Final
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

SELECT FORMAT(@from, N'yyyy-MM') AS Monat,
  #Final.*,
  ROUND(CAST(#Final.[Austausch absolut] AS float) / CAST(IIF(#Final.Umlaufmenge = 0, 1, #Final.Umlaufmenge) AS float) * CAST(100 AS float), 1) AS [Austausch relativ zu Umlauf in Prozent],
  #Final.Umlaufmenge / 208 AS [Wöchentlicher Austausch SOLL],
  #Final.[Austausch absolut] / 4.33 AS [Wöchentlicher Austausch IST],
  ROUND(CAST((#Final.Umlaufmenge / 208) - (#Final.[Austausch absolut] / 4.33) AS float) / CAST(IIF(#Final.[Austausch absolut] / 4.33 = 0, 1, #Final.[Austausch absolut] / 4.33) AS float) * CAST(100 AS float), 1) AS [Abweichung in Prozent],
  #Final.Umlaufmenge / IIF(#Final.[Austausch absolut] = 0, 1, #Final.[Austausch absolut]) AS [Reichweite in Monaten]
FROM #Final
ORDER BY [Austausch absolut] DESC;