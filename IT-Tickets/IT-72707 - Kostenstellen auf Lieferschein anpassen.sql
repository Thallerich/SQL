DECLARE @kdnr int = 10003474;
DECLARE @ksst nvarchar(20) = N'500';

DECLARE @abteilid int;
DECLARE @ls TABLE (
  LsNr int PRIMARY KEY CLUSTERED
);

INSERT INTO @ls (LsNr)
VALUES (48902667), (48962713), (48975438), (48976892), (48997762), (48997929);

SELECT @abteilid = Abteil.ID
FROM Abteil
JOIN Kunden ON Abteil.KundenID = Kunden.ID
JOIN Vsa ON Vsa.KundenID = Kunden.ID
JOIN LsKo ON LsKo.VsaID = Vsa.ID
WHERE Kunden.KdNr = @kdnr
  AND Abteil.Abteilung = @ksst
  AND LsKo.LsNr IN (SELECT LsNr FROM @ls);

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE LsPo SET AbteilID = @abteilid
    WHERE LsPo.LsKoID IN (
      SELECT LsKo.ID
      FROM LsKo
      WHERE LsKo.LsNr IN (SELECT LsNr FROM @ls)
    );
  
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