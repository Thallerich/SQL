DECLARE @ImportFile nvarchar(200) = N'\\atenadvantex01\AdvanTex\Temp\SALKPE.xlsx';  -- Pfad zum Excel-File mit den Teile-Daten. Muss für den SQL-Server-Prozess zugreifbar sein, daher am Besten unter \\atenadvantex01\advantex\temp\ ablegen.
DECLARE @XLSXImportSQL nvarchar(max);

DECLARE @ImportTable TABLE (
  KdNr int,
  ArtikelNr nchar(15) COLLATE Latin1_General_CS_AS,
  Variante nchar(2) COLLATE Latin1_General_CS_AS,
  LeasingNeu money,
  WaschenNeu money
);

SET @XLSXImportSQL = N'SELECT CAST(KDNR as int) AS KdNr, ' +
  N'CAST(ArtikelNr as nchar(15)), ' +
  N'CAST(Variante as nchar(2)), ' +
  N'ROUND(CAST(LeasingNeu as money), 3), ' +
  N'ROUND(CAST(WaschenNeu as money), 3) ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [gesamt$]);';

INSERT INTO @ImportTable
EXEC sp_executesql @XLSXImportSQL;

DECLARE @PreisChanged TABLE (
  ID int,
  LeasingPreis money,
  WaschPreis money,
  SonderPreis money,
  PeriodenPreis money,
  VKPreis money,
  BasisRestwert money
);

DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE MitarbeiUser = N'THALST');

--SELECT Kunden.KdNr, Artikel.ArtikelNr, Artikel.ArtikelBez, KdArti.Variante, KdArti.LeasingPreis, KdArti.WaschPreis, SALKPE.LeasingNeu, SALKPE.WaschenNeu
UPDATE KdArti SET LeasingPreis = SALKPE.LeasingNeu, WaschPreis = SALKPE.WaschenNeu
OUTPUT inserted.ID, inserted.LeasingPreis, inserted.WaschPreis, inserted.SonderPreis, inserted.PeriodenPreis, inserted.VkPreis, inserted.BasisRestwert
INTO @PreisChanged
FROM KdArti
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN @ImportTable AS SALKPE ON SALKPE.KdNr = Kunden.KdNr AND SALKPE.ArtikelNr = Artikel.ArtikelNr AND SALKPE.Variante = KdArti.Variante
WHERE (SALKPE.LeasingNeu != KdArti.LeasingPreis OR SALKPE.WaschenNeu != KdArti.WaschPreis);

INSERT INTO PrArchiv (KdArtiID, Datum, LeasingPreis, WaschPreis, SonderPreis, PeriodenPreis, VKPreis, BasisRestwert, MitarbeiID, Aktivierungszeitpunkt, Anlage_, Update_, AnlageUserID_, UserID_)
SELECT ID AS KdArtiID, N'2020-02-01' AS Datum, LeasingPreis, WaschPreis, SonderPreis, PeriodenPreis, VKPreis, BasisRestwert, @UserID AS MitarbeiID, GETDATE() AS Aktivierungszeitpunkt, GETDATE() AS Anlage_, GETDATE() AS Update_, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM @PreisChanged;