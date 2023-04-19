DROP TABLE IF EXISTS #OpTeileBKAnlage;

SELECT DISTINCT EinzTeil.ID AS EinzTeilID, EinzHist.ID EinzHistID, EinzHist.Barcode, - 1 KundenID, EinzHist.ArtikelID, EinzHist.ArtGroeID, isnull(KdBer.ID, - 1) KdberID, Artikel.BereichID, - 1 KdArtiID, - 1 VsaID, - 1 TraegerID, - 1 TraeArtiID
INTO #OpTeileBKAnlage
FROM EinzTeil
JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
JOIN Artikel ON EinzHist.ArtikelID = Artikel.ID
LEFT JOIN Vsa ON EinzTeil.VsaOwnerID = Vsa.ID
LEFT JOIN KdBer ON KdBer.KundenID = Vsa.KundenID AND KdBer.BereichID = Artikel.BereichID
WHERE Artikel.ID IN (
    SELECT DISTINCT ArtikelID
    FROM KdArti, Artikel, Bereich
    WHERE KdArti.KundenID = (
        SELECT ID
        FROM Kunden
        WHERE KdNr = 100151
        )
      AND KdArti.Status = N'A'
      AND KdArti.ArtikelID = Artikel.ID
      AND Artikel.BereichID = Bereich.ID
      AND (Bereich.Bereich = 'BK' OR Artikel.ID IN (SELECT ArtikelID from __FW_Artikel_fuer_SDC))
    )
AND EinzHist.EinzHistTyp = 1
AND EinzHist.TraeArtiID = -1
AND EinzHist.PoolFkt = 1
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

-- Vor dem Einfügen das Offsett für die RepQueue erhöhen. Die neuen Teile hier können auch später verarbeitet werden.
IF OBJECT_ID('tempdb..#AdvSession') IS NOT NULL 
BEGIN 
  UPDATE #AdvSession SET OffSet = 100000;
END;

-- Absichern, falls das SQL knallt (Blockierung etc.), damit das Offset auf jeden Fall wieder zurückgesetzt wird
BEGIN TRY
UPDATE EinzHist SET
KundenID = op.KundenID, 
VsaID = op.VsaID, 
TraegerID = op.TraegerID, 
KdArtiID = op.KdArtiID, 
TraeArtiID = op.TraeArtiID  
FROM #OpTeileBKAnlage op 
WHERE op.EinzHistID = EinzHist.ID;
-- Update auf das EinzTeil, damit dies auch an die SDCs übertragen wird
UPDATE EinzTeil SET Code = EinzTeil.Code
FROM #OpTeileBKAnlage op 
WHERE op.EinzTeilID = EinzTeil.ID;
END TRY
BEGIN CATCH
END CATCH;
-- Offset wieder auf 0 setzen.
IF OBJECT_ID('tempdb..#AdvSession') IS NOT NULL 
BEGIN 
  UPDATE #AdvSession SET OffSet = 0;
END;