DECLARE @Customer TABLE (
  CustomerID int,
  CustomerNumber int
);

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

INSERT INTO @Customer (CustomerNumber)
VALUES (10006236), (1132), (1265), (1270), (2025), (2029), (10006289), (16031), (2290), (2288), (5005), (5016), (5014), (5010), (10006290), (19111), (6070), (2035), (7020), (10006291), (7370), (7371), (8060), (10006235), (10006292), (11140), (11150), (10006237), (11156), (12020), (12077), (10006238), (13320), (13330), (16030), (14030), (15002), (15075), (16035), (16041), (24090), (16151), (18030), (10006239), (20010), (20025), (20015), (19068), (22025), (22013), (10005948), (10006240), (10006683), (10006293), (30092), (25100), (30075), (26007), (21144), (24041), (12008);

UPDATE @Customer SET CustomerID = Kunden.ID
FROM Kunden
WHERE Kunden.KdNr = [@Customer].CustomerNumber;

DROP TABLE IF EXISTS #TmpKdBerUpdate;

SELECT KdBer.ID AS KdBerID,
  RabattNeu = 
    CASE Bereich.Bereich
      WHEN N'BK' THEN 4.75
      WHEN N'FW' THEN 3.75
      WHEN N'PWS' THEN 1.25
    END
INTO #TmpKdBerUpdate
FROM KdBer WITH (UPDLOCK, ROWLOCK)
JOIN Bereich ON KdBer.BereichID = Bereich.ID
JOIN @Customer ON KdBer.KundenID = [@Customer].CustomerID
WHERE Bereich.Bereich IN (N'BK', N'FW', N'PWS');

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE KdBer SET RabattLeasing = #TmpKdBerUpdate.RabattNeu, RabattWasch = #TmpKdBerUpdate.RabattNeu, UserID_ = @userid
    FROM #TmpKdBerUpdate
    WHERE KdBer.ID = #TmpKdBerUpdate.KdBerID;
  
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