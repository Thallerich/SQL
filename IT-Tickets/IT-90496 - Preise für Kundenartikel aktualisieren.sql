SET CONTEXT_INFO 0x1; /* AdvanTex-Trigger für RepQueue deaktivieren */
GO

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

DECLARE @Archive TABLE (
  KdArtiID int,
  LeasPreis money,
  WaschPreis money,
  SonderPreis money,
  VKPreis money,
  BasisRestwert money,
  LeasPreisAbwAbWo money
);

BEGIN TRY
  BEGIN TRANSACTION;

    /* Bestehende Kundenartikel aktualisieren */

    UPDATE KdArti SET WaschPreis = ImportList.Waschpreis, UserID_ = @userid
    OUTPUT inserted.ID, inserted.LeasPreis, inserted.WaschPreis, inserted.SonderPreis, inserted.VkPreis, inserted.BasisRestwert, inserted.LeasPreisAbwAbWo
    INTO @Archive (KdArtiID, LeasPreis, WaschPreis, SonderPreis, VKPreis, BasisRestwert, LeasPreisAbwAbWo)
    FROM (
      SELECT Kunden.ID AS KundenID, Artikel.ID AS ArtikelID, _IT90496.Waschpreis
      FROM Salesianer.dbo._IT90496
      JOIN Kunden ON _IT90496.KdNr = Kunden.KdNr
      JOIN Artikel ON _IT90496.ArtikelNr = Artikel.ArtikelNr
    ) AS ImportList
    WHERE ImportList.KundenID = KdArti.KundenID AND ImportList.ArtikelID = KdArti.ArtikelID
      AND KdArti.WaschPreis != ImportList.Waschpreis;

    INSERT INTO PrArchiv (KdArtiID, Datum, LeasPreis, WaschPreis, SonderPreis, VKPreis, BasisRestwert, LeasPreisAbwAbWo, MitarbeiID, Aktivierungszeitpunkt, AnlageUserID_, UserID_)
    SELECT KdArtiID, CAST(GETDATE() AS date) AS Datum, LeasPreis, WaschPreis, SonderPreis, VKPreis, BasisRestwert, LeasPreisAbwAbWo, @userid, GETDATE(), @userid, @userid
    FROM @Archive;
  
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

SET CONTEXT_INFO 0x0; /* AdvanTex-Trigger für RepQueue deaktivieren */
GO