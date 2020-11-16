DECLARE @ImportFile nvarchar(200) = N'\\ATENADVANTEX01.wozabal.int\AdvanTex\Temp\Bewohnerteile.xlsx';
DECLARE @XLSXImportSQL nvarchar(max);
DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');
DECLARE @Week nchar(7) = (SELECT Week.Woche FROM Week WHERE CAST(GETDATE() AS date) BETWEEN Week.VonDat AND Week.BisDat);

DECLARE @ImportTable TABLE (
  KdNr int,
  VsaNr nvarchar(40) COLLATE Latin1_General_CS_AS,
  --Kostenstelle nvarchar(20) COLLATE Latin1_General_CS_AS,
  BewohnerNr nchar(8) COLLATE Latin1_General_CS_AS,
  Nachname nvarchar(25) COLLATE Latin1_General_CS_AS,
  Vorname nvarchar(20) COLLATE Latin1_General_CS_AS,
  ZimmerNr nchar(10) COLLATE Latin1_General_CS_AS,
  ArtikelNr nchar(15) COLLATE Latin1_General_CS_AS,
  ArtikelBez nvarchar(60) COLLATE Latin1_General_CS_AS,
  Barcode nvarchar(33) COLLATE Latin1_General_CS_AS
);

SET @XLSXImportSQL = N'SELECT * FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [BewImport$]);';

INSERT INTO @ImportTable
EXEC sp_executesql @XLSXImportSQL;

MERGE INTO TraeArti
USING (
  SELECT DISTINCT Vsa.ID AS VsaID, Traeger.ID AS TraegerID, ArtGroe.ID AS ArtGroeID, KdArti.ID AS KdArtiID
  FROM @ImportTable IT
  JOIN Vsa ON IT.VsaNr = Vsa.SuchCode
  JOIN Kunden ON Vsa.KundenID = Kunden.ID AND IT.KdNr = Kunden.KdNr
  JOIN Artikel ON IT.ArtikelNr = Artikel.ArtikelNr
  JOIN KdArti ON KdArti.ArtikelID = Artikel.ID AND KdArti.KundenID = Kunden.ID
  JOIN Traeger ON Traeger.VsaID = Vsa.ID AND Traeger.Traeger = IT.BewohnerNr AND Traeger.Nachname = IT.Nachname AND Traeger.Vorname = IT.Vorname AND Traeger.Altenheim = 1
  JOIN ArtGroe ON ArtGroe.ArtikelID = Artikel.ID AND ArtGroe.Groesse = N'-'
) AS ImportData ON TraeArti.TraegerID = ImportData.TraegerID AND TraeArti.KdArtiID = ImportData.KdArtiID AND TraeArti.ArtGroeID = ImportData.ArtGroeID
WHEN NOT MATCHED THEN
  INSERT (TraegerID, KdArtiID, ArtGroeID, VsaID, AnlageUserID_, UserID_)
  VALUES (ImportData.TraegerID, ImportData.KdArtiID, ImportData.ArtGroeID, ImportData.VsaID, @UserID, @UserID);

INSERT INTO Teile (Barcode, [Status], VsaID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, AltenheimModus, Entnommen, Indienst, IndienstDat, Erstwoche, ErstDatum, PatchDatum, EinsatzGrund, AnlageUserID_, UserID_)
SELECT IT.Barcode, N'Q' AS [Status], Vsa.ID AS VsaID, Traeger.ID AS TraegerID, TraeArti.ID AS TraeArtiID, KdArti.ID AS KdArtiID, Artikel.ID AS ArtikelID, ArtGroe.ID AS ArtGroeID, CAST(1 AS bit) AS AltenheimModus, CAST(1 AS bit) AS Entnommen, @Week AS Indienst, CAST(GETDATE() AS date) AS IndienstDat, @Week AS Erstwoche, CAST(GETDATE() AS date) AS ErstDatum, CAST(GETDATE() AS date) AS Patchdatum, N'3' AS EinsatzGrund, @UserID AS AnlageUserID_, @UserID AS UserID_
FROM @ImportTable IT
JOIN Vsa ON IT.VsaNr = Vsa.SuchCode
JOIN Kunden ON Vsa.KundenID = Kunden.ID AND IT.KdNr = Kunden.KdNr
JOIN Artikel ON IT.ArtikelNr = Artikel.ArtikelNr
JOIN KdArti ON KdArti.ArtikelID = Artikel.ID AND KdArti.KundenID = Kunden.ID
JOIN Traeger ON Traeger.VsaID = Vsa.ID AND Traeger.Traeger = IT.BewohnerNr AND Traeger.Nachname = IT.Nachname AND Traeger.Vorname = IT.Vorname
JOIN ArtGroe ON ArtGroe.ArtikelID = Artikel.ID AND ArtGroe.Groesse = N'-'
JOIN TraeArti ON TraeArti.TraegerID = Traeger.ID AND TraeArti.KdArtiID = KdArti.ID AND TraeArti.ArtGroeID = ArtGroe.ID
WHERE NOT EXISTS (
  SELECT Teile.*
  FROM Teile
  WHERE Teile.Barcode = IT.Barcode
);