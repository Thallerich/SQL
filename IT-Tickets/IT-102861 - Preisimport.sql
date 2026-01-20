DROP TABLE IF EXISTS #PriceUpdate;

GO

SELECT KdArti.ID AS KdArtiID, KdArti.WaschPreis, _IT102861.Waschpreis AS WaschpreisNeu, KdArti.LeasPreis, _IT102861.LeasPreis AS LeaspreisNeu, KdArti.WaschPreisPrListKdArtiID, KdArti.LeasPreisPrListKdArtiID, CAST(IIF(KundPrLi.ID IS NOT NULL, 1, 0) AS bit) AS HatPreisliste
INTO #PriceUpdate
FROM KdArti WITH (UPDLOCK)
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN _IT102861 ON Kunden.KdNr = _IT102861.KdNr AND Artikel.ArtikelNr = _IT102861.ArtikelNr AND KdArti.Variante = _IT102861.Variante
LEFT JOIN KundPrLi ON Kunden.ID = KundPrLi.KundenID
WHERE (KdArti.WaschPreis != _IT102861.WaschPreis OR KdArti.LeasPreis != _IT102861.LeasPreis);

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = UPPER(REPLACE(ORIGINAL_LOGIN(), N'SAL\', N'')));
DECLARE @msg nvarchar(max);

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
  
    /* TODO: Preislisten berücksichtigen! */

    UPDATE KdArti SET WaschPreis = #PriceUpdate.WaschpreisNeu, LeasPreis = #PriceUpdate.LeaspreisNeu, UserID_ = @userid
    OUTPUT inserted.ID, inserted.LeasPreis, inserted.WaschPreis, inserted.SonderPreis, inserted.VkPreis, inserted.BasisRestwert, inserted.LeasPreisAbwAbWo
    INTO @Archive (KdArtiID, LeasPreis, WaschPreis, SonderPreis, VKPreis, BasisRestwert, LeasPreisAbwAbWo)
    FROM #PriceUpdate
    WHERE KdArti.ID = #PriceUpdate.KdArtiID;

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

DROP TABLE #PriceUpdate;

GO