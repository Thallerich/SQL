DROP TABLE IF EXISTS #OpTeilMeng;

SELECT VsaAnf.ID AS VsaAnfID,
  IIF(Daten.LastErsatzFuerKdArtiID > 0, Daten.LastErsatzFuerKdArtiID, VsaAnf.KdArtiID) AS KdArtiID, 
  Vsa.ID AS VsaID, 
  COUNT(Daten.ID) AS BestandIst,
  SUM(IIF(Daten.LastErsatzFuerKdArtiID <> -1, 1, 0)) AS VomIstBestandErsatz,
  SUM(IIF(Daten.LastErsatzFuerKdArtiID <> -1, 0, 1)) AS IstBestandOrig,
  MIN(Daten.ID) AS EinzTeilID,
  IIF(Bereich.VsaAnfGroe = 1, VsaAnf.ArtGroeID, -1) AS ArtGroeID
INTO #OpTeilMeng 
FROM 
(
  /* nicht als Ersatz geliefert */
  SELECT EinzTeil.ID, EinzTeil.VsaID, EinzTeil.LastErsatzFuerKdArtiID, KdArti.KdBerID, KdArti.ID KdArtiID, KdArti.ArtikelID, KdArti.IstBestandAnpass, EinzTeil.ArtGroeID
  FROM EinzTeil, ArtGroe, KdArti, Vsa
  WHERE EinzTeil.LastErsatzFuerKdArtiID = -1
    AND EinzTeil.LastActionsID IN (2, 102, 120, 129, 130, 136, 154)  /* EinzTeil.LastActionsID = (ID_PRODSTAT_AUSLESEN, ID_PRODSTAT_OPAUSLESEN, ID_PRODSTAT_OP_INVENTUR, ID_PRODSTAT_FAHRER_APP_ABLADEN, ID_PRODSTAT_SCHRANKFACH_EINSORTIER, ID_PRODSTAT_UHFWARENEINGANG_KUNDE oder ID_PRODSTAT_SCHWUNDSUCHE_POOLINVENTORY_APP) */
    AND EinzTeil.VsaID > 0
    AND EinzTeil.VsaID = Vsa.ID 
    AND Vsa.KundenID = KdArti.KundenID
    AND ArtGroe.ArtikelID = KdArti.ArtikelID
    AND EinzTeil.ArtGroeID = ArtGroe.ID

  UNION ALL
 
  /* als Ersatz geliefert */
  SELECT EinzTeil.ID, EinzTeil.VsaID, EinzTeil.LastErsatzFuerKdArtiID, KdArti.KdBerID, KdArti.ID KdArtiID, KdArti.ArtikelID, KdArti.IstBestandAnpass, EinzTeil.LastErsatzArtGroeID ArtGroeID
  FROM EinzTeil, KdArti, Vsa
  WHERE EinzTeil.LastErsatzFuerKdArtiID > -1
    AND EinzTeil.LastErsatzFuerKdArtiID = KdArti.ID
    AND EinzTeil.LastActionsID IN (2, 102, 120, 129, 130, 136, 154)  /* EinzTeil.LastActionsID = (ID_PRODSTAT_AUSLESEN, ID_PRODSTAT_OPAUSLESEN, ID_PRODSTAT_OP_INVENTUR, ID_PRODSTAT_FAHRER_APP_ABLADEN, ID_PRODSTAT_SCHRANKFACH_EINSORTIER, ID_PRODSTAT_UHFWARENEINGANG_KUNDE oder ID_PRODSTAT_SCHWUNDSUCHE_POOLINVENTORY_APP) */
    AND EinzTeil.VsaID > 0
    AND EinzTeil.VsaID = Vsa.ID 
    AND Vsa.KundenID = KdArti.KundenID
) Daten, Vsa, kdber, vsaanf, Kunden, Artikel, Bereich
WHERE Vsa.ID = Daten.VsaID
  AND Vsa.KundenID = KdBer.KundenID
  AND Kunden.ID = Vsa.KundenID
  AND Daten.KdBerID = KdBer.ID
  AND Artikel.ID = Daten.ArtikelID
  AND ((KdBer.IstBestandAnpass = 1) OR (Daten.IstBestandAnpass = 1))
  AND VsaAnf.VsaID = Vsa.ID
  AND VsaAnf.KdArtiID = Daten.KdArtiID
  AND KdBer.BereichID = Bereich.ID
  AND (VsaAnf.ArtGroeID = -1 OR (Bereich.VsaAnfGroe = 1 AND VsaAnf.ArtGroeID = Daten.ArtGroeID))
GROUP BY VsaAnf.ID, IIF(Daten.LastErsatzFuerKdArtiID > 0, Daten.LastErsatzFuerKdArtiID, VsaAnf.KdArtiID), Vsa.ID, VsaAnf.Bestand, VsaAnf.BestandIst, IIF(Bereich.VsaAnfGroe = 1, VsaAnf.ArtGroeID, -1);

UPDATE x SET x.BestandIst = IIF(x.BestandIst - z.Geliefert < 0, 0, x.BestandIst - z.Geliefert) 
FROM #OpTeilMeng x, (
  SELECT AnfKo.VsaID, AnfPo.KdArtiID, AnfPo.ArtGroeID, SUM(Geliefert) Geliefert 
  FROM AnfKo, AnfPo, #OpTeilMeng o 
  WHERE AnfKo.Status IN ('N', 'P')
    AND AnfKo.LsKoID = -1 
    AND AnfKo.ID = AnfPo.AnfKoID
    AND AnfKo.VsaID = o.VsaID
    AND AnfPo.KdArtiID = o.KdArtiID
    /* ArtGroeID ist nur gesetzt, wenn der Bereich entsprechend eingestellt ist - die Info wird weiter oben ausgewertet */
    AND AnfPo.ArtGroeID = o.ArtGroeID
    AND AnfKo.LieferDatum >= DATEADD(day, -3, CAST(GETDATE() AS DATE))
GROUP BY AnfKo.VsaID, AnfPo.KdArtiID, AnfPo.ArtGroeID
) z
WHERE z.KdArtiID = x.KdArtiID
  AND z.VsaID = x.VsaID
  AND z.ArtGroeID = x.ArtGroeID;

/* Ermittelte korrekte Werte in VSAANF eintragen */
BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE VsaAnf SET BestandIst = x.BestandIst, VomIstBestandErsatz = x.VomIstBestandErsatz, IstBestandOrig = x.IstBestandOrig
    FROM #OpTeilMeng x
    WHERE VsaAnf.ID = x.VsaAnfID
      AND VsaAnf.BestandIst <> x.BestandIst;
  
  COMMIT;
END TRY
BEGIN CATCH
  DECLARE @Message varchar(MAX) = ERROR_MESSAGE();
  DECLARE @Severity int = ERROR_SEVERITY();
  DECLARE @State smallint = ERROR_STATE();
  
  IF XACT_STATE() != 0
    ROLLBACK TRANSACTION;
  
  RAISERROR(@Message, @Severity, @State) WITH NOWAIT;
END CATCH;

DROP TABLE IF EXISTS #OpTeilMeng;