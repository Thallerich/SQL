DECLARE @ImportFile nvarchar(200) = N'\\atenadvantex01\AdvanTex\Temp\2018-09-14_Signale_31145_31164_31172.xlsx';
DECLARE @XLSXImportSQLTeil nvarchar(max);
DECLARE @XLSXImportSQLTraeger nvarchar(max);

DECLARE @SignalTeil TABLE (
  KdNr int,
  Barcode nvarchar(33) COLLATE Latin1_General_CS_AS,
  Signalbezeichnung nvarchar(128) COLLATE Latin1_General_CS_AS,
  Signaltext nvarchar(128) COLLATE Latin1_General_CS_AS
);

DECLARE @SignalTraeger TABLE (
  KdNr int,
  TraegerNr int,
  Vorname nvarchar(20) COLLATE Latin1_General_CS_AS,
  Nachname nvarchar(25) COLLATE Latin1_General_CS_AS,
  ArtikelNr nvarchar(15) COLLATE Latin1_General_CS_AS,
  ArtikelBez nvarchar(60) COLLATE Latin1_General_CS_AS,
  Groesse nvarchar(10) COLLATE Latin1_General_CS_AS,
  Signalcode int,
  Signalbezeichnung nvarchar(128) COLLATE Latin1_General_CS_AS,
  Barcode nvarchar(33) COLLATE Latin1_General_CS_AS
);

SET @XLSXImportSQLTeil = N'SELECT CAST(KDNR as int) AS KdNr, ' +
  N'CAST(BC AS nvarchar(33)) AS Barcode, ' +
  N'CAST(Signalbez AS nvarchar(128)) AS Signalbezeichnung, ' +
  N'CAST(Signaltext AS nvarchar(128)) AS Signaltext ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [SignalTeil$]);';

SET @XLSXImportSQLTraeger = N'SELECT CAST(KDNR as int) AS KdNr, ' +
  N'CAST(Trägernr AS int) AS TraegerNr, ' + 
  N'CAST(Vorname AS nvarchar(20)) AS Vorname, ' +
  N'CAST(Nachname AS nvarchar(25)) AS Nachname, ' +
  N'CAST(Produkt AS nvarchar(15)) AS ArtikelNr, ' +
  N'CAST(Produktbez AS nvarchar(60)) AS ArtikelBez, ' +
  N'CAST(Größe AS nvarchar(10)) AS Groesse, ' +
  N'CAST(Signalcode AS int) AS Signalcode, ' +
  N'CAST(Signalbez AS nvarchar(128)) AS Signalbezeichnung, ' +
  N'CAST(BC AS nvarchar(33)) AS Barcode ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [SignalTraeger$]);';

INSERT INTO @SignalTeil
EXEC sp_executesql @XLSXImportSQLTeil;

INSERT INTO @SignalTraeger
EXEC sp_executesql @XLSXImportSQLTraeger;

SELECT * FROM @SignalTeil;
SELECT * FROM @SignalTraeger;