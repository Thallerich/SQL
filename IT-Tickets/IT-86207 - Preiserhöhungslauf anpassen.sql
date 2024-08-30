SET NOCOUNT ON;
SET XACT_ABORT ON;

GO

DECLARE @Vertrag TABLE (
  VertragID int PRIMARY KEY CLUSTERED
);

DECLARE @msg nvarchar(max);

INSERT INTO @Vertrag (VertragID)
SELECT Vertrag.ID
FROM Vertrag
JOIN Kunden ON Vertrag.KundenID = Kunden.ID
JOIN Holding ON Kunden.HoldingID = Holding.ID
JOIN PrLauf ON Vertrag.PrLaufID = PrLauf.ID
WHERE Holding.Holding IN (N'VOES', N'VOESAN', N'VOESLE')
  AND PrLauf.Code != N'S'
  AND Kunden.AdrArtID = 1;

SET @msg = FORMAT(GETDATE(), N'yyy-MM-dd HH:mm:ss') + N': ' + FORMAT(@@ROWCOUNT, N'G', N'de-AT') + N' customer contracts needing update!';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

INSERT INTO @Vertrag (VertragID)
SELECT Vertrag.ID
FROM Vertrag
JOIN Kunden ON Vertrag.KundenID = Kunden.ID
JOIN PrLauf ON Vertrag.PrLaufID = PrLauf.ID
WHERE PrLauf.Code != N'S'
  AND Kunden.AdrArtID = 5
  AND (
    EXISTS (
      SELECT KdArti.*
      FROM KdArti
      JOIN Kunden ON KdArti.KundenID = Kunden.ID
      JOIN Holding ON Kunden.HoldingID = Holding.ID
      JOIN KdArti AS PrListKdArti ON KdArti.LeasPreisPrListKdArtiID = PrListKdArti.ID
      JOIN Kunden AS PrListKunden ON PrListKdArti.KundenID = PrListKunden.ID
      WHERE PrListKunden.ID = Vertrag.KundenID
        AND Holding.Holding IN (N'VOES', N'VOESAN', N'VOESLE')
        AND Kunden.AdrArtID = 1
        AND KdArti.LeasPreisPrListKdArtiID > 0
    )
    OR EXISTS (
      SELECT KdArti.*
      FROM KdArti
      JOIN Kunden ON KdArti.KundenID = Kunden.ID
      JOIN Holding ON Kunden.HoldingID = Holding.ID
      JOIN KdArti AS PrListKdArti ON KdArti.WaschPreisPrListKdArtiID = PrListKdArti.ID
      JOIN Kunden AS PrListKunden ON PrListKdArti.KundenID = PrListKunden.ID
      WHERE PrListKunden.ID = Vertrag.KundenID
        AND Holding.Holding IN (N'VOES', N'VOESAN', N'VOESLE')
        AND Kunden.AdrArtID = 1
        AND KdArti.WaschPreisPrListKdArtiID > 0
    )
    OR EXISTS (
      SELECT KdArti.*
      FROM KdArti
      JOIN Kunden ON KdArti.KundenID = Kunden.ID
      JOIN Holding ON Kunden.HoldingID = Holding.ID
      JOIN KdArti AS PrListKdArti ON KdArti.SondPreisPrListKdArtiID = PrListKdArti.ID
      JOIN Kunden AS PrListKunden ON PrListKdArti.KundenID = PrListKunden.ID
      WHERE PrListKunden.ID = Vertrag.KundenID
        AND Holding.Holding IN (N'VOES', N'VOESAN', N'VOESLE')
        AND Kunden.AdrArtID = 1
        AND KdArti.SondPreisPrListKdArtiID > 0
    )
    OR EXISTS (
      SELECT KdArti.*
      FROM KdArti
      JOIN Kunden ON KdArti.KundenID = Kunden.ID
      JOIN Holding ON Kunden.HoldingID = Holding.ID
      JOIN KdArti AS PrListKdArti ON KdArti.VkPreisPrListKdArtiID = PrListKdArti.ID
      JOIN Kunden AS PrListKunden ON PrListKdArti.KundenID = PrListKunden.ID
      WHERE PrListKunden.ID = Vertrag.KundenID
        AND Holding.Holding IN (N'VOES', N'VOESAN', N'VOESLE')
        AND Kunden.AdrArtID = 1
        AND KdArti.VkPreisPrListKdArtiID > 0
    )
  );

SET @msg = FORMAT(GETDATE(), N'yyy-MM-dd HH:mm:ss') + N': ' + FORMAT(@@ROWCOUNT, N'G', N'de-AT') + N' price list contracts needing update!';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE Vertrag SET PrLaufID = (SELECT PrLauf.ID FROM PrLauf WHERE PrLauf.Code = N'S'), UserID_ = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST')
    WHERE ID IN (SELECT VertragID FROM @Vertrag);

    SET @msg = FORMAT(GETDATE(), N'yyy-MM-dd HH:mm:ss') + N': ' + FORMAT(@@ROWCOUNT, N'G', N'de-AT') + N' contracts (customer or price list) have been set to price increase run "S - Sondertermin"!';
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