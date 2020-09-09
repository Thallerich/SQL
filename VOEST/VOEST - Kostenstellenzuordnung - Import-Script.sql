DECLARE @CustomerNumber int = 272295;

DECLARE @ImportFile nvarchar(200) = N'\\ATENADVANTEX01.wozabal.int\AdvanTex\Temp\Kostenstellenzuordnung.xlsx';
DECLARE @XLSXImportSQL nvarchar(max);

DECLARE @ImportTable TABLE (
  Kostenstelle nchar(15) COLLATE Latin1_General_CS_AS,
  Kostenstellenbezeichnung nvarchar(100) COLLATE Latin1_General_CS_AS,
  GebäudeNr nchar(5) COLLATE Latin1_General_CS_AS
);

SET @XLSXImportSQL = N'SELECT * ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [Tabelle1$]);';

INSERT INTO @ImportTable
EXEC sp_executesql @XLSXImportSQL;

/*SELECT Vsa.ID AS VsaID, Vsa.VsaNr, Vsa.SuchCode, Vsa.Bez AS VsaBez, Abteil.Abteilung, Abteil.Bez AS AbteilBez, Vsa.GebaeudeNr, Vsa.GebaeudeBez, ImportTable.GebäudeNr AS GebaeudeNr_Import
INTO __VOEST_Backup_Kostenstellenzuordnung*/
UPDATE Vsa SET Vsa.GebaeudeBez = ImportTable.GebäudeNr
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN Abteil ON Vsa.AbteilID = Abteil.ID
JOIN @ImportTable AS ImportTable ON Abteil.Bez = ImportTable.Kostenstelle
WHERE Kunden.KdNr = @CustomerNumber;