/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Import von Teilen zu Trägerartikeln                                                                                       ++ */
/* ++ für Kundenübernahmen von Salesianer Miettex                                                                               ++ */
/* ++                                                                                                                           ++ */
/* ++ Author: Stefan Thaller - 2018-06-27                                                                                       ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

-- 9398 Datensätze
INSERT INTO Teile (Barcode, [Status], VsaID, TraegerID, TraeArtiID, KdArtiID, ArtikelID, ArtGroeID, Entnommen, EinsatzGrund, PatchDatum, Erstwoche, ErstDatum, Indienst, IndienstDat, RuecklaufG, Kostenlos, AlterInfo, AltenheimModus, AnlageUserID_, UserID_)
SELECT LHImport.Barcode,
  N'Q' AS [Status],
  Vsa.ID AS VsaID,
  Traeger.ID AS TraegerID,
  TraeArti.ID AS TraeArtiID,
  TraeArti.KdArtiID, Artikel.ID AS ArtikelID,
  ArtGroe.ID AS ArtGroeID,
  CAST(1 AS bit) AS Entnommen,
  N'3' AS EinsatzGrund,
  CAST(GETDATE() AS date) AS PatchDatum,
  (SELECT Week.Woche FROM Week WHERE ISNULL(DATEADD(month, LHImport.[Alter in Monate] * -1, CAST(GETDATE() AS date)), N'1980-01-01') BETWEEN Week.VonDat AND Week.BisDat) AS ErstWoche,
  ISNULL(DATEADD(month, LHImport.[Alter in Monate] * -1, CAST(GETDATE() AS date)), N'1980-01-01') AS ErstDatum,
  (SELECT Week.Woche FROM Week WHERE ISNULL(LHImport.IndienstDat, N'1980-01-01') BETWEEN Week.VonDat AND Week.BisDat) AS Indienst,
  ISNULL(LHImport.IndienstDat, N'1980-01-01') AS IndienstDat,
  LHImport.Waschzyklen AS RuecklaufG,
  CAST(0 AS bit) AS Kostenlos,
  DATEDIFF(week, ISNULL(DATEADD(month, LHImport.[Alter in Monate] * -1, CAST(GETDATE() AS date)), N'1980-01-01'), GETDATE()) AS AlterInfo,
  CAST(0 AS int) AS AltenheimModus,
  (SELECT Mitarbei.ID FROM Mitarbei WHERE Mitarbei.UserName = N'STHA') AS AnlageUserID_,
  (SELECT Mitarbei.ID FROM Mitarbei WHERE Mitarbei.UserName = N'STHA') AS UserID_
FROM __LHTeile AS LHImport
JOIN Kunden ON LHImport.KdNr = Kunden.KdNr
JOIN Vsa ON Vsa.KundenID = Kunden.ID AND ISNULL(CAST(LHImport.Schrank AS nchar(7)), N'EMPFANG') COLLATE Latin1_General_CS_AS = Vsa.SuchCode
JOIN Traeger ON Traeger.VsaID = Vsa.ID AND CAST(Traeger.Traeger AS int) = LHImport.TraegerNr
JOIN TraeArti ON TraeArti.TraegerID = Traeger.ID
JOIN ArtGroe ON TraeArti.ArtGroeID = ArtGroe.ID AND ArtGroe.Groesse = LHImport.Groesse COLLATE Latin1_General_CS_AS
JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID AND Artikel.ArtikelNr = LHImport.Artikel COLLATE Latin1_General_CS_AS;