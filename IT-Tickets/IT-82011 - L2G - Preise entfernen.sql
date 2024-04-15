DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

DECLARE @PreisChanged TABLE (
  KdArtiID int,
  LeasPreis money,
  WaschPreis money,
  SonderPreis money,
  VKPreis money,
  BasisRestwert money,
  LeasPreisAbwAbWo money,
  LeasPreisPrListKdArtiID int,
  WaschPreisPrListKdArtiID int,
  SondPreisPrListKdArtiID int,
  VkPreisPrListKdArtiID int,
  BasisRWPrListKdArtiID int
);

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE KdArti SET WaschPreis = 0, LeasPreis = 0, SonderPreis = 0
    OUTPUT inserted.ID, inserted.LeasPreis, inserted.WaschPreis, inserted.SonderPreis, inserted.VkPreis, inserted.BasisRestwert, inserted.LeasPreisAbwAbWo, inserted.LeasPreisPrListKdArtiID, inserted.WaschPreisPrListKdArtiID, inserted.SondPreisPrListKdArtiID, inserted.VkPreisPrListKdArtiID, inserted.BasisRWPrListKdArtiID
    INTO @PreisChanged (KdArtiID, LeasPreis, WaschPreis, SonderPreis, VKPreis, BasisRestwert, LeasPreisAbwAbWo, LeasPreisPrListKdArtiID, WaschPreisPrListKdArtiID, SondPreisPrListKdArtiID, VkPreisPrListKdArtiID, BasisRWPrListKdArtiID)
    FROM KdArti
    WHERE KdArti.KundenID IN (SELECT Kunden.ID FROM Kunden WHERE Kunden.KdNr IN (10006760, 10006208))
      AND (KdArti.WaschPreis != 0 OR KdARti.LeasPreis != 0 OR KdArti.SonderPreis != 0);

    INSERT INTO PrArchiv (KdArtiID, Datum, LeasPreis, WaschPreis, SonderPreis, VKPreis, BasisRestwert, LeasPreisAbwAbWo, MitarbeiID, Aktivierungszeitpunkt, LeasPreisPrListKdArtiID, WaschPreisPrListKdArtiID, SondPreisPrListKdArtiID, VkPreisPrListKdArtiID, BasisRWPrListKdArtiID, AnlageUserID_, UserID_)
    SELECT KdArtiID, CAST(GETDATE() AS date) AS Datum, LeasPreis, WaschPreis, SonderPreis, VKPreis, BasisRestwert, LeasPreisAbwAbWo, @UserID AS MitarbeiID, GETDATE() AS Aktivierungszeitpunkt, LeasPreisPrListKdArtiID, WaschPreisPrListKdArtiID, SondPreisPrListKdArtiID, VkPreisPrListKdArtiID, BasisRWPrListKdArtiID, @UserID AS AnlageUserID_, @UserID AS UserID_
    FROM @PreisChanged;

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