SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

DECLARE @targetwaeid int;
DECLARE @userid int;
DECLARE @msg nvarchar(max);
DECLARE @errormsg nvarchar(max), @errorseverity int, @errorstate smallint;

SELECT @targetwaeid = Wae.ID
FROM Wae
WHERE Wae.Code = N'EUR';

SELECT @userid = Mitarbei.ID
FROM Mitarbei
WHERE Mitarbei.UserName = N'THALST';

DECLARE @PrList TABLE (
  PrListID int
);

INSERT INTO @PrList (PrListID)
SELECT Kunden.ID
FROM Kunden
WHERE Kunden.KdNr IN (1000000143, 1000000135, 1000000046, 1000000050)
  AND Kunden.AdrArtID = 5;

DECLARE @PosPrice TABLE (
  KdArtiID int,
  WaschPreis_old money,
  WaschPreis_new money,
  LeasPreis_old money,
  LeasPreis_new money,
  SonderPreis_old money,
  SonderPreis_new money,
  VKPreis_old money,
  VKPreis_new money,
  BasisRestwert_old money,
  BasisRestwert_new money
);

BEGIN TRY
  BEGIN TRANSACTION;
  
    UPDATE Kunden SET VertragWaeID = @targetwaeid, RechWaeID = @targetwaeid, UserID_ = @userid
    WHERE ID IN (SELECT PrListID FROM @PrList)
      AND (VertragWaeID != @targetwaeid OR RechWaeID != @targetwaeid);

    SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': ' + FORMAT(@@ROWCOUNT, N'N0') + N' price lists have had their currency field updated!';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    UPDATE KdArti SET WaschPreis = ROUND(WaschPreis, 2), LeasPreis = ROUND(LeasPreis, 2), SonderPreis = ROUND(SonderPreis, 2), VKPreis = ROUND(VKPreis, 2), BasisRestwert = ROUND(BasisRestwert, 2), UserID_ = @userid
    OUTPUT inserted.ID, deleted.WaschPreis, inserted.WaschPreis, deleted.LeasPreis, inserted.LeasPreis, deleted.SonderPreis, inserted.SonderPreis, deleted.VKPreis, inserted.VKPreis, deleted.BasisRestwert, inserted.BasisRestwert
    INTO @PosPrice (KdArtiID, WaschPreis_old, WaschPreis_new, LeasPreis_old, LeasPreis_new, SonderPreis_old, SonderPreis_new, VKPreis_old, VKPreis_new, BasisRestwert_old, BasisRestwert_new)
    WHERE KdArti.KundenID IN (SELECT PrListID FROM @PrList);
  
    SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': ' + FORMAT(@@ROWCOUNT, N'N0') + N' price list positions have been rounded!';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    INSERT INTO PrArchiv (KdArtiID, Datum, WaschPreis, LeasPreis, SonderPreis, VKPreis, BasisRestwert, MitarbeiID, Aktivierungszeitpunkt, AnlageUserID_, UserID_)
    SELECT KdArtiID, CAST(GETDATE() AS date) AS Datum, WaschPreis_new, LeasPreis_new, SonderPreis_new, VKPreis_new, BasisRestwert_new, @userid AS MitarbeiID, GETDATE() AS Aktivierungszeitpunkt, @userid AS AnlageUserID_, @userid AS UserID_
    FROM @PosPrice
    WHERE (WaschPreis_old != WaschPreis_new OR LeasPreis_old != LeasPreis_new OR SonderPreis_old != SonderPreis_new OR VKPreis_old != VKPreis_new OR BasisRestwert_old != BasisRestwert_new);

    SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N': ' + FORMAT(@@ROWCOUNT, N'N0') + N' price list archive entries have been written!';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

  COMMIT;
END TRY
BEGIN CATCH
  SELECT @errormsg = ERROR_MESSAGE(), @errorseverity = ERROR_SEVERITY(), @errorstate = ERROR_STATE();
  
  IF XACT_STATE() != 0
    ROLLBACK TRANSACTION;
  
  RAISERROR(@errormsg, @errorseverity, @errorstate) WITH NOWAIT;
END CATCH;

GO

SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Kunden.[Status], VertragWae.Code AS Vertragswährung, RechWae.Code AS Rechnungswährung, PrList.KdNr AS Preisliste_Nr
FROM KundPrLi
JOIN Kunden ON KundPrLi.KundenID = Kunden.ID
JOIN Kunden AS PrList ON KundPrLi.PrListKundenID = PrList.ID
JOIN Wae AS VertragWae ON Kunden.VertragWaeID = VertragWae.ID
JOIN Wae AS RechWae ON Kunden.RechWaeID = RechWae.ID
WHERE PrList.KdNr IN (1000000143, 1000000135, 1000000046, 1000000050)
  AND (Kunden.VertragWaeID != PrList.VertragWaeID OR Kunden.RechWaeID != PrList.RechWaeID)
  AND Kunden.[Status] = N'A';

GO