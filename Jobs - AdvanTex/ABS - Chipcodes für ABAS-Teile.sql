-- Variablen definieren
DECLARE @Rentomat TABLE (
  RentomatID int
);

DECLARE @AbsResult TABLE (
  Barcode nchar(33) COLLATE Latin1_General_CS_AS,
  Chipcode nchar(33) COLLATE Latin1_General_CS_AS
);

DECLARE @total int,
  @current int = 0,
  @barcodes nvarchar(max),
  @abssql nvarchar(max),
  @deletesql nvarchar(max);

-- Bekleidungsautomaten, für die der Abgleich mit ABS durchgeführt wird
INSERT INTO @Rentomat VALUES (64), (65), (66), (70), (71), (72), (73), (74), (75), (82), (83), (84), (85);

IF OBJECT_ID('tempdb..#ABASTeile') IS NOT NULL
  TRUNCATE TABLE #ABASTeile;
ELSE
  CREATE TABLE #ABASTeile (
    TeileID int,
    Barcode nvarchar(33) COLLATE Latin1_General_CS_AS
  );

-- Für diese Teile muss der Chipcode aus ABS geholt werden
INSERT INTO #ABASTeile (TeileID, Barcode)
SELECT Teile.ID, Teile.Barcode
FROM Teile
JOIN Vsa ON Teile.VsaID = Vsa.ID
WHERE Vsa.RentomatID IN (
    SELECT RentomatID
    FROM @Rentomat
  )
  AND Teile.RentomatChip IS NULL
  AND Teile.Status BETWEEN N'L' AND N'W';

SET @Total = @@ROWCOUNT;  -- Wieviele Teile müssens insgesamt aktualisiert werden

WHILE @current < @total
BEGIN
  DELETE FROM @AbsResult; -- Tabelle leeren

  -- 100 Barcodes als Text für Abfrage über ABS Linked Server vorbereiten
  SET @barcodes = (
    SELECT STUFF((
      SELECT TOP (100) N', ''''' + Barcode + ''''''
      FROM #ABASTeile
      FOR XML PATH ('')
    ), 1, 2, N'')
  );

  SET @abssql = N'SELECT * FROM OPENQUERY(ABS, N''SELECT ui.primaryid, sec.secondaryid FROM uniqueitem ui, secondaryuniqueitem sec WHERE ui.uniqueitem_id = sec.uniqueitem_id AND ui.primaryid IN (' + @barcodes + ')'');';
  SET @deletesql = N'DELETE FROM #ABASTeile WHERE Barcode IN (' + REPLACE(@barcodes, N'''''', N'''') + ')';

  -- Daten aus ABS in Tabelle speichern
  INSERT INTO @AbsResult (Barcode, Chipcode)
  EXEC (@abssql);

  -- Teile mit Chipcode aus ABS aktualisieren
  UPDATE Teile SET RentomatChip = ResultTable.Chipcode
  FROM @AbsResult AS ResultTable
  JOIN Teile ON ResultTable.Barcode = Teile.Barcode;

  -- Verarbeitete Teile aus Tabelle löschen, damit sie nicht nochmal verarbeitet werden
  EXEC (@deletesql);

  -- Pro Schleifendurchlauf werden 100 Teile verarbeitet, daher +100
  SET @current = @current + 100;
END;