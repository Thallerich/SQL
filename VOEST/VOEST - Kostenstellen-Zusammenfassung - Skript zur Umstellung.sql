DROP TABLE IF EXISTS #AbteilCombine;
GO

SELECT Abteil.ID AS AbteilID_Old,
  CAST(NULL AS int) AS AbteilID_Neu,
  [Kostenstelle neu] = Abteil.Bez,
  Abteil.Code,
  Abteil.KundenID
INTO #AbteilCombine
FROM Abteil
JOIN Kunden ON Abteil.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
WHERE Kunden.KdNr IN (272376, 271583, 272353)
  AND (Abteil.Bez = '-' OR TRY_CAST(Abteil.Bez AS bigint) IS NOT NULL);

GO

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = UPPER(REPLACE(ORIGINAL_LOGIN(), N'SAL\', N'')));

DECLARE @AbteilNew TABLE (
  AbteilID int,
  Abteilung nvarchar(20) COLLATE Latin1_General_CS_AS
);

BEGIN TRY
  BEGIN TRANSACTION;

    UPDATE Abteil SET Abteilung = Abteil.Abteilung + N'***'
    FROM (
      SELECT DISTINCT KundenID, [Kostenstelle neu] AS Abteilung
      FROM #AbteilCombine
    ) AS x
    WHERE x.KundenID = Abteil.KundenID
      AND x.Abteilung = Abteil.Abteilung
      AND Abteil.[Status] = 'I';
  
    INSERT INTO Abteil (KundenID, Abteilung, Bez, [Status], Code, AnlageUserID_, UserID_)
    OUTPUT inserted.ID, inserted.Abteilung
    INTO @AbteilNew
    SELECT DISTINCT KundenID, [Kostenstelle neu] AS Abteilung, [Kostenstelle neu] AS Bez, N'A' AS [Status], Code, @userid AS AnlageUserID_, @userid AS UserID_
    FROM #AbteilCombine
    WHERE NOT EXISTS (
      SELECT Abteil.*
      FROM Abteil
      WHERE Abteil.KundenID = #AbteilCombine.KundenID
        AND Abteil.Abteilung = #AbteilCombine.[Kostenstelle neu]
    );

    UPDATE #AbteilCombine SET AbteilID_Neu = [@AbteilNew].AbteilID
    FROM @AbteilNew
    WHERE [@AbteilNew].Abteilung = #AbteilCombine.[Kostenstelle neu];

    UPDATE Traeger SET AbteilID = #AbteilCombine.AbteilID_Neu, UserID_ = @userid
    FROM #AbteilCombine
    WHERE Traeger.AbteilID = #AbteilCombine.AbteilID_Old;

    UPDATE Vsa SET AbteilID = #AbteilCombine.AbteilID_Neu, UserID_ = @userid
    FROM #AbteilCombine
    WHERE Vsa.AbteilID = #AbteilCombine.AbteilID_Old;

/*     UPDATE LsPo SET AbteilID = #AbteilCombine.AbteilID_Neu, UserID_ = @userid
    FROM #AbteilCombine, LsKo
    WHERE LsPo.AbteilID = #AbteilCombine.AbteilID_Old
      AND LsPo.LsKoID = LsKo.ID
      AND LsKo.[Status] < 'W'
      AND LsPo.RechPoID = -1; */

    UPDATE VsaLeas SET AbteilID = #AbteilCombine.AbteilID_Neu, UserID_ = @userid
    FROM #AbteilCombine
    WHERE VsaLeas.AbteilID = #AbteilCombine.AbteilID_Old;

    UPDATE Schrank SET Schrank.AbteilID = #AbteilCombine.AbteilID_Neu, UserID_ = @userid
    FROM #AbteilCombine
    WHERE Schrank.AbteilID = #AbteilCombine.AbteilID_Old;

    UPDATE VsaAnf SET VsaAnf.AbteilID = #AbteilCombine.AbteilID_Neu, UserID_ = @userid
    FROM #AbteilCombine
    WHERE VsaAnf.AbteilID = #AbteilCombine.AbteilID_Old;

    UPDATE Abteil SET [Status] = 'I', UserID_ = @userid
    FROM #AbteilCombine
    WHERE Abteil.ID = #AbteilCombine.AbteilID_Old;
  
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