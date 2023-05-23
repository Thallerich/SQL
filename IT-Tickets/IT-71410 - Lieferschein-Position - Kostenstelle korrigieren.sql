DROP TABLE IF EXISTS #LsKsStKorrektur;
GO

CREATE TABLE #LsKsStKorrektur (
  LsPoID int PRIMARY KEY CLUSTERED,
  AbteilID int
);

GO

DECLARE @customer int = 272628;
DECLARE @vsa int = 19;

DECLARE @sqltext nvarchar(max);

SET @sqltext = N'
  INSERT INTO #LsKsStKorrektur (LsPoID, AbteilID)
  SELECT DISTINCT LsPo.ID, COALESCE(VsaAnf.AbteilID, Vsa.AbteilID) AS AbteilID
  FROM LsPo
  JOIN LsKo ON LsPo.LsKoID = LsKo.ID
  JOIN Vsa ON LsKo.VsaID = Vsa.ID
  JOIN Kunden ON Vsa.KundenID = Kunden.ID
  LEFT JOIN VsaAnf ON VsaAnf.VsaID = Vsa.ID AND VsaAnf.KdArtiID = LsPo.KdArtiID
  WHERE Kunden.KdNr = @customer
    AND Vsa.VsaNr = @vsa
    AND LsPo.RechPoID = -1
    AND LsPo.AbteilID != COALESCE(VsaAnf.AbteilID, Vsa.AbteilID);
';

EXEC sp_executesql @sqltext, N'@customer int, @vsa int', @customer, @vsa;

GO

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE LsPo SET AbteilID = #LsKsStKorrektur.AbteilID
    FROM #LsKsStKorrektur
    WHERE #LsKsStKorrektur.LsPoID = LsPo.ID;
  
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