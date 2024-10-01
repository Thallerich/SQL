DECLARE @KdForUpdate TABLE (
  KundenID int PRIMARY KEY CLUSTERED,
  RwNachWochen int
);

INSERT INTO @KdForUpdate (KundenID, RwNachWochen)
SELECT Kunden.ID AS KundenID, Kunden.RWnachWochen
FROM Kunden WITH (UPDLOCK)
JOIN Holding ON Kunden.HoldingID = Holding.ID
WHERE Holding.Holding IN (N'BBGL1', N'BBGL2', N'BBGL3', N'BBGL4', N'BBGL5', N'BBGL6', N'BBGS', N'BBGT', N'BBG', N'BH K2', N'BH K3')
  AND Kunden.RWnachWochen < 9000
  AND Kunden.AdrArtID = 1;

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE Kunden SET RWnachWochen = 9999
    WHERE ID IN (SELECT KundenID FROM @KdForUpdate);
  
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

SELECT [Zone].ZonenCode AS Vertriebszone, Holding.Holding, Holding.Bez AS [Holding-Bezeichnung], Kunden.KdNr, Kunden.SuchCode AS Kunde, [@KdForUpdate].RwNachWochen AS [RW-Faktura nach Wochen - alter Wert], Kunden.RwNachWochen AS [RW-Faktura nach Wochen - neuer Wert]
FROM @KdForUpdate
JOIN Kunden ON [@KdForUpdate].KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID;

GO