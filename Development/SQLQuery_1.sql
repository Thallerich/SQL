DROP TABLE IF EXISTS #WorkTable;
DROP TABLE IF EXISTS #ResultSet;

CREATE TABLE #WorkTable (
  Jahr smallint,
  Monat tinyint,
  LetzterSonntag date
);

DECLARE
  @basedate date,
  @maxdate date,
  @lastdate date,
  @offset int,
  @maxmonths int;

SET @basedate = DATEADD(day, 1, EOMONTH(DATEADD(month, -37, GETDATE())));
SET @maxdate = EOMONTH(GETDATE());
SET @lastdate = @basedate;
SET @offset = 1;
SET @maxmonths = DATEDIFF(month, @basedate, @maxdate);

INSERT INTO #WorkTable (Jahr, Monat, LetzterSonntag)
VALUES (DATEPART(year, @basedate), DATEPART(month, @basedate), DATEADD(week, -1, DATEADD(day, ((15 - @@DATEFIRST) - DATEPART(weekday, @basedate)) % 7, @basedate))); /* Letzter Sonntag */

WHILE (@offset <= @maxmonths)
BEGIN
  SET @lastdate = DATEADD(month, 1, @lastdate);

  INSERT INTO #WorkTable (Jahr, Monat, LetzterSonntag)
  VALUES (DATEPART(year, @lastdate), DATEPART(month, @lastdate), DATEADD(dd, -1 * (DATEPART(dw, DATEADD(day, -1, DATEADD(month, DATEDIFF(month, 0, @lastdate) + 1, 0))) - 1), DATEADD(day, -1, DATEADD(month, DATEDIFF(month, 0, @lastdate) + 1, 0)))); /* Letzter Sonntag des Monats */

  SET @offset = @offset + 1;
END;

SELECT #WorkTable.Jahr, #WorkTable.Monat, #WorkTable.LetzterSonntag, KdArti.ID AS KdArtiID, KdArti.KundenID, KdArti.ArtikelID, KdArti.Variante, CAST(0 AS bigint) AS Umlaufmenge, CAST(0 AS float) AS Liefermenge, CAST(0 AS money) AS Umsatz, CAST(0 AS int) AS Einsatzmenge
INTO #ResultSet
FROM KdArti
CROSS JOIN #WorkTable;

WITH Umlauf AS (
  SELECT _Umlauf.Datum, _Umlauf.KdArtiID, SUM(_Umlauf.Umlauf) AS Umlaufmenge
  FROM _Umlauf
  WHERE _Umlauf.Datum IN (
    SELECT #WorkTable.LetzterSonntag
    FROM #WorkTable
  )
),
Liefermenge AS (
  SELECT FORMAT(LsKo.Datum, N'yyyy-MM') AS Monat, LsPo.KdArtiID, SUM(LsPo.Menge) AS Liefermenge
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  WHERE LsKo.Datum BETWEEN DATEADD(day, 1, EOMONTH(DATEADD(month, -37, GETDATE()))) AND EOMONTH(GETDATE()) /* Monatserster vor 36 Monaten von heute aus  -  Monatsletzer aktueller Monat */
  GROUP BY FORMAT(LsKo.Datum, N'yyyy-MM'), LsPo.KdArtiID
),
Umsatz AS (
  SELECT FORMAT(RechKo.RechDat, N'yyyy-MM') AS Monat, RechPo.KdArtiID, SUM(RechPo.GPreis) AS Umsatz
  FROM RechPo
  JOIN RechKo ON RechPo.RechKoID = RechKo.ID
  WHERE RechKo.RechDat BETWEEN DATEADD(day, 1, EOMONTH(DATEADD(month, -37, GETDATE()))) AND EOMONTH(GETDATE()) /* Monatserster vor 36 Monaten von heute aus  -  Monatsletzer aktueller Monat */
  GROUP BY FORMAT(RechKo.RechDat, N'yyyy-MM'), RechPo.KdArtiID
),
Textileinsatz AS (
  SELECT FORMAT(EinzHist.IndienstDat, N'yyyy-MM') AS Monat, EinzHist.KdArtiID, COUNT(EinzHist.ID) AS Einsatzmenge
  FROM EinzHist
  WHERE Einzhist.Entnommen = 1
    AND Einzhist.PoolFkt = 0
    AND Einzhist.EinzHistTyp = 1
    AND Einzhist.IndienstDat BETWEEN DATEADD(day, 1, EOMONTH(DATEADD(month, -37, GETDATE()))) AND EOMONTH(GETDATE()) /* Monatserster vor 36 Monaten von heute aus  -  Monatsletzer aktueller Monat */
  GROUP BY FORMAT(EinzHist.IndienstDat, N'yyyy-MM'), EinzHist.KdArtiID
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Kunden.Name1 AS [Adresszeile 1], Holding.Holding, [Zone].ZonenBez AS Vertriebszone, ArtGru.Gruppe AS Artikelgruppe, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, [#ResultSet].Variante, Artikel.StueckGewicht AS [Gewicht pro Stück], [#ResultSet].Umlaufmenge, [#ResultSet].Liefermenge, [#ResultSet].Umsatz, [#ResultSet].Einsatzmenge
FROM #ResultSet
JOIN Kunden ON [#ResultSet].KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN Artikel ON [#ResultSet].ArtikelID = Artikel.ID
JOIN ArtGru ON Artikel.ArtGruID = ArtGru.ID
WHERE (ISNULL([#ResultSet].Umlaufmenge, 0) != 0 OR ISNULL([#ResultSet].Liefermenge, 0) != 0 OR ISNULL([#ResultSet].Umsatz, 0) != 0 OR ISNULL([#ResultSet].Einsatzmenge, 0) != 0);