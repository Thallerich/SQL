DECLARE @ImportFile nvarchar(200) = N'\\atenadvantex01\AdvanTex\Temp\Feiertage.xlsx';  -- Pfad zum Excel-File mit den Teile-Daten. Muss für den SQL-Server-Prozess zugreifbar sein, daher am Besten unter \\atenadvantex01\advantex\temp\ ablegen.
DECLARE @XLSXImportSQL nvarchar(max);

DECLARE @ImportTable TABLE (
  Feiertag nvarchar(50) COLLATE Latin1_General_CS_AS,
  Land nvarchar(40) COLLATE Latin1_General_CS_AS,
  Datum date
);

SET @XLSXImportSQL = N'SELECT CAST(Feiertag AS nvarchar(50)), ' +
  N'CAST(Land AS nvarchar(40)), ' +
  N'CAST(Datum AS date) ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [Feiertage$]);';

INSERT INTO @ImportTable
EXEC sp_executesql @XLSXImportSQL;

UPDATE Feiertag SET LandID = 58
WHERE ID > 0
  AND Datum NOT IN (SELECT DISTINCT Datum FROM @ImportTable)
  AND DATEPART(year, Datum) >= (SELECT MIN(DATEPART(year, Datum)) FROM @ImportTable)
  AND DATEPART(year, Datum) <= (SELECT MAX(DATEPART(year, Datum)) FROM @ImportTable);

INSERT INTO Feiertag (Datum, FeiertagBez, FeiertagBez1, FeiertagBez2, FeiertagBez3, FeiertagBez4, FeiertagBez5, Bundesweit, SepaFeiertag, LandID)
SELECT import.Datum, import.Feiertag AS FeiertagBez, import.Feiertag AS FeiertagBez1, import.Feiertag AS FeiertagBez2, import.Feiertag AS FeiertagBez3, import.Feiertag AS FeiertagBez4, import.Feiertag AS FeiertagBez5, 1 AS Bundesweit, 0 AS SepaFeiertag, Land.ID AS LandID
FROM @ImportTable AS import
JOIN Land ON import.Land = Land.LandBez
WHERE NOT EXISTS (
  SELECT x.*
  FROM Feiertag AS x
  WHERE x.Datum = import.Datum
    AND x.LandID IN (-1, Land.ID)
);