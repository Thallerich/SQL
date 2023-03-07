DECLARE @PreisChanged TABLE (
  KdArtiID int,
  LeasPreis money,
  WaschPreis money,
  SonderPreis money,
  VKPreis money,
  BasisRestwert money,
  LeasPreisAbwAbWo money
);

DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE MitarbeiUser = N'THALST');

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE KdArti SET VKPreis = BasisRestwert
    OUTPUT inserted.ID, inserted.LeasPreis, inserted.WaschPreis, inserted.SonderPreis, inserted.VkPreis, inserted.BasisRestwert, inserted.LeasPreisAbwAbWo
    INTO @PreisChanged (KdArtiID, LeasPreis, WaschPreis, SonderPreis, VKPreis, BasisRestwert, LeasPreisAbwAbWo)
    FROM Kunden
    WHERE KdArti.KundenID = Kunden.ID
      AND Kunden.KdNr IN (1000000128, 1000000130)
      AND Kunden.AdrArtID = (SELECT ID FROM AdrArt WHERE AdrartBez = N'Preisliste')
      AND KdArti.BasisRestwert != KdArti.VkPreis;

    INSERT INTO PrArchiv (KdArtiID, LeasPreis, WaschPreis, SonderPreis, VKPreis, BasisRestwert, LeasPreisAbwAbWo, MitarbeiID, Datum, Aktivierungszeitpunkt, AnlageUserID_, UserID_)
    SELECT KdArtiID, LeasPreis, WaschPreis, SonderPreis, VKPreis, BasisRestwert, LeasPreisAbwAbWo, @UserID, CAST(GETDATE() AS date), CAST(GETDATE() AS date), @UserID, @UserID
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