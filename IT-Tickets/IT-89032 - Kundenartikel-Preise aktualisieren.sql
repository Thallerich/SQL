SET CONTEXT_INFO 0x1; /* AdvanTex-Trigger für RepQueue deaktivieren */
GO

/* TODO: Add Code here! */
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

    UPDATE KdArti SET LeasPreis = ImportList.Leasing, WaschPreis = ImportList.Bearbeitung, UserID_ = @userid
    OUTPUT inserted.ID, inserted.LeasPreis, inserted.WaschPreis, inserted.SonderPreis, inserted.VkPreis, inserted.BasisRestwert, inserted.LeasPreisAbwAbWo
    INTO @Archive (KdArtiID, LeasPreis, WaschPreis, SonderPreis, VKPreis, BasisRestwert, LeasPreisAbwAbWo)
    FROM (
      SELECT Kunden.ID AS KundenID, Artikel.ID AS ArtikelID, _IT89032.Variante, _IT89032.Leasing, _IT89032.Bearbeitung
      FROM Salesianer.dbo._IT89032
      JOIN Kunden ON _IT89032.KdNr = Kunden.KdNr
      JOIN Artikel ON _IT89032.ArtikelNr = Artikel.ArtikelNr
      WHERE _IT89032.KdNr != 10003771
    ) AS ImportList
    WHERE ImportList.KundenID = KdArti.KundenID AND ImportList.ArtikelID = KdArti.ArtikelID AND ImportList.Variante = KdArti.Variante
      AND (KdArti.WaschPreis != ImportList.Bearbeitung OR KdArti.LeasPreis != ImportList.Leasing);

    INSERT INTO PrArchiv (KdArtiID, Datum, LeasPreis, WaschPreis, SonderPreis, VKPreis, BasisRestwert, LeasPreisAbwAbWo, MitarbeiID, Aktivierungszeitpunkt, AnlageUserID_, UserID_)
    SELECT KdArtiID, CAST(GETDATE() AS date) AS Datum, LeasPreis, WaschPreis, SonderPreis, VKPreis, BasisRestwert, LeasPreisAbwAbWo, @userid, GETDATE(), @userid, @userid
    FROM @Archive;

    /* Output-Table leeren */
    DELETE FROM @Archive;

    /* Fehlende Kundenartikel anlegen */
  
    INSERT INTO KdArti (KundenID, ArtikelID, KdBerID, Variante, VariantBez, LeasPreis, WaschPreis, PrListKdArtiAlleVariant, AnlageUserID_, UserID_)
    OUTPUT inserted.ID, inserted.LeasPreis, inserted.WaschPreis
    INTO @Archive (KdArtiID, LeasPreis, WaschPreis)
    SELECT Kunden.ID AS KundenID, Artikel.ID AS ArtikelID, KdBer.ID AS KdBerID, _IT89032.Variante, _IT89032.[Varianten-Bezeichnung] AS VariantBez, _IT89032.Leasing AS LeasPreis, _IT89032.Bearbeitung AS WaschPreis, CAST(IIF(_IT89032.Variante = N'-', 1, 0) AS bit) AS PrListKdArtiAlleVariant, @userid AS AnlageUserID_, @userid AS UserID_
    FROM Salesianer.dbo._IT89032
    JOIN Kunden ON _IT89032.KdNr = Kunden.KdNr
    JOIN Artikel ON _IT89032.ArtikelNr = Artikel.ArtikelNr
    JOIN Bereich ON Artikel.BereichID = Bereich.ID
    JOIN KdBer ON KdBer.KundenID = Kunden.ID AND KdBer.BereichID = Bereich.ID AND _IT89032.Produktbereich = Bereich.Bereich
    WHERE NOT EXISTS (
        SELECT PrListKdArti.*
        FROM KdArti AS PrListKdArti
        WHERE PrListKdArti.KundenID = Kunden.ID
          AND PrListKdArti.ArtikelID = Artikel.ID
          AND PrListKdArti.Variante = _IT89032.Variante
      )
      AND Kunden.KdNr != 10003771;

    INSERT INTO PrArchiv (KdArtiID, Datum, LeasPreis, WaschPreis, MitarbeiID, Aktivierungszeitpunkt, AnlageUserID_, UserID_)
    SELECT KdArtiID, CAST(GETDATE() AS date) AS Datum, LeasPreis, WaschPreis, @userid, GETDATE(), @userid, @userid
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