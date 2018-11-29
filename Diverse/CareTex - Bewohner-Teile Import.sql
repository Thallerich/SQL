DROP TABLE IF EXISTS #BTImport;

-- 188.960 Teile zu importieren - 2.514 vorhandenen = 186 446 importiert
SELECT BT.Barcode, Vsa.ID AS VsaID, Traeger.ID AS TraegerID, ArtGroe.ID AS ArtGroeID, KdArti.ID AS KdArtiID, Artikel.ID AS ArtikelID, 9245 AS UserID
INTO #BTImport
FROM (
  SELECT Barcode, MAX(TrägerID) AS TraegerID, Artikelnummer, Artikelbezeichnung
  FROM Wozabal.dbo.__Bewohnerteile
  GROUP BY Barcode, Artikelnummer, Artikelbezeichnung
) AS BT
JOIN Traeger ON BT.TraegerID = Traeger.ID
JOIN Vsa ON Traeger.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID AND Artikel.ArtikelNr = BT.Artikelnummer
JOIN ArtGroe ON ArtGroe.ArtikelID = Artikel.ID
WHERE BT.Artikelbezeichnung NOT LIKE N'Wäschesack%';

SELECT * FROM #BTImport;

BEGIN TRANSACTION;
  -- TraeArti: VsaID, TraegerID, ArtGroeID, KdArtiID, AnlageUserID_, UserID_
  INSERT INTO TraeArti (VsaID, TraegerID, ArtGroeID, KdArtiID, AnlageUserID_, UserID_)
  SELECT DISTINCT BTImport.VsaID, BTImport.TraegerID, BTImport.ArtGroeID, BTImport.KdArtiID, BTImport.UserID AS AnlageUserID_, BTImport.UserID AS UserID_
  FROM #BTImport AS BTImport
  WHERE NOT EXISTS (
    SELECT TraeArti.*
    FROM TraeArti
    WHERE TraeArti.TraegerID = BTImport.TraegerID
      AND TraeArti.KdArtiID = BTImport.KdArtiID
      AND TraeArti.ArtGroeID = BTImport.ArtGroeID
  );

  -- Teile: Barcode, [Status], VsaID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, Eingang1, Ausgang1, Entnommen, EinsatzGrund, PatchDatum, Erstwoche, ErstDatum, Indienst, IndienstDat, RuecklaufG, Kostenlos, AlterInfo, AltenheimModus, AnlageUserID_, UserID_
  INSERT INTO Teile (Barcode, [Status], VsaID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, AltenheimModus, Entnommen, Indienst, IndienstDat, Erstwoche, ErstDatum, PatchDatum, EinsatzGrund, AnlageUserID_, UserID_)
  SELECT N'999' + RTRIM(BTImport.Barcode) AS Barcode, N'Q' AS [Status], BTImport.VsaID, BTImport.TraegerID, TraeArti.ID AS TraeArtiID, BTImport.KdArtiID, BTImport.ArtikelID, BTImport.ArtGroeID, CAST(1 AS bit) AS AltenheimModus, CAST(1 AS bit) AS Entnommen, N'2018/48' AS Indienst, CAST(GETDATE() AS date) AS IndienstDat, N'2018/48' AS Erstwoche, CAST(GETDATE() AS date) AS ErstDatum, CAST(GETDATE() AS date) AS Patchdatum, N'3' AS EinsatzGrund, BTImport.UserID AS AnlageUserID_, BTImport.UserID AS UserID_
  FROM #BTImport AS BTImport
  JOIN TraeArti ON BTImport.VsaID = TraeArti.VsaID AND BTImport.TraegerID = TraeArti.TraegerID AND BTImport.ArtGroeID = TraeArti.ArtGroeID AND BTImport.KdArtiID = TraeArti.KdArtiID
  WHERE NOT EXISTS (
    SELECT Teile.*
    FROM Teile
    WHERE Teile.Barcode = N'999' + RTRIM(BTImport.Barcode)
  );
COMMIT;