/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Import von Teilen zu Trägerartikeln                                                                                       ++ */
/* ++ für Kundenübernahmen von Salesianer Miettex                                                                               ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan Thaller - 2018-08-29                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @ImportFile nvarchar(200) = N'\\atenadvantex01\AdvanTex\Temp\2018-09-12_31172_Hubers Landhendl_VSA Produktion.xlsx';  -- Pfad zum Excel-File mit den Teile-Daten. Muss für den SQL-Server-Prozess zugreifbar sein, daher am Besten unter \\atenadvantex01\advantex\temp\ ablegen.
DECLARE @XLSXImportSQL nvarchar(max);

DECLARE @ImportTable TABLE (
  KdNr int,
  Vsa int,
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
  Eingang1 date,
  Ausgang1 date,
  IndienstDat date,
  Waschzyklen int,
  AlterMonate int
);

DECLARE @DoubleParts TABLE (
  TeileID int,
  Teilstatus nchar(2) COLLATE Latin1_General_CS_AS,
  Barcode nvarchar(33) COLLATE Latin1_General_CS_AS
);

SET @XLSXImportSQL = N'SELECT CAST(KDNR as int) AS KdNr, ' +
  N'CAST(Abt AS int) AS Vsa, ' +
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
  N'CONVERT(date, [Letzte Einscannung], 104) AS Eingang1, ' +
  N'CONVERT(date, [Letzte Ausscannung], 104) AS Ausgang1, ' +
  N'CONVERT(date, [Letztes Einsatzdatu], 104) AS IndienstDat, ' +
  N'CAST(Waschzyklen AS int) AS Waschzyklen, ' +
  N'CAST([Alter in Monate] AS int) AS AlterMonate ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [Teiledaten$]);';

INSERT INTO @ImportTable
EXEC sp_executesql @XLSXImportSQL;

-- Prüfung auf bereits vorhandene Barcode - Ausgabe der bereits im AdvanTex vorhandenen Teile
INSERT INTO @DoubleParts
SELECT Teile.ID AS TeileID, Teile.Status AS Teilstatus, Teile.Barcode
FROM Teile
WHERE EXISTS (
  SELECT *
  FROM @ImportTable AS Import
  WHERE Teile.Barcode = Import.Barcode
);

-- Teile mit Status Schrott, Lager, Lager verbraucht - Barcode mit *SAL erweitern, damit Übernahme-Teil importiert werden kann
UPDATE Teile SET Teile.Barcode = RTRIM(Teile.Barcode) + N'*SAL'
WHERE Teile.ID IN (
  SELECT DoubleParts.TeileID
  FROM @DoubleParts AS DoubleParts
  WHERE DoubleParts.Teilstatus IN (N'Y', N'L', N'LM')
);

-- Wenn Teil bereits im AdvanTex vorhanden ist (und nicht den Status Schrott, Lager, Lager verbraucht aufweist), dann das Übernahme-Teil mit *SAL erweitern um es importieren zu können
-- Nach dem Import wird dann ein Hinweis beim bestehenden Teil und beim Übernahme-Teil angelegt
UPDATE @ImportTable SET Barcode = RTRIM(Barcode) + N'*SAL'
WHERE Barcode IN (
  SELECT DoubleParts.Barcode
  FROM @DoubleParts AS DoubleParts
  WHERE DoubleParts.Teilstatus NOT IN (N'Y', N'L', N'LM')
);

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
JOIN Vsa ON Vsa.KundenID = Kunden.ID AND Vsa.VsaNr = ImportTable.Vsa
JOIN Traeger ON Traeger.VsaID = Vsa.ID AND CAST(Traeger.Traeger AS int) = ImportTable.TraegerNr
JOIN TraeArti ON TraeArti.TraegerID = Traeger.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID AND ArtGroe.Groesse = ImportTable.Groesse
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID AND Artikel.ArtikelNr = ImportTable.ArtikelNr;

-- Umpatch-Hinweis bei bestehenden Teilen anlegen
INSERT INTO Hinweis (TeileID, Aktiv, StatusSDC, Hinweis, BisWoche, Anzahl, EingabeDatum, EingabeMitarbeiID, Wichtig)
SELECT DoubleParts.TeileID, 1 AS Aktiv, N'A' AS StatusSDC, N'<o> ACHTUNG:Neuen Barcode patchen! Auf korrekten Kunden achten! Kundenübernahme von Salesianer!' AS Hinweis, N'2099/52' AS BisWoche, 1 AS Anzahl, CAST(GETDATE() AS date) AS Eingabedatum, (SELECT Mitarbei.ID FROM Mitarbei WHERE Mitarbei.UserName = N'STHA') AS EingabeMitarbeiID, 1 AS Wichtig
FROM @DoubleParts AS Doubleparts
WHERE DoubleParts.Teilstatus NOT IN (N'Y', N'L', N'LM');

-- Umpatch-Hinweis bei importierten Teilen anlegen
INSERT INTO Hinweis (TeileID, Aktiv, StatusSDC, Hinweis, BisWoche, Anzahl, EingabeDatum, EingabeMitarbeiID, Wichtig)
SELECT Teile.ID, 1 AS Aktiv, N'A' AS StatusSDC, N'<o> ACHTUNG:Neuen Barcode patchen! Auf korrekten Kunden achten! Kundenübernahme von Salesianer!' AS Hinweis, N'2099/52' AS BisWoche, 1 AS Anzahl, CAST(GETDATE() AS date) AS Eingabedatum, (SELECT Mitarbei.ID FROM Mitarbei WHERE Mitarbei.UserName = N'STHA') AS EingabeMitarbeiID, 1 AS Wichtig
FROM @DoubleParts AS Doubleparts
JOIN Teile ON Teile.Barcode = RTRIM(Doubleparts.Barcode) + N'*SAL'
WHERE DoubleParts.Teilstatus NOT IN (N'Y', N'L', N'LM');