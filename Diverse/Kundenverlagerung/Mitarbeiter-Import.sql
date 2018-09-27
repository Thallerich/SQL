DECLARE @ImportFile nvarchar(200) = N'\\atenadvantex01\AdvanTex\Temp\SAL_AußendienstMA.xlsx';  -- Pfad zum Excel-File mit den Teile-Daten. Muss für den SQL-Server-Prozess zugreifbar sein, daher am Besten unter \\atenadvantex01\advantex\temp\ ablegen.
DECLARE @XLSXImportSQL nvarchar(max);

DECLARE @ImportTable TABLE (
  MaNr nvarchar(6) COLLATE Latin1_General_CS_AS,
  [Datum aktiv] date,
  Vorname nvarchar(30) COLLATE Latin1_General_CS_AS,
  Nachname nvarchar(40) COLLATE Latin1_General_CS_AS
);

SET @XLSXImportSQL = N'SELECT CAST([Mitarbeiternr#] AS nvarchar(6)) AS MaNr, ' +
  N'CONVERT(date, [Datum aktiv], 104) AS Eintritt, ' +
  N'CAST(Vorname AS nvarchar(30)) AS Vorname, ' +
  N'CAST(Nachname AS nvarchar(40)) AS Nachname ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [MA$]);';

INSERT INTO @ImportTable
EXEC sp_executesql @XLSXImportSQL;

INSERT INTO Mitarbei (SichtbarID, [Status], MaNr, [Name], Nachname, Vorname, Betreuer, Vertreter, EintrittAm, Barcode)
SELECT -2 AS SichtbarID, N'A' AS [Status], N'SM' + RIGHT(REPLICATE(N'0', 6) + ImportData.MaNr, 6) AS MaNr, ISNULL(ImportData.Nachname, N'') + N', ' + ISNULL(ImportData.Vorname, N'') AS [Name], ImportData.Nachname, ImportData.Vorname, 1 AS Betreuer, 1 AS Vertreter, ImportData.[Datum aktiv] AS EintrittAm, RIGHT(REPLICATE(N'0', 6) + ImportData.MaNr, 6) AS Barcode
FROM @ImportTable AS ImportData
WHERE NOT EXISTS (
  SELECT Mitarbei.*
  FROM Mitarbei
  WHERE Mitarbei.Nachname = ImportData.Nachname
    AND Mitarbei.Vorname = ImportData.Vorname
);

UPDATE Mitarbei SET Mitarbei.Betreuer = 1, Mitarbei.Vertreter = 1
FROM Mitarbei
WHERE Mitarbei.ID IN (
  SELECT Mitarbei.ID
  FROM Mitarbei
  JOIN @ImportTable AS ImportData ON ImportData.Nachname = Mitarbei.Nachname AND ImportData.Vorname = Mitarbei.Vorname
  WHERE Mitarbei.Betreuer = 0
    OR Mitarbei.Vertreter = 0
);