DECLARE @RechPo TABLE (
  RechPoID int PRIMARY KEY
);

INSERT INTO @RechPo (RechPoID)
SELECT DISTINCT RechPo.ID
FROM RechPo
JOIN RechKo ON RechPo.RechKoID = RechKo.ID
JOIN TeilSoFa ON TeilSoFa.RechPoID = RechPo.ID
WHERE RechKo.Status = N'A'
  AND TeilSoFa.SoFaArt = N'R'
  AND RechPo.Anlage_ > N'2022-11-13 00:00:00';

BEGIN TRY
  BEGIN TRANSACTION;

    UPDATE TeilSoFa SET [Status] = N'L', RechPoID = -1
    WHERE RechPoID IN (SELECT RechPoID FROM @RechPo);

    DELETE FROM RechPo
    WHERE ID IN (SELECT RechPoID FROM @RechPo);

    UPDATE RwConfPo SET RwRechPoProTeil = 1
    WHERE RwRechPoProTeil = 0
      AND RwConfigID > 0;
  
  COMMIT;
END TRY
BEGIN CATCH
  DECLARE @Message varchar(MAX) = ERROR_MESSAGE();
  DECLARE @Severity int = ERROR_SEVERITY();
  DECLARE @State smallint = ERROR_STATE();

  IF XACT_STATE() != 0
    ROLLBACK TRANSACTION;
 
  RAISERROR(@Message, @Severity, @State);
END CATCH;