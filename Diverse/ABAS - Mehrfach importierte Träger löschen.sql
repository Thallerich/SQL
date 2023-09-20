SET NOCOUNT ON;
GO

DROP TABLE IF EXISTS #TraegerDelete;
GO

CREATE TABLE #TraegerDelete (
  TraegerID int PRIMARY KEY CLUSTERED
);

GO

INSERT INTO #TraegerDelete (TraegerID)
SELECT TraegerID
FROM (
  SELECT Traeger.ID AS TraegerID, Traeger.PersNr, Traeger.Nachname, Traeger.Vorname, RANK() OVER (PARTITION BY Traeger.PersNr, Traeger.Nachname, Traeger.Vorname ORDER BY Traeger.ID ASC) AS SortRank
  FROM Traeger
  WHERE Traeger.VsaID = 6141636
    AND NOT EXISTS (
      SELECT TraeArti.*
      FROM TraeArti
      WHERE TraeArti.TraegerID = Traeger.ID
    )
    AND Traeger.[Status] = N'A'
) x
WHERE x.SortRank > 1;

GO

DECLARE @currowcount int = 1, @totalrowcount int = 0, @maxrowcount int, @msg nvarchar(100);

SELECT @maxrowcount = COUNT(TraegerID) FROM #TraegerDelete;

WHILE @currowcount > 0
BEGIN
  BEGIN TRY
    BEGIN TRANSACTION;
    
      DELETE TOP (1000) FROM Traeger
      WHERE ID IN (
        SELECT TraegerID FROM #TraegerDelete
      );

      SELECT @currowcount = @@ROWCOUNT, @totalrowcount += @@ROWCOUNT;
      SELECT @msg = N'Deleted ' + FORMAT(@totalrowcount, N'N0', N'de-AT') + ' wearers out of ' + FORMAT(@maxrowcount, N'N0', N'de-AT') + N' total!';
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

  WAITFOR DELAY N'00:00:01';
END;

GO

DROP TABLE #TraegerDelete;
GO