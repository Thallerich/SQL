DECLARE @ImportFile nvarchar(200) = N'\\ATENADVANTEX01.wozabal.int\AdvanTex\Temp\20000_Teiledaten.xlsx';
DECLARE @XLSXImportSQL nvarchar(max);

DECLARE @Teiledaten TABLE (
  Chipcode nchar(33) COLLATE Latin1_General_CS_AS,
  ArtikelNr nchar(15) COLLATE Latin1_General_CS_AS,
  Groesse nchar(10) COLLATE Latin1_General_CS_AS
);

DECLARE @Uebersetzung TABLE (
  ArtikelNrUni nchar(15) COLLATE Latin1_General_CS_AS,
  GroesseUni nchar(10) COLLATE Latin1_General_CS_AS,
  ArtikelNrAdv nchar(15) COLLATE Latin1_General_CS_AS,
  GroesseAdv nchar(10) COLLATE Latin1_General_CS_AS
);

SET @XLSXImportSQL = N'SELECT CHIPCODE, ARTIKEL, MAAT ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [KLEDING$]);';

INSERT INTO @Teiledaten
EXEC sp_executesql @XLSXImportSQL;

SET @ImportFile = N'\\ATENADVANTEX01.wozabal.int\AdvanTex\Temp\20000_Übersetzungsliste.xlsx';

SET @XLSXImportSQL = N'SELECT CAST(ArtNrUni AS nchar(15)), GroesseUni, CAST(ArtNrAdv AS nchar(15)), GroesseAdv ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [Tabelle2$]);';

INSERT INTO @Uebersetzung
EXEC sp_executesql @XLSXImportSQL;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Check data validity                                                                                                       ++ */
/* ** missing translations, wrong sizes                                                                                         ** */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
SELECT DISTINCT Teiledaten.ArtikelNr AS ArtikelNrUni, Teiledaten.Groesse AS GroesseUni, Uebersetzung.ArtikelNrAdv, Uebersetzung.GroesseAdv, ArtGroeTable.ArtikelID, ArtGroeTable.ArtGroeID
FROM @Teiledaten AS Teiledaten
LEFT JOIN @Uebersetzung AS Uebersetzung ON Uebersetzung.ArtikelNrUni = Teiledaten.ArtikelNr AND Uebersetzung.GroesseUni = Teiledaten.Groesse
LEFT JOIN (
  SELECT Artikel.ID AS ArtikelID, ArtGroe.ID AS ArtGroeID, Artikel.ArtikelNr, ArtGroe.Groesse
  FROM ArtGroe
  JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
) AS ArtGroeTable ON ArtGroeTable.ArtikelNr = Uebersetzung.ArtikelNrAdv AND ArtGroeTable.Groesse = Uebersetzung.GroesseAdv
WHERE (Uebersetzung.ArtikelNrAdv != N'weg' OR Uebersetzung.ArtikelNrAdv IS NULL)
  AND (ArtGroeTable.ArtikelID IS NULL OR ArtGroeTable.ArtGroeID IS NULL OR Uebersetzung.ArtikelNrAdv IS NULL);

SELECT RIGHT(RTRIM(Teiledaten.Chipcode), 10) AS Chipcode, Uebersetzung.ArtikelNrAdv, Uebersetzung.GroesseAdv, ArtGroeTable.ArtikelID, ArtGroeTable.ArtGroeID
FROM @Teiledaten AS Teiledaten
JOIN @Uebersetzung AS Uebersetzung ON Uebersetzung.ArtikelNrUni = Teiledaten.ArtikelNr AND Uebersetzung.GroesseUni = Teiledaten.Groesse
JOIN (
  SELECT Artikel.ID AS ArtikelID, ArtGroe.ID AS ArtGroeID, Artikel.ArtikelNr, ArtGroe.Groesse
  FROM ArtGroe
  JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
) AS ArtGroeTable ON ArtGroeTable.ArtikelNr = Uebersetzung.ArtikelNrAdv AND ArtGroeTable.Groesse = Uebersetzung.GroesseAdv
WHERE Uebersetzung.ArtikelNrAdv != N'weg'
  AND LEFT(Teiledaten.Chipcode, 5) = N'00000'
  AND EXISTS (
    SELECT Teile.*
    FROM Teile
    WHERE --Teile.RentomatChip = RIGHT(RTRIM(Teiledaten.Chipcode), 5)
      Teile.Barcode = RIGHT(RTRIM(Teiledaten.Chipcode), 5)
  )

WITH Importdaten AS (
  SELECT RIGHT(RTRIM(Teiledaten.Chipcode), 10) AS Chipcode, Uebersetzung.ArtikelNrAdv, Uebersetzung.GroesseAdv, ArtGroeTable.ArtikelID, ArtGroeTable.ArtGroeID
  FROM @Teiledaten AS Teiledaten
  JOIN @Uebersetzung AS Uebersetzung ON Uebersetzung.ArtikelNrUni = Teiledaten.ArtikelNr AND Uebersetzung.GroesseUni = Teiledaten.Groesse
  JOIN (
    SELECT Artikel.ID AS ArtikelID, ArtGroe.ID AS ArtGroeID, Artikel.ArtikelNr, ArtGroe.Groesse
    FROM ArtGroe
    JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
  ) AS ArtGroeTable ON ArtGroeTable.ArtikelNr = Uebersetzung.ArtikelNrAdv AND ArtGroeTable.Groesse = Uebersetzung.GroesseAdv
  WHERE Uebersetzung.ArtikelNrAdv != N'weg'
    AND LEFT(Teiledaten.Chipcode, 5) = N'00000'
)
INSERT INTO Teile (Barcode, [Status], VsaID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, Eingang1, Ausgang1, Entnommen, EinsatzGrund, PatchDatum, Erstwoche, ErstDatum, Indienst, IndienstDat, RuecklaufG, Kostenlos, AlterInfo, AltenheimModus, AnlageUserID_, UserID_, RentomatChip)
SELECT Importdaten.Chipcode,
  N'Q' AS [Status],
  Vsa.ID AS VsaID,
  Traeger.ID AS TraegerID,
  TraeArti.ID AS TraeArtiID,
  TraeArti.KdArtiID, Artikel.ID AS ArtikelID,
  ArtGroe.ID AS ArtGroeID,
  NULL AS Eingang1,
  NULL AS Ausgang1,
  CAST(1 AS bit) AS Entnommen,
  N'3' AS EinsatzGrund,
  CAST(GETDATE() AS date) AS PatchDatum,
  N'1980/01' AS ErstWoche,
  N'1980-01-01' AS ErstDatum,
  N'1980/01' AS Indienst,
  N'1980-01-01' AS IndienstDat,
  1 AS RuecklaufG,
  CAST(0 AS bit) AS Kostenlos,
  0 AS AlterInfo,
  CAST(0 AS int) AS AltenheimModus,
  (SELECT Mitarbei.ID FROM Mitarbei WHERE Mitarbei.UserName = N'THALST') AS AnlageUserID_,
  (SELECT Mitarbei.ID FROM Mitarbei WHERE Mitarbei.UserName = N'THALST') AS UserID_,
  Importdaten.Chipcode AS RentomatChip
FROM Importdaten
JOIN Kunden ON ImportTable.KdNr = Kunden.KdNr
JOIN Vsa ON Vsa.KundenID = Kunden.ID AND Vsa.VsaNr = ImportTable.Vsa
JOIN Traeger ON Traeger.VsaID = Vsa.ID AND CAST(Traeger.Traeger AS int) = ImportTable.TraegerNr
JOIN TraeArti ON TraeArti.TraegerID = Traeger.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID AND ArtGroe.Groesse = ImportTable.Groesse
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID AND Artikel.ArtikelNr = ImportTable.ArtikelNr;