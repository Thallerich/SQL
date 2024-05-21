DROP TABLE IF EXISTS #FakFreqFix;
GO

CREATE TABLE #FakFreqFix (
  RechKoID int PRIMARY KEY CLUSTERED NOT NULL,
  FakFreqID int NOT NULL
);

GO

INSERT INTO #FakFreqFix (RechKoID, FakFreqID)
SELECT RechKo.ID AS RechKoID,
  KdFakFreqID = (
    SELECT TOP 1 KdBer.FakFreqID
    FROM KdBer
    JOIN RechPo ON RechPo.KdBerID = KdBer.ID
    WHERE RechPo.RechKoID = RechKo.ID
    GROUP BY KdBer.FakFreqID
    ORDER BY COUNT(DISTINCT KdBer.ID) DESC
  )
FROM RechKo
JOIN Kunden ON RechKo.KundenID = Kunden.ID
WHERE Kunden.DrLaufID = (SELECT ID FROM DrLauf WHERE Bez = N'HOGAST alle')
  AND RechKo.Status < N'N';

GO

BEGIN TRY
  BEGIN TRANSACTION;

  UPDATE RechKo SET FakFreqID = #FakFreqFix.FakFreqID
  FROM #FakFreqFix
  WHERE #FakFreqFix.RechKoID = RechKo.ID
    AND #FakFreqFix.FakFreqID != RechKo.FakFreqID;

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