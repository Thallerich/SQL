DECLARE @ImportFile nvarchar(200) = N'\\atenadvantex01.wozabal.int\AdvanTex\Temp\Signale.xlsx';  -- Pfad zum Excel-File mit den Teile-Daten. Muss für den SQL-Server-Prozess zugreifbar sein, daher am Besten unter \\atenadvantex01\advantex\temp\ ablegen.
DECLARE @XLSXImportSQL nvarchar(max);

DECLARE @ImportTable TABLE (
  Barcode nvarchar(33) COLLATE Latin1_General_CS_AS,
  Signalcode int,
  Signalbez nvarchar(100) COLLATE Latin1_General_CS_AS,
  Signaltext nvarchar(max) COLLATE Latin1_General_CS_AS,
  Signalstartdatum datetime
);

SET @XLSXImportSQL = N'SELECT CAST(BC as nvarchar(33)) AS Barcode, ' +
  N'CAST(Signalcode AS int) AS Signalcode, ' +
  N'CAST(Signalbez AS nvarchar(100)) AS Signalbez, ' +
  N'CAST(Signaltext AS nvarchar(max)) AS Signaltext, ' +
  N'CAST(Signalstartdatum AS datetime) AS Signalstartdatum ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [Signale$]);';

INSERT INTO @ImportTable
EXEC sp_executesql @XLSXImportSQL;

--SELECT * FROM @ImportTable ORDER BY Signalcode ASC;

-- Signalcode 101, 105 -> Auf Rückgabe stellen

UPDATE Teile SET Teile.Status = N'W' WHERE Teile.Barcode IN (
  SELECT Barcode FROM @ImportTable WHERE Signalcode IN (101, 105)
);

-- Signalcode 107 -> Auf Einzug stellen

UPDATE Teile SET Teile.Status = N'U' WHERE Teile.Barcode IN (
  SELECT Barcode FROM @ImportTable WHERE Signalcode = 107
);

-- Alle anderen Codes -> Hinweistext anlegen

INSERT INTO Hinweis (TeileID, Aktiv, Hinweis, BisWoche, Anzahl, EingabeDatum, EingabeMitarbeiID)
SELECT Teile.ID AS TeileID, 1 AS Aktiv, N'<o> ' + RTRIM(IIF(i.Signaltext = N'', i.Signalbez, i.Signaltext)) AS Hinweis, N'2099-52' AS BisWoche, 1 AS Anzahl, i.Signalstartdatum AS Eingabedatum, (SELECT Mitarbei.ID FROM Mitarbei WHERE Mitarbei.UserName = N'THALST') AS EingabeMitarbeiID
FROM @ImportTable AS i
JOIN Teile ON i.Barcode = Teile.Barcode
WHERE i.Signalcode NOT IN (101, 105, 107);