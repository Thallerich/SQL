DECLARE @Barcodes nvarchar(max) = (
  SELECT STUFF((
    SELECT N', ''''' + Teile.Barcode + ''''''
    FROM Teile
    JOIN Vsa ON Teile.VsaID = Vsa.ID
    WHERE Vsa.RentomatID IN (64, 65, 66)
      AND Teile.RentomatChip IS NULL
      AND Teile.Status BETWEEN N'L' AND N'W'
    FOR XML PATH ('')
  ), 1, 2, N'')
);

DECLARE @ABSSQL nvarchar(max) = N'SELECT * FROM OPENQUERY(ABS, N''SELECT ui.primaryid, sec.secondaryid FROM uniqueitem ui, secondaryuniqueitem sec WHERE ui.uniqueitem_id = sec.uniqueitem_id AND ui.primaryid IN (' + @Barcodes + ')'');';

DECLARE @ResultTable TABLE (
  Barcode nchar(33) COLLATE Latin1_General_CS_AS,
  Chipcode nchar(33) COLLATE Latin1_General_CS_AS
);

INSERT INTO @ResultTable
EXEC (@ABSSQL);

--SELECT Teile.ID AS TeileID, Teile.Barcode, Teile.RentomatChip, ResultTable.Chipcode
UPDATE Teile SET RentomatChip = ResultTable.Chipcode
FROM @ResultTable AS ResultTable
JOIN Teile ON ResultTable.Barcode = Teile.Barcode;