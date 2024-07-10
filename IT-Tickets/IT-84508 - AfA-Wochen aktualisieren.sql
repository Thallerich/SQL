SET CONTEXT_INFO 0x1; /* AdvanTex-Trigger für RepQueue deaktivieren */
GO

/* Step 1a - Set AfAWochen on customer article         */
/*          exclude those that are set by price list! */

DECLARE @KdArti TABLE (
  KdArtiID int PRIMARY KEY CLUSTERED,
  AfaWochen int,
  RepQueueDone bit DEFAULT 0
);

DECLARE @KdArtiRep TABLE (
  KdArtiID int
);

DECLARE @Message varchar(MAX), @Severity int, @State smallint;

INSERT INTO @KdArti (KdArtiID, AfaWochen)
SELECT KdArti.ID AS KdArtiID, IIF(PrListKdArti.AfAundBasisRWausPrList = 1 AND KdArti.BasisRWPrListKdArtiID > 0, KdArti.AfaWochen, _IT84508.AfaWochen) AS AfAWochen
/* SELECT Kunden.KdNr, Kunden.SuchCode, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, KdArti.Variante, KdArti.AfaWochen, PrListKdArti.AfAundBasisRWausPrList, KdArti.BasisRWPrListKdArtiID, _IT84508.AfAWochen, IIF(PrListKdArti.AfAundBasisRWausPrList = 1 AND KdArti.BasisRWPrListKdArtiID > 0, KdArti.AfaWochen, _IT84508.AfaWochen) AS AfAWochen_ForReal */
FROM _IT84508
JOIN RwConfig ON _IT84508.RWBez = RwConfig.RwConfigBez
JOIN Kunden ON Kunden.RWConfigID = RwConfig.ID
JOIN KdArti WITH (UPDLOCK) ON KdArti.KundenID = Kunden.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN KdArti AS PrListKdArti ON KdArti.BasisRWPrListKdArtiID = PrListKdArti.ID
WHERE Kunden.FirmaID = (SELECT ID FROM Firma WHERE SuchCode = N'FA14')
  AND Kunden.[Status] = N'A'
  AND Kunden.AdrArtID = 1 /* Kunde */
  AND KdArti.AfaWochen != IIF(PrListKdArti.AfAundBasisRWausPrList = 1 AND KdArti.BasisRWPrListKdArtiID > 0, KdArti.AfaWochen, _IT84508.AfaWochen);

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE KdArti SET AfaWochen = [@KdArti].AfaWochen
    FROM @KdArti
    WHERE [@KdArti].KdArtiID = KdArti.ID;
  
  COMMIT;
END TRY
BEGIN CATCH
  SET @Message = ERROR_MESSAGE();
  SET @Severity = ERROR_SEVERITY();
  SET @State = ERROR_STATE();
  
  IF XACT_STATE() != 0
    ROLLBACK TRANSACTION;
  
  RAISERROR(@Message, @Severity, @State) WITH NOWAIT;
END CATCH;

/* Step 1b - Write RepQueue-Entries for synchronization with SDC-DB's           */
/*           this is done in a loop of 1.000 entries to prevent blocking        */

WHILE (SELECT COUNT(*) FROM @KdArti WHERE RepQueueDone = 0) > 0
BEGIN

  BEGIN TRY
    BEGIN TRANSACTION;

      DELETE FROM @KdArtiRep;
    
      INSERT INTO RepQueue (Typ, TableName, TableID, ApplicationID, SdcDevID, Priority)
      OUTPUT inserted.TableID INTO @KdArtiRep (KdArtiID)
      SELECT N'UPDATE', N'KDARTI', KdArtiInsert.KdArtiID, N'AdvanTex.exe', SdcDev.ID, 90015
      FROM (
        SELECT TOP 1000 *
        FROM @KdArti
        WHERE RepQueueDone = 0
      ) AS KdArtiInsert
      CROSS JOIN (
        SELECT SdcDev.ID
        FROM SdcDev
        WHERE SdcDev.ID > -1
          AND SdcDev.IsTriggerDest = 1
      ) AS SdcDev;

      UPDATE @KdArti SET RepQueueDone = 1
      WHERE KdArtiID IN (SELECT DISTINCT KdArtiID FROM @KdArtiRep);

      SET @Message = N'1000 RepQueue-Entries written'
      RAISERROR(@Message, 1, 0) WITH NOWAIT;
    
    COMMIT;
  END TRY
  BEGIN CATCH
    SET @Message = ERROR_MESSAGE();
    SET @Severity = ERROR_SEVERITY();
    SET @State = ERROR_STATE();
    
    IF XACT_STATE() != 0
      ROLLBACK TRANSACTION;
    
    RAISERROR(@Message, @Severity, @State) WITH NOWAIT;
  END CATCH;

END;

GO

/* Step 2 - Set AfaWochen for price lists                                       */
/*          only if all customers with this price list have the same RW-config  */

DECLARE @KdArti TABLE (
  KdArtiID int PRIMARY KEY CLUSTERED,
  AfaWochen int
);

INSERT INTO @KdArti (KdArtiID, AfaWochen)
SELECT KdArti.ID AS KdArtiID, _IT84508.AfaWochen AS AfAWochen
/* SELECT PrList.KdNr, PrList.Name1 AS Preisliste, Artikel.ArtikelNr, Artikel.ArtikelBez AS Artikelbezeichnung, KdArti.Variante, KdArti.AfaWochen, _IT84508.AfAWochen */
FROM _IT84508
JOIN RwConfig ON _IT84508.RWBez = RwConfig.RwConfigBez
JOIN Kunden AS PrList ON PrList.RWConfigID = RwConfig.ID
JOIN KdArti WITH (UPDLOCK) ON KdArti.KundenID = PrList.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
WHERE PrList.FirmaID = (SELECT ID FROM Firma WHERE SuchCode = N'FA14')
  AND PrList.AdrArtID = 5 /* Preisliste */
  AND PrList.[Status] = N'A'
  AND KdArti.AfaWochen != _IT84508.AfAWochen
  AND NOT EXISTS (
    SELECT Kunden.*
    FROM KundPrLi
    JOIN Kunden ON KundPrLi.KundenID = Kunden.ID
    WHERE KundPrLi.PrListKundenID = PrList.ID
      AND Kunden.RWConfigID != RwConfig.ID
  );

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE KdArti SET AfaWochen = [@KdArti].AfaWochen
    FROM @KdArti
    WHERE [@KdArti].KdArtiID = KdArti.ID;

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

UPDATE KdArti SET AfaWochen = PrListKdArti.AfaWochen
FROM KdArti
JOIN KdArti AS PrListKdArti ON KdArti.BasisRWPrListKdArtiID = PrListKdArti.ID
WHERE PrListKdArti.AfAundBasisRWausPrList = 1
  AND KdArti.AfaWochen != PrListKdArti.AfaWochen;

GO

/* Step 3 - Set suggested value for new customer articles at the customer level */

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE Kunden SET AfaWochen = _IT84508.AfAWochen
    FROM _IT84508
    JOIN RwConfig ON _IT84508.RWBez = RwConfig.RwConfigBez
    JOIN Kunden ON Kunden.RWConfigID = RwConfig.ID
    WHERE Kunden.FirmaID = (SELECT ID FROM Firma WHERE SuchCode = N'FA14')
      AND Kunden.[Status] = N'A'
      AND Kunden.AdrArtID = 1 /* Kunde */
      AND Kunden.AfaWochen != _IT84508.AfAWochen;
  
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

SET CONTEXT_INFO 0x0; /* AdvanTex-Trigger für RepQueue aktivieren */
GO