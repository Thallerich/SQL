SET NOCOUNT ON;
GO

DROP TABLE IF EXISTS #SMZLPreisPrep, #SMZLPreis;
GO

SELECT DISTINCT Artikel.ID AS ArtikelID, ArtiLief.EkPreis, CAST(IIF(ArtiLief.LiefID = Artikel.LiefID, 1, 0) AS bit) AS Prio
INTO #SMZLPreisPrep
FROM ArtiLief
JOIN Artikel ON ArtiLief.ArtikelID = Artikel.ID
JOIN LiefPrio ON LiefPrio.ArtikelID = ArtiLief.ArtikelID AND LiefPrio.LiefID = ArtiLief.LiefID AND LiefPrio.StandortID = (SELECT ID FROM Standort WHERE SuchCode = N'SMZL')
WHERE ArtiLief.StandortID = (SELECT ID FROM Standort WHERE SuchCode = N'SMZL')
  AND CAST(GETDATE() AS date) BETWEEN ISNULL(ArtiLief.VonDatum, N'1980-01-01') AND ISNULL(ArtiLief.BisDatum, N'2099-12-31')
  AND Artikel.ID IN (
    SELECT DISTINCT Artikel.ID
    FROM KdArti
    JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
    JOIN KdBer ON KdArti.KdBerID = KdBer.ID
    JOIN Bereich ON KdBer.BereichID = Bereich.ID
    JOIN Kunden ON KdArti.KundenID = Kunden.ID
    JOIN Firma ON Kunden.FirmaID = Firma.ID
    WHERE Artikel.EkPreis < 1
      AND (Bereich.Bereich != N'LW' AND Bereich.Bereich != N'PWS' AND Artikel.ArtikelNr NOT LIKE N'SW%')
      AND EXISTS (
        SELECT EinzHist.*
        FROM EinzTeil
        JOIN EinzHist ON EinzTeil.CurrEinzHistID = EinzHist.ID
        WHERE EinzHist.KdArtiID = KdArti.ID
          AND EinzHist.EinzHistTyp = 1
          AND EinzHist.PoolFkt = 0
          AND EinzTeil.AltenheimModus =  0
      )
  );

SELECT *
INTO #SMZLPreis
FROM #SMZLPreisPrep
WHERE Prio = 1;

INSERT INTO #SMZLPreis
SELECT *
FROM #SMZLPreisPrep
WHERE Prio = 0
  AND NOT EXISTS (
    SELECT #SMZLPreis.*
    FROM #SMZLPreis
    WHERE #SMZLPreis.ArtikelID = #SMZLPreisPrep.ArtikelID
  );

DELETE FROM #SMZLPreis WHERE EkPreis < 1;

GO

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');
DECLARE @msg nvarchar(max);

DECLARE @ArtikelEK TABLE (
  ArtikelID int,
  LiefID int,
  EKPreis money
);

BEGIN TRY
  BEGIN TRANSACTION;
  
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ EK-Preis im Artikelstamm setzen und Historie-Eintrag schreiben                                                            ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': UPDATE Artikel.EKPreis start';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    UPDATE Artikel SET EKPreis = #SMZLPreis.EKPreis, VKPreis = VKInfo.VKPreis, UserID_ = @userid
    OUTPUT inserted.ID, inserted.LiefID, inserted.EKPreis
    INTO @ArtikelEK (ArtikelID, LiefID, EKPreis)
    FROM Artikel
    JOIN #SMZLPreis ON #SMZLPreis.ArtikelID = Artikel.ID
    CROSS APPLY advFunc_VKPreisArtikelInfo(-1, #SMZLPreis.EKPreis, Artikel.LiefID, Artikel.VkAufschlagArti, 0) AS VKInfo;

    INSERT INTO ArtEKHis (ArtikelID, EKPreis, GueltigSeit, LiefID, AnlageUserID_, UserID_)
    SELECT ArtikelID, EKPreis, CAST(GETDATE() AS date), LiefID, @userid, @userid
    FROM @ArtikelEK;

    SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': UPDATE Artikel.EKPreis end';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ ArtiLief-Datensatz aktualiesieren oder erstellen                                                                          ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    
    SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': UPDATE ArtiLief start';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;
    
    UPDATE ArtiLief SET EKPreis = Artikel.EKPreis, UserID_ = @userid
    FROM Artikel
    JOIN #SMZLPreis ON #SMZLPreis.ArtikelID = Artikel.ID
    WHERE ArtiLief.ArtikelID = Artikel.ID
      AND ArtiLief.LiefID = Artikel.LiefID
      AND ArtiLief.LiefPackmenge = Artikel.LiefPackmenge
      AND ArtiLief.StandortID = -1;

    INSERT INTO ArtiLief (LiefID, ArtikelID, EKPreis, EKPreisSeit, LiefPackmenge, VonDatum, LiefTageID, AnlageUserID_, UserID_)
    SELECT Artikel.LiefID, Artikel.ID, Artikel.EKPreis, CAST(GETDATE() AS date), Artikel.LiefPackmenge, CAST(GETDATE() AS date), Artikel.LiefTageID, @userid, @userid
    FROM #SMZLPreis
    JOIN Artikel ON #SMZLPreis.ArtikelID = Artikel.ID
    WHERE NOT EXISTS (
      SELECT ArtiLief.*
      FROM ArtiLief
      WHERE ArtiLief.ArtikelID = Artikel.ID
        AND ArtiLief.LiefID = Artikel.LiefID 
        AND ArtiLief.LiefPackmenge = Artikel.LiefPackmenge
        AND ArtiLief.StandortID = -1
    );

    SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': UPDATE ArtiLief end';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ EK-Preis in Artikelgröße setzen                                                                                           ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': UPDATE ArtGroe.EKPreis start';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    UPDATE ArtGroe SET EKPreis = ROUND(Artikel.EKPreis * (1 + (ArtGroe.Zuschlag / 100)), 2), UserID_ = @userid
    FROM #SMZLPreis
    JOIN Artikel ON #SMZLPreis.ArtikelID = Artikel.ID
    WHERE ArtGroe.ArtikelID = Artikel.ID;

    SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': UPDATE ArtGroe.EKPreis end';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
    /* ++ ArGrLief-Datensatz aktualisieren                                                                                          ++ */
    /* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

    SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': UPDATE ArGrLief start';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    UPDATE ArGrLief SET EkPreis = ArtGroe.EKPreis, BestellNr = ArtGroe.BestNr, Zuschlag = ArtGroe.Zuschlag, EAN = ArtGroe.Ean13, LiefTageID = ArtGroe.LiefTageID, UserID_ = @userid
    FROM ArtGroe
    JOIN Artikel ON ArtGroe.ArtikelID = Artikel.ID
    JOIN ArtiLief ON ArtiLief.ArtikelID = Artikel.ID
    JOIN #SMZLPreis ON #SMZLPreis.ArtikelID = Artikel.ID
    WHERE ArGrLief.ArtGroeID = ArtGroe.ID
      AND ArGrLief.ArtiLiefID = ArtiLief.ID
      AND ArGrLief.AbMenge = 1
      AND ArtiLief.StandortID = - 1
      AND ISNULL(ArGrLief.VonDatum, '1980-01-01') <= CAST(GetDate() AS DATE)
      AND ISNULL(ArGrLief.BisDatum, '2099-12-31') >= CAST(GetDate() AS DATE)
      AND (
        (
          ArtiLief.LiefID = ArtGroe.LiefID
          AND ArtGroe.LiefID <> - 1
          )
        OR (
          ArtiLief.LiefID = Artikel.LiefID
          AND ArtGroe.LiefID = - 1
          )
        );

    SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': UPDATE ArGrLief end';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

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

GO

DROP TABLE IF EXISTS #SMZLPreisPrep, #SMZLPreis;
GO