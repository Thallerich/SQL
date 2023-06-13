/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: prepHistory                                                                                                     ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan THALLER - 2022-01-25                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @fromDate date = $STARTDATE$;
DECLARE @toDate date = $ENDDATE$;

DECLARE @Years TABLE (
  Jahr int
);

DECLARE @startYear smallint = YEAR(@fromDate);
DECLARE @endYear smallint = YEAR(@toDate);

WHILE @startYear <= @endYear
BEGIN
  INSERT INTO @Years
  VALUES (@startYear);

  SET @startYear = @startYear + 1;
END;

IF OBJECT_ID('tempdb..#Preishistory') IS NULL
  CREATE TABLE #Preishistory (
    ArtikelNr nchar(15),
    Artikelbezeichnung nvarchar(60),
    Kundenbereich nvarchar(60),
    Variante nchar(2),
    Variantenbezeichnung nvarchar(60),
    Preis money,
    Preistyp nchar(5)
  );
ELSE
  TRUNCATE TABLE #Preishistory;

WITH Preishistory AS (
  SELECT DISTINCT PrArchiv.KdArtiID,
    YEAR(PrArchiv.Datum) AS Jahr,
    Bearbeitung = LAST_VALUE(PrArchiv.WaschPreis) OVER (PARTITION BY PrArchiv.KdArtiID, YEAR(PrArchiv.Datum) ORDER BY PrArchiv.Datum RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING),
    Sequenz = DENSE_RANK() OVER (PARTITION BY PrArchiv.KdArtiID ORDER BY YEAR(PrArchiv.Datum))
  FROM PrArchiv
)
INSERT INTO #Preishistory (ArtikelNr, Artikelbezeichnung, Kundenbereich, Variante, Variantenbezeichnung, Preis, Preistyp)
SELECT DISTINCT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Bereich.BereichBez$LAN$ AS Kundenbereich, KdArti.Variante, KdArti.VariantBez AS Variantenbezeichnung, Preishistory_Jahr.Bearbeitung AS Preis, N'B' + CAST(Jahre.Jahr AS nchar(4)) AS Preistyp
FROM @Years AS Jahre
JOIN (
  SELECT Preishistory.KdArtiID, Preishistory.Bearbeitung, Preishistory.Jahr AS vonJahr, ISNULL(PreisHistory_Next.Jahr, @endYear + 1) AS bisJahr
  FROM Preishistory
  LEFT JOIN Preishistory AS PreisHistory_Next ON PreisHistory_Next.KdArtiID = Preishistory.KdArtiID AND Preishistory.Sequenz = PreisHistory_Next.Sequenz - 1
) AS Preishistory_Jahr ON Jahre.Jahr >= Preishistory_Jahr.vonJahr AND Jahre.Jahr < Preishistory_Jahr.bisJahr
JOIN KdArti ON Preishistory_Jahr.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
WHERE Kunden.ID IN ($3$)
  AND KdArti.ArtikelID > 0
  AND Jahre.Jahr BETWEEN YEAR(@fromDate) AND YEAR(@toDate)
  AND EXISTS (
    SELECT LsPo.*
    FROM LsPo
    JOIN LsKo ON LsPo.LsKoID = LsKo.ID
    WHERE LsPo.KdArtiID = KdArti.ID
      AND LsPo.Menge > 0
      AND LsKo.Datum BETWEEN @fromDate AND @toDate
  );

WITH Preishistory AS (
  SELECT DISTINCT PrArchiv.KdArtiID,
    YEAR(PrArchiv.Datum) AS Jahr,
    Leasing = LAST_VALUE(PrArchiv.LeasPreis) OVER (PARTITION BY PrArchiv.KdArtiID, YEAR(PrArchiv.Datum) ORDER BY PrArchiv.Datum RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING),
    Sequenz = DENSE_RANK() OVER (PARTITION BY PrArchiv.KdArtiID ORDER BY YEAR(PrArchiv.Datum))
  FROM PrArchiv
)
INSERT INTO #Preishistory (ArtikelNr, Artikelbezeichnung, Kundenbereich, Variante, Variantenbezeichnung, Preis, Preistyp)
SELECT DISTINCT Artikel.ArtikelNr, Artikel.ArtikelBez$LAN$ AS Artikelbezeichnung, Bereich.BereichBez$LAN$ AS Kundenbereich, KdArti.Variante, KdArti.VariantBez AS Variantenbezeichnung, Preishistory_Jahr.Leasing AS Preis, N'L' + CAST(Jahre.Jahr AS nchar(4)) AS Preistyp
FROM @Years AS Jahre
JOIN (
  SELECT Preishistory.KdArtiID, Preishistory.Leasing, Preishistory.Jahr AS vonJahr, ISNULL(PreisHistory_Next.Jahr, @endYear + 1) AS bisJahr
  FROM Preishistory
  LEFT JOIN Preishistory AS PreisHistory_Next ON PreisHistory_Next.KdArtiID = Preishistory.KdArtiID AND Preishistory.Sequenz = PreisHistory_Next.Sequenz - 1
) AS Preishistory_Jahr ON Jahre.Jahr >= Preishistory_Jahr.vonJahr AND Jahre.Jahr < Preishistory_Jahr.bisJahr
JOIN KdArti ON Preishistory_Jahr.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdBer ON KdArti.KdBerID = KdBer.ID
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
WHERE Kunden.ID IN ($3$)
  AND KdArti.ArtikelID > 0
  AND Jahre.Jahr BETWEEN YEAR(@fromDate) AND YEAR(@toDate)
  AND EXISTS (
    SELECT LsPo.*
    FROM LsPo
    JOIN LsKo ON LsPo.LsKoID = LsKo.ID
    WHERE LsPo.KdArtiID = KdArti.ID
      AND LsPo.Menge > 0
      AND LsKo.Datum BETWEEN @fromDate AND @toDate
  );

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Pipeline: Preishistory                                                                                                    ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan THALLER - 2022-01-25                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @pivotcols nvarchar(max);
DECLARE @pivotcolshead nvarchar(max);
DECLARE @pivotsql nvarchar(max);

SET @pivotcols = STUFF((SELECT DISTINCT ', [' + Preistyp + ']' FROM #Preishistory ORDER BY 1 FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,1,'');
SET @pivotcolshead = STUFF((SELECT DISTINCT ', [' + Preistyp + '] AS [' + REPLACE(REPLACE(Preistyp, N'B', N'Bearbeitung '), N'L', N'Leasing ') + ']' FROM #Preishistory ORDER BY 1 FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,1,'');

SET @pivotsql = N'SELECT ArtikelNr, Artikelbezeichnung, Kundenbereich, Variante, Variantenbezeichnung, ' + @pivotcolshead + 
  ' FROM #Preishistory AS Pivotdata ' +
  ' PIVOT (MAX(Preis) FOR Preistyp IN (' + @pivotcols + ')) AS b;';

EXEC sp_executesql @pivotsql;