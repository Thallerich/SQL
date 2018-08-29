/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Import von Teilen zu Trägerartikeln                                                                                       ++ */
/* ++ für Kundenübernahmen von Salesianer Miettex                                                                               ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan Thaller - 2018-08-29                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @KdNr int = 10001002;  -- Kundennummer des Kunden im AdvanTex
DECLARE @ImportFile nvarchar(200) = N'\\atenadvantex01\AdvanTex\Temp\2018-08-29_10001002_St Anna Service.xlsx';  -- Pfad zum Excel-File mit den Teile-Daten. Muss für den SQL-Server-Prozess zugreifbar sein, daher am Besten unter \\atenadvantex01\advantex\temp\ ablegen.
DECLARE @XLSXImportSQL nvarchar(max);

DECLARE @ImportTable TABLE (
  KdNr int,
  Schrank nchar(1),
  Fach nchar(3),
  TraegerNr int,
  Vorname nvarchar(20) COLLATE Latin1_General_CS_AS,
  Nachname nvarchar(25) COLLATE Latin1_General_CS_AS,
  PersNr nvarchar(10) COLLATE Latin1_General_CS_AS,
  ArtikelNr nvarchar(15) COLLATE Latin1_General_CS_AS,
  ArtikelBez nvarchar(60) COLLATE Latin1_General_CS_AS,
  Groesse nvarchar(10) COLLATE Latin1_General_CS_AS,
  MaxBestand int,
  Barcode nvarchar(33) COLLATE Latin1_General_CS_AS,
  Verbleib nvarchar(100) COLLATE Latin1_General_CS_AS,
  Eingang1 date,
  Ausgang1 date,
  IndienstDat date,
  Qualitaet nchar(1) COLLATE Latin1_General_CS_AS,
  Waschzyklen int,
  AlterMonate int
);

SET @XLSXImportSQL = N'SELECT CAST(KDNR as int) AS KdNr, ' +
  N'CAST(Schrank AS nchar(1)) AS Schrank, ' +
  N'CAST(Fach AS nchar(3)) AS Fach, ' + 
  N'CAST(TRNR AS int) AS TraegerNr, ' + 
  N'CAST(Vorname AS nvarchar(20)) AS Vorname, ' +
  N'CAST(Nachname AS nvarchar(25)) AS Nachname, ' +
  N'CAST(AdminNr AS nvarchar(10)) AS PersNr, ' +
  N'CAST(Produkt AS nvarchar(15)) AS ArtikelNr, ' +
  N'CAST(Bezeichnung AS nvarchar(60)) AS ArtikelBez, ' +
  N'CAST(Größe AS nvarchar(10)) AS Groesse, ' +
  N'CAST(Maxbest AS int) AS MaxBestand, ' +
  N'CAST(Barcode AS nvarchar(33)) AS Barcode, ' +
  N'CAST(Verbleib AS nvarchar(100)) AS Verbleib, ' +
  N'CONVERT(date, [Letzte Einscannung], 104) AS Eingang1, ' +
  N'CONVERT(date, [Letzte Ausscannung], 104) AS Ausgang1, ' +
  N'CONVERT(date, [Letztes Einsatzdatu], 104) AS IndienstDat, ' +
  N'CAST(Qualität AS nchar(1)) AS Qualitaet, ' +
  N'CAST(Waschzyklen AS int) AS Waschzyklen, ' +
  N'CAST([Alter in Monate] AS int) AS AlterMonate ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [Teiledaten$]);';

INSERT INTO @ImportTable
EXEC sp_executesql @XLSXImportSQL;

INSERT INTO Teile (Barcode, [Status], VsaID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, Entnommen, EinsatzGrund, PatchDatum, Erstwoche, ErstDatum, Indienst, IndienstDat, RuecklaufG, Kostenlos, AlterInfo, AltenheimModus, AnlageUserID_, UserID_)
SELECT ImportTable.Barcode,
  N'Q' AS [Status],
  Vsa.ID AS VsaID,
  Traeger.ID AS TraegerID,
  TraeArti.ID AS TraeArtiID,
  TraeArti.KdArtiID, Artikel.ID AS ArtikelID,
  ArtGroe.ID AS ArtGroeID,
  CAST(1 AS bit) AS Entnommen,
  N'3' AS EinsatzGrund,
  CAST(GETDATE() AS date) AS PatchDatum,
  (SELECT Week.Woche FROM Week WHERE ISNULL(DATEADD(month, ImportTable.AlterMonate * -1, CAST(GETDATE() AS date)), N'1980-01-01') BETWEEN Week.VonDat AND Week.BisDat) AS ErstWoche,
  ISNULL(DATEADD(month, ImportTable.AlterMonate * -1, CAST(GETDATE() AS date)), N'1980-01-01') AS ErstDatum,
  (SELECT Week.Woche FROM Week WHERE ISNULL(ImportTable.IndienstDat, N'1980-01-01') BETWEEN Week.VonDat AND Week.BisDat) AS Indienst,
  ISNULL(ImportTable.IndienstDat, N'1980-01-01') AS IndienstDat,
  ImportTable.Waschzyklen AS RuecklaufG,
  CAST(0 AS bit) AS Kostenlos,
  DATEDIFF(week, ISNULL(DATEADD(month, ImportTable.AlterMonate * -1, CAST(GETDATE() AS date)), N'1980-01-01'), GETDATE()) AS AlterInfo,
  CAST(0 AS int) AS AltenheimModus,
  (SELECT Mitarbei.ID FROM Mitarbei WHERE Mitarbei.UserName = N'STHA') AS AnlageUserID_,
  (SELECT Mitarbei.ID FROM Mitarbei WHERE Mitarbei.UserName = N'STHA') AS UserID_
FROM @ImportTable AS ImportTable
JOIN Kunden ON ImportTable.KdNr = Kunden.KdNr
JOIN Vsa ON Vsa.KundenID = Kunden.ID
JOIN Traeger ON Traeger.VsaID = Vsa.ID AND CAST(Traeger.Traeger AS int) = ImportTable.TraegerNr
JOIN TraeArti ON TraeArti.TraegerID = Traeger.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID AND ArtGroe.Groesse = ImportTable.Groesse
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID AND Artikel.ArtikelNr = ImportTable.ArtikelNr;