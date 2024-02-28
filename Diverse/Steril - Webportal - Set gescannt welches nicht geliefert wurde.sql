DECLARE @pattern nvarchar(100) = N'%: Laut Status ist dieses OP-Set niemals zum Kunden ausgeliefert worden!%';
DECLARE @input nvarchar(max), @timestamp datetime2;

DROP TABLE IF EXISTS #Result;

CREATE TABLE #Result (
  Zeitpunkt datetime2,
  SetListe nvarchar(max)
);

DECLARE SetNotAtCustomer CURSOR FOR
SELECT LogItem.Memo, LogItem.Anlage_
FROM LogItem
WHERE LogItem.LogCaseID = 372
  AND LogItem.Memo LIKE N'%: Laut Status ist dieses OP-Set niemals zum Kunden ausgeliefert worden!%';

OPEN SetNotAtCustomer;

FETCH NEXT FROM SetNotAtCustomer INTO @input, @timestamp;

WHILE @@FETCH_STATUS = 0
BEGIN

  WITH Src AS (
    SELECT SUBSTRING(@input, PATINDEX(@pattern, @input) - 10, 10) Val,
           STUFF(@input, 1, PATINDEX(@pattern, @input) + 10, '') Txt
    WHERE PATINDEX(@pattern, @input) > 0
    
    UNION ALL

    SELECT SUBSTRING(Txt, PATINDEX(@pattern, Txt) - 10, 10),
           STUFF(Txt, 1, PATINDEX(@pattern, Txt) + 10, '')
    FROM Src
    WHERE PATINDEX(@pattern, Txt) > 0
  )
  INSERT INTO #Result (Zeitpunkt, SetListe)
  SELECT @timestamp, STUFF((SELECT ', '+Val FROM Src FOR XML PATH('')), 1, 2, '');

  FETCH NEXT FROM SetNotAtCustomer INTO @input, @timestamp;

END;

CLOSE SetNotAtCustomer;
DEALLOCATE SetNotAtCustomer;

SELECT * FROM #Result;