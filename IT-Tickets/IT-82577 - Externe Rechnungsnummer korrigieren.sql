DROP TABLE IF EXISTS #RechFix;
GO

CREATE TABLE #RechFix (
  RechKoID int,
  RechNr int,
  ExtRechNr varchar(12),
  RechDat date,
  Art char(1)
);

GO

INSERT INTO #RechFix (RechKoID, RechNr, ExtRechNr, RechDat, Art)
SELECT RechKo.ID, RechKo.RechNr, RechKo.ExtRechNr, RechKo.RechDat, RechKo.Art
FROM RechKo
WHERE RechKo.FirmaID = (SELECT Firma.ID FROM Firma WHERE Firma.SuchCode = N'SMRS')
  AND RechKo.RechDat >= N'2024-04-01'
  AND RechKo.ExtRechNr NOT LIKE N'ST-____-____'
  AND RechKo.ExtRechNr NOT LIKE N'R-____-____';

GO

UPDATE #RechFix SET ExtRechNr = N'R-' + RIGHT(REPLICATE(N'0', 4) + CAST(NEXT VALUE FOR NextID_RECHNRKR_R_SMRS2024 AS varchar), 4) + N'-2024'
WHERE Art = 'R';
UPDATE #RechFix SET ExtRechNr = N'ST-' + RIGHT(REPLICATE(N'0', 4) + CAST(NEXT VALUE FOR NextID_RECHNRKR_G_SMRS2024 AS varchar), 4) + N'-2024'
WHERE Art = 'G';

GO

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE RechKo SET ExtRechNr = #RechFix.ExtRechNr
    FROM #RechFix
    WHERE #RechFix.RechKoID = RechKo.ID;
  
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

DROP TABLE #RechFix;
GO