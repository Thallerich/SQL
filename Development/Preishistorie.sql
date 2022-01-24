DECLARE @fromDate date = N'2019-01-01';
DECLARE @toDate date = N'2021-12-13';

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

/* DROP TABLE #Preishistory; */

IF OBJECT_ID('tempdb..#Preishistory') IS NULL
  CREATE TABLE #Preishistory (
    ArtikelNr nchar(15),
    Artikelbezeichnung nvarchar(60),
    Variante nchar(2),
    Variantenbezeichnung nvarchar(60),
    Jahr smallint,
    Bearbeitungspreis money,
    PivotColNameBearb nchar(20),
    Leasingpreis money,
    PivotColNameLeas nchar(20)
  );
ELSE
  TRUNCATE TABLE #Preishistory;

WITH Preishistory AS (
  SELECT DISTINCT PrArchiv.KdArtiID,
    YEAR(PrArchiv.Datum) AS Jahr,
    Bearbeitung = LAST_VALUE(PrArchiv.WaschPreis) OVER (PARTITION BY PrArchiv.KdArtiID, YEAR(PrArchiv.Datum) ORDER BY PrArchiv.Datum RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING),
    Leasing = LAST_VALUE(PrArchiv.LeasPreis) OVER (PARTITION BY PrArchiv.KdArtiID, Year(PrArchiv.Datum) ORDER BY PrArchiv.Datum RANGE BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING),
    Sequenz = DENSE_RANK() OVER (PARTITION BY PrArchiv.KdArtiID ORDER BY YEAR(PrArchiv.Datum))
  FROM PrArchiv
)
INSERT INTO #Preishistory (ArtikelNr, Artikelbezeichnung, Variante, Variantenbezeichnung, Jahr, Bearbeitungspreis, PivotColNameBearb, Leasingpreis, PivotColNameLeas)
SELECT DISTINCT Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, KdArti.Variante, KdArti.VariantBez AS Variantenbezeichnung, Jahre.Jahr, Preishistory_Jahr.Bearbeitung, N'Bearbeitung ' + CAST(Jahre.Jahr AS nchar(4)) AS PivotColNameBearb, Preishistory_Jahr.Leasing, N'Leasing ' + CAST(Jahre.Jahr AS nchar(4)) AS PivotColNameLeas
FROM @Years AS Jahre
JOIN (
  SELECT Preishistory.KdArtiID, Preishistory.Bearbeitung, Preishistory.Leasing, Preishistory.Jahr AS vonJahr, ISNULL(PreisHistory_Next.Jahr, @endYear) AS bisJahr
  FROM Preishistory
  LEFT JOIN Preishistory AS PreisHistory_Next ON PreisHistory_Next.KdArtiID = Preishistory.KdArtiID AND Preishistory.Sequenz = PreisHistory_Next.Sequenz - 1
) AS Preishistory_Jahr ON Jahre.Jahr >= Preishistory_Jahr.vonJahr AND Jahre.Jahr < Preishistory_Jahr.bisJahr
JOIN KdArti ON Preishistory_Jahr.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
WHERE Holding.Holding = N'GESPAG'
  AND KdArti.ArtikelID > 0
  AND Jahre.Jahr BETWEEN YEAR(@fromDate) AND YEAR(@toDate)
  AND EXISTS (
    SELECT LsPo.*
    FROM LsPo
    JOIN LsKo ON LsPo.LsKoID = LsKo.ID
    WHERE LsPo.KdArtiID = KdArti.ID
      AND LsPo.Menge > 0
      AND LsKo.Datum BETWEEN @fromDate AND @toDate
  )
  AND (Preishistory_Jahr.Bearbeitung != 0 OR Preishistory_Jahr.Leasing != 0);

DECLARE @pivotcolsall nvarchar(max);
DECLARE @pivotcolsbearb nvarchar(max);
DECLARE @pivotcolsleas nvarchar(max);
DECLARE @pivotsql nvarchar(max);

SET @pivotcolsall = STUFF((SELECT DISTINCT ', [Bearbeitung ' + CAST(Jahr AS nchar(4)) + '], [Leasing ' + CAST(Jahr AS nchar(4)) + ']' FROM #Preishistory ORDER BY 1 FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,1,'');
SET @pivotcolsbearb = STUFF((SELECT DISTINCT ', [Bearbeitung ' + CAST(Jahr AS nchar(4)) + ']' FROM #Preishistory ORDER BY 1 FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,1,'');
SET @pivotcolsleas = STUFF((SELECT DISTINCT ', [Leasing ' + CAST(Jahr AS nchar(4)) + ']' FROM #Preishistory ORDER BY 1 FOR XML PATH(''), TYPE).value('.', 'NVARCHAR(MAX)'),1,1,'');

SET @pivotsql = N'SELECT ArtikelNr, Artikelbezeichnung, Variante, Variantenbezeichnung, ' + @pivotcolsall + 
  ' FROM #Preishistory AS Pivotdata ' +
  ' PIVOT (MAX(Bearbeitungspreis) FOR PivotColNameBearb IN (' + @pivotcolsbearb + ')) AS b ' +
  ' PIVOT (MAX(Leasingpreis) FOR PivotColNameLeas IN (' + @pivotcolsleas + ')) AS l;';

EXEC sp_executesql @pivotsql;