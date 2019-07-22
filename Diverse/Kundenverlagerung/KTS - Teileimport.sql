/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Import von Teilen zu Trägerartikeln                                                                                       ++ */
/* ++ für Kundenübernahmen von Salesianer Miettex                                                                               ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan Thaller - 2018-10-31                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

DECLARE @KdNr int = 7000097;
DECLARE @ImportFile nvarchar(200) = N'\\atenadvantex01\AdvanTex\Temp\7000097_Total_KTS.xlsx';  -- Pfad zum Excel-File mit den Teile-Daten. Muss für den SQL-Server-Prozess zugreifbar sein, daher am Besten unter \\atenadvantex01\advantex\temp\ ablegen.
DECLARE @XLSXImportSQL nvarchar(max);

DECLARE @ImportTable TABLE (
  Traeger nchar(8) COLLATE Latin1_General_CS_AS,
  Barcode nvarchar(33) COLLATE Latin1_General_CS_AS,
  ArtikelNr nchar(15) COLLATE Latin1_General_CS_AS,
  Groesse nchar(10) COLLATE Latin1_General_CS_AS
);

DECLARE @DoubleParts TABLE (
  TeileID int,
  Teilstatus nchar(2) COLLATE Latin1_General_CS_AS,
  Barcode nvarchar(33) COLLATE Latin1_General_CS_AS
);

SET @XLSXImportSQL = N'SELECT CAST([ID Person Intern] AS nchar(8)) AS Traeger, ' +
  N'CAST(Barcodes AS nvarchar(33)) AS Barcode, ' +
  N'CAST([Salesianer Art#Nr#] AS nchar(15)) AS ArtikelNr, ' +
  N'CAST(Größe AS nchar(10)) AS Groesse ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=Yes;Database='+@ImportFile+''', [Teiledaten$]);';

INSERT INTO @ImportTable
EXEC sp_executesql @XLSXImportSQL;

/*
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
*/
WITH Traegerdaten AS (
  SELECT Traeger.ID AS TraegerID, Traeger.VsaID, TraeArti.ID AS TraeArtiID, TraeArti.KdArtiID, Artikel.ID AS ArtikelID, ArtGroe.ID AS ArtGroeID, Traeger.Traeger, Artikel.ArtikelNr, ArtGroe.Groesse
  FROM TraeArti
  JOIN Traeger ON TraeArti.TraegerID = Traeger.ID
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID
  JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
  WHERE Kunden.KdNr = @KdNr
)
INSERT INTO Teile (Barcode, [Status], VsaID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, Entnommen, EinsatzGrund, PatchDatum, Erstwoche, ErstDatum, Indienst, IndienstDat, AltenheimModus)
SELECT ImportTable.Barcode,
  N'Q' AS [Status],
  Traegerdaten.VsaID,
  Traegerdaten.TraegerID,
  Traegerdaten.TraeArtiID,
  Traegerdaten.KdArtiID,
  Traegerdaten.ArtikelID,
  Traegerdaten.ArtGroeID,
  CAST(1 AS bit) AS Entnommen,
  N'3' AS EinsatzGrund,
  CAST(GETDATE() AS date) AS PatchDatum,
  (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat) AS ErstWoche,
  CAST(GETDATE() AS date) AS ErstDatum,
  (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat) AS Indienst,
  CAST(GETDATE() AS date) AS IndienstDat,
  CAST(0 AS int) AS AltenheimModus
FROM @ImportTable AS ImportTable
JOIN Traegerdaten ON Traegerdaten.Traeger = ImportTable.Traeger AND Traegerdaten.ArtikelNr = ImportTable.ArtikelNr AND Traegerdaten.Groesse = ImportTable.Groesse;


/*
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
*/