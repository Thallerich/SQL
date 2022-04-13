DROP TABLE IF EXISTS #OpTeileBKAnlage;

SELECT DISTINCT EinzTeil.ID AS EinzTeilID, EinzTeil.Code, - 1 KundenID, EinzTeil.ArtikelID, EinzTeil.ArtGroeID, '-' Variante, 0 VariantNum, '' VariantBez, 'A' STATUS, 0 NurKundenEigen, isnull(KdBer.ID, - 1) KdberID, Artikel.BereichID, 0 Leasingpreis, 0 WAschpreis, 0 VkPreis, 0 Vorlaeufig, - 1 WaschPrgID, - 1 LiefArtID, - 1 FinishingMethod_ID, 1 EigentumID, 0 KaufwareModus, - 1 FolgeKdArtiID, 156 AfaWochen, 0 AusblendenVsaAnfEingang, 0 AusblendenVsaAnfAusgang, 1 ArtiZwingendBarcodiert, - 1 KdArtiID, - 1 VsaID, - 1 TraegerID, - 1 TraeArtiID
INTO #OpTeileBKAnlage
FROM EinzTeil
JOIN Artikel ON EinzTeil.ArtikelID = Artikel.ID
LEFT JOIN Vsa ON EinzTeil.VsaOwnerID = Vsa.ID
LEFT JOIN KdBer ON KdBer.KundenID = Vsa.KundenID AND KdBer.BereichID = Artikel.BereichID
WHERE Artikel.ID IN (
    SELECT DISTINCT ArtikelID
    FROM KdArti
    WHERE KundenID = (
        SELECT ID
        FROM Kunden
        WHERE KdNr = 100151
        )
      AND KdArti.Status = N'A'
    )
  AND NOT EXISTS (
    SELECT *
    FROM Teile
    WHERE EinzTeilID = EinzTeil.ID
    )
  AND NOT EXISTS (
    SELECT *
    FROM Teile
    WHERE Barcode = EinzTeil.Code
    )
  AND EinzTeil.VsaOwnerID = -1
  AND EinzTeil.Status IN (N'Q', N'A');

UPDATE #OpTeileBKAnlage SET KdberID = KdBer.ID, KundenID = Kunden.ID
FROM Kunden, KdBer
WHERE KdBer.KundenID = Kunden.ID
  AND Kunden.KdNr = 100151 /*Dummy-KdNr*/
  AND #OpTeileBKAnlage.BereichID = KdBer.BereichID
  AND #OpTeileBKAnlage.KundenID = -1;

UPDATE #OpTeileBKAnlage SET KdArtiID = KdArti.ID
FROM KdArti
WHERE #OpTeileBKAnlage.KundenID = KdArti.KundenID
  AND #OpTeileBKAnlage.ArtikelID = KdArti.ArtikelID;

UPDATE #OpTeileBKAnlage SET VsaID = Vsa.ID
FROM Vsa
WHERE #OpTeileBKAnlage.KundenID = Vsa.KundenID
  AND #OpTeileBKAnlage.vsaID = -1;

UPDATE #OpTeileBKAnlage SET TraegerID = Traeger.ID
FROM Traeger
WHERE Traeger.VsaID = #OpTeileBKAnlage.VsaID
  AND Traeger.Vorname = N'Pool'
  AND Traeger.Nachname = N'Dummy';

INSERT INTO TraeArti (VsaID, TraegerID, KdArtiID, ArtGroeID)
SELECT DISTINCT op.VsaID, op.TraegerID, op.KdArtiID, op.ArtGroeID
FROM #OpTeileBKAnlage op
WHERE NOT EXISTS (
    SELECT ID
    FROM TraeArti
    WHERE TraeArti.TraegerID = op.TraegerID
      AND TraeArti.KdArtiID = op.KdArtiID
      AND TraeArti.ArtGroeID = op.ArtGroeID
    );

UPDATE #OpTeileBKAnlage SET TraeArtiID = TraeArti.ID
FROM TraeArti
WHERE #OpTeileBKAnlage.TraegerID = TraeArti.TraegerID
  AND #OpTeileBKAnlage.KdArtiID = TraeArti.KdArtiID
  AND #OpTeileBKAnlage.ArtGroeID = TraeArti.ArtGroeID;

INSERT INTO Teile (Barcode, STATUS, TraegerID, TraeArtiID, ArtikelID, ArtGroeID, KdArtiID, VsaID, EinzTeilID, IndienstDat, Indienst, ErstDatum, PatchDatum, EinsatzGrund)
SELECT op.Code Barcode, 'Q' STATUS, TraegerID, TraeArtiID, ArtikelID, ArtGroeID, KdArtiID, VsaID, EinzTeilID, CAST(N'1980-01-01' AS date) AS Indienstdat, dbo.WeekOfDate(CAST(N'1980-01-01' AS date)) AS Indienst, CAST(N'1980-01-01' AS date) AS Erstdatum, CAST(N'1980-01-01' AS date) AS PatchDatum, N'5' AS EinsatzGrund
FROM #OpTeileBKAnlage op
WHERE NOT EXISTS (
    SELECT ID
    FROM Teile
    WHERE op.Code = Teile.Barcode
  );