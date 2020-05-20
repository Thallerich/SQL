-- 5.755 Teile zu iomportieren

DECLARE @TraegerID int = 8233678;  -- Live
--DECLARE @TraegerID int = 8233659;  -- Test
DECLARE @AdvUserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

DECLARE @ImportFile nvarchar(200);
DECLARE @XLSXImportSQL nvarchar(max);

IF OBJECT_ID(N'__Teiledaten', N'U') IS NULL
BEGIN
  CREATE TABLE __Teiledaten (
    Chipcode nchar(33) COLLATE Latin1_General_CS_AS,
    ArtikelNr nchar(15) COLLATE Latin1_General_CS_AS,
    Groesse nchar(10) COLLATE Latin1_General_CS_AS
  );

  SET @ImportFile = N'\\ATENADVANTEX01.wozabal.int\AdvanTex\Temp\20000_Teiledaten.xlsx';

  SET @XLSXImportSQL = N'SELECT CHIPCODE, ARTIKEL, MAAT ' +
  N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [KLEDING$]);';

  INSERT INTO __Teiledaten
  EXEC sp_executesql @XLSXImportSQL;
END;

IF OBJECT_ID(N'__Uebersetzung', N'U') IS NULL
BEGIN
  CREATE TABLE __Uebersetzung (
    ArtikelNrUni nchar(15) COLLATE Latin1_General_CS_AS,
    GroesseUni nchar(10) COLLATE Latin1_General_CS_AS,
    ArtikelNrAdv nchar(15) COLLATE Latin1_General_CS_AS,
    GroesseAdv nchar(10) COLLATE Latin1_General_CS_AS
  );

  SET @ImportFile = N'\\ATENADVANTEX01.wozabal.int\AdvanTex\Temp\20000_Übersetzungsliste.xlsx';

  SET @XLSXImportSQL = N'SELECT CAST(ArtNrUni AS nchar(15)), GroesseUni, CAST(ArtNrAdv AS nchar(15)), GroesseAdv ' +
    N'FROM OPENROWSET(N''Microsoft.ACE.OLEDB.12.0'', N''Excel 12.0 Xml;HDR=YES;Database='+@ImportFile+''', [Tabelle2$]);';

  INSERT INTO __Uebersetzung
  EXEC sp_executesql @XLSXImportSQL;
END;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Optional: delete existing import tables                                                                                   ** */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

/*
DROP TABLE __Teiledaten;
DROP TABLE __Uebersetzung;
*/

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Check data validity                                                                                                       ++ */
/* ** missing translations, wrong sizes                                                                                         ** */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

/*
SELECT DISTINCT Teiledaten.ArtikelNr AS ArtikelNrUni, Teiledaten.Groesse AS GroesseUni, Uebersetzung.ArtikelNrAdv, Uebersetzung.GroesseAdv, ArtGroeTable.ArtikelID, ArtGroeTable.ArtGroeID
FROM __Teiledaten AS Teiledaten
LEFT JOIN __Uebersetzung AS Uebersetzung ON Uebersetzung.ArtikelNrUni = Teiledaten.ArtikelNr AND Uebersetzung.GroesseUni = Teiledaten.Groesse
LEFT JOIN (
  SELECT Artikel.ID AS ArtikelID, ArtGroe.ID AS ArtGroeID, Artikel.ArtikelNr, ArtGroe.Groesse
  FROM ArtGroe
  JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
) AS ArtGroeTable ON ArtGroeTable.ArtikelNr = Uebersetzung.ArtikelNrAdv AND ArtGroeTable.Groesse = Uebersetzung.GroesseAdv
WHERE (Uebersetzung.ArtikelNrAdv != N'weg' OR Uebersetzung.ArtikelNrAdv IS NULL)
  AND (ArtGroeTable.ArtikelID IS NULL OR ArtGroeTable.ArtGroeID IS NULL OR Uebersetzung.ArtikelNrAdv IS NULL);

SELECT RIGHT(RTRIM(Teiledaten.Chipcode), 10) AS Chipcode, Uebersetzung.ArtikelNrAdv, Uebersetzung.GroesseAdv, ArtGroeTable.ArtikelID, ArtGroeTable.ArtGroeID
FROM __Teiledaten AS Teiledaten
JOIN __Uebersetzung AS Uebersetzung ON Uebersetzung.ArtikelNrUni = Teiledaten.ArtikelNr AND Uebersetzung.GroesseUni = Teiledaten.Groesse
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
  );

WITH Importdaten AS (
  SELECT RIGHT(RTRIM(Teiledaten.Chipcode), 10) AS Chipcode, Uebersetzung.ArtikelNrAdv, Uebersetzung.GroesseAdv, ArtGroeTable.ArtikelID, ArtGroeTable.ArtGroeID
  FROM __Teiledaten AS Teiledaten
  JOIN __Uebersetzung AS Uebersetzung ON Uebersetzung.ArtikelNrUni = Teiledaten.ArtikelNr AND Uebersetzung.GroesseUni = Teiledaten.Groesse
  JOIN (
    SELECT Artikel.ID AS ArtikelID, ArtGroe.ID AS ArtGroeID, Artikel.ArtikelNr, ArtGroe.Groesse
    FROM ArtGroe
    JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
  ) AS ArtGroeTable ON ArtGroeTable.ArtikelNr = Uebersetzung.ArtikelNrAdv AND ArtGroeTable.Groesse = Uebersetzung.GroesseAdv
  WHERE Uebersetzung.ArtikelNrAdv != N'weg'
    AND LEFT(Teiledaten.Chipcode, 5) = N'00000'
)
SELECT DISTINCT Importdaten.ArtikelNrAdv
FROM Importdaten
CROSS JOIN (
  SELECT Traeger.ID, Traeger.VsaID, Vsa.KundenID
  FROM Traeger
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  WHERE Traeger.ID = @TraegerID
) AS Traeger
LEFT JOIN KdArti ON Importdaten.ArtikelID = KdArti.ArtikelID AND Traeger.KundenID = KdArti.KundenID AND KdArti.Variante = N'-'
WHERE KdArti.ID IS NULL;
*/

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Trägerartikel anlegen                                                                                                     ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

WITH Importdaten AS (
  SELECT RIGHT(RTRIM(Teiledaten.Chipcode), 10) AS Chipcode, Uebersetzung.ArtikelNrAdv, Uebersetzung.GroesseAdv, ArtGroeTable.ArtikelID, ArtGroeTable.ArtGroeID
  FROM __Teiledaten AS Teiledaten
  JOIN __Uebersetzung AS Uebersetzung ON Uebersetzung.ArtikelNrUni = Teiledaten.ArtikelNr AND Uebersetzung.GroesseUni = Teiledaten.Groesse
  JOIN (
    SELECT Artikel.ID AS ArtikelID, ArtGroe.ID AS ArtGroeID, Artikel.ArtikelNr, ArtGroe.Groesse
    FROM ArtGroe
    JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
  ) AS ArtGroeTable ON ArtGroeTable.ArtikelNr = Uebersetzung.ArtikelNrAdv AND ArtGroeTable.Groesse = Uebersetzung.GroesseAdv
  WHERE Uebersetzung.ArtikelNrAdv != N'weg'
    AND LEFT(Teiledaten.Chipcode, 5) = N'00000'
)
INSERT INTO TraeArti (VsaID, TraegerID, ArtGroeID, KdArtiID, AnlageUserID_)
SELECT DISTINCT Traeger.VsaID, Traeger.ID AS TraegerID, Importdaten.ArtGroeID, KdArti.ID AS KdArtiID, @AdvUserID AS AnlageUserID_
FROM Importdaten
CROSS JOIN (
  SELECT Traeger.ID, Traeger.VsaID, Vsa.KundenID
  FROM Traeger
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  WHERE Traeger.ID = @TraegerID
) AS Traeger
JOIN KdArti ON Importdaten.ArtikelID = KdArti.ArtikelID AND Traeger.KundenID = KdArti.KundenID AND KdArti.Variante = N'-'
WHERE NOT EXISTS (
  SELECT TraeArti.*
  FROM TraeArti
  WHERE TraeArti.TraegerID = Traeger.ID
    AND TraeArti.KdArtiID = KdArti.ID
    AND TraeArti.ArtGroeID = Importdaten.ArtGroeID
);

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Teile importieren                                                                                                         ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

WITH Importdaten AS (
  SELECT RIGHT(RTRIM(Teiledaten.Chipcode), 10) AS Chipcode, Uebersetzung.ArtikelNrAdv, Uebersetzung.GroesseAdv, ArtGroeTable.ArtikelID, ArtGroeTable.ArtGroeID
  FROM __Teiledaten AS Teiledaten
  JOIN __Uebersetzung AS Uebersetzung ON Uebersetzung.ArtikelNrUni = Teiledaten.ArtikelNr AND Uebersetzung.GroesseUni = Teiledaten.Groesse
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
  Traeger.VsaID,
  Traeger.ID AS TraegerID,
  TraeArti.ID AS TraeArtiID,
  TraeArti.KdArtiID,
  KdArti.ArtikelID,
  Importdaten.ArtGroeID,
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
  @AdvUserID AS AnlageUserID_,
  @AdvUserID AS UserID_,
  Importdaten.Chipcode AS RentomatChip
FROM Importdaten
CROSS JOIN (
  SELECT Traeger.ID, Traeger.VsaID, Vsa.KundenID
  FROM Traeger
  JOIN Vsa ON Traeger.VsaID = Vsa.ID
  WHERE Traeger.ID = @TraegerID
) AS Traeger
LEFT JOIN KdArti ON Importdaten.ArtikelID = KdArti.ArtikelID AND Traeger.KundenID = KdArti.KundenID AND KdArti.Variante = N'-'
LEFT JOIN TraeArti ON TraeArti.TraegerID = Traeger.ID AND TraeArti.KdArtiID = KdArti.ID AND TraeArti.ArtGroeID = Importdaten.ArtGroeID
WHERE NOT EXISTS (
  SELECT Teile.*
  FROM Teile
  WHERE Teile.Barcode = Importdaten.Chipcode
);