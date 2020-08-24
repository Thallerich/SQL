DECLARE @ImportFile nvarchar(200) = N'\\ATENADVANTEX01.wozabal.int\AdvanTex\Temp\fahrzeug.xlsx';
DECLARE @XLSXImportSQL nvarchar(max);

DECLARE @ImportTable TABLE (
  Standort nchar(4) COLLATE Latin1_General_CS_AS,
  Fahrzeugtyp nvarchar(50) COLLATE Latin1_General_CS_AS,
  FahrgestellNr nvarchar(20) COLLATE Latin1_General_CS_AS,
  Kennzeichen nvarchar(20) COLLATE Latin1_General_CS_AS,
  Fahrer nvarchar(100) COLLATE Latin1_General_CS_AS
);

SET @XLSXImportSQL = N'SELECT CAST(Standort AS nchar(4)), CAST(Fahrzeugtyp AS nvarchar(50)), CAST(FahrgestellNr AS nvarchar), CAST(Kennzeichen AS nvarchar), CAST(Fahrer AS nvarchar) ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [sheet1$]);';

INSERT INTO @ImportTable
EXEC sp_executesql @XLSXImportSQL;

UPDATE @ImportTable SET Kennzeichen = REPLACE(LTRIM(Kennzeichen), N' ', N'-');
UPDATE @ImportTable SET Standort = N'BUKA' WHERE Standort = N'SMRO';

INSERT INTO Fahrzeug ([Status], FzNr, Kennzeichen, Typ, SichtbarID, StandortID, SuchCode, FahrgestellNr)
SELECT N'A' AS [Status],
  IIF(IT.Standort = N'BUKA', 600, 700) + ROW_NUMBER() OVER (PARTITION BY IT.Standort ORDER BY IT.Kennzeichen) AS FzNr,
  IT.Kennzeichen,
  IT.Fahrzeugtyp AS Typ,
  Standort.SichtbarID,
  Standort.ID AS StandortID,
  IT.Kennzeichen AS SuchCode,
  IT.FahrgestellNr
FROM @ImportTable AS IT
JOIN Standort ON IT.Standort = Standort.SuchCode;