SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

DROP TABLE IF EXISTS #KdArtiSrc;
GO

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');
DECLARE @msg nvarchar(max);

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

DECLARE @ArtikelMap TABLE (
  ArtikelNr_Alt nchar(15) COLLATE Latin1_General_CS_AS,
  ArtikelNr_Neu nchar(15) COLLATE Latin1_General_CS_AS
);

INSERT INTO @ArtikelMap (ArtikelNr_Alt, ArtikelNr_Neu)
VALUES ('GH0200', 'GH0200G'),
       ('GH0100', 'GH0100G'),
       ('GH0246', 'GH0246G'); 


SELECT KdArti.ID AS KdArtiID_Alt, Artikel_Neu.ID AS ArtikelID_Neu
INTO #KdArtiSrc
FROM @ArtikelMap AS ArtikelMap
JOIN Artikel AS Artikel_Alt ON ArtikelMap.ArtikelNr_Alt = Artikel_Alt.ArtikelNr
JOIN Artikel AS Artikel_Neu ON ArtikelMap.ArtikelNr_Neu = Artikel_Neu.ArtikelNr
JOIN KdArti ON KdArti.ArtikelID = Artikel_Alt.ID
JOIN Kunden ON KdArti.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN [Zone] ON Kunden.ZoneID = [Zone].ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
WHERE KdGf.KurzBez = N'MED'
  AND [Zone].ZonenCode = 'SÜD'
  AND Firma.SuchCode = N'FA14'
  AND NOT EXISTS (
    SELECT k.*
    FROM KdArti AS k
    WHERE k.KundenID = KdArti.KundenID
      AND k.Variante = KdArti.Variante
      AND k.ArtikelID = Artikel_Neu.ID
  );

SET @msg = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss') + ': ' + FORMAT(@@ROWCOUNT, N'N0') + ' Kundenartikel anzulegen.';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

BEGIN TRY
  BEGIN TRANSACTION;

    INSERT INTO KdArti (KundenID, ArtikelID, Variante, VariantBez, KdBerID, LiefArtID, WaschPrgID, WebArtikel, KostenlosRPo, LeasPreis, WaschPreis, SonderPreis, VKPreis, BasisRestwert, LeasPreisAbwAbWo, MaxWaschen, AfaWochen, UserID_, AnlageUserID_)
    OUTPUT inserted.ID, inserted.LeasPreis, inserted.WaschPreis, inserted.SonderPreis, inserted.VkPreis, inserted.BasisRestwert, inserted.LeasPreisAbwAbWo, inserted.LeasPreisPrListKdArtiID, inserted.WaschPreisPrListKdArtiID, inserted.SondPreisPrListKdArtiID, inserted.VkPreisPrListKdArtiID, inserted.BasisRWPrListKdArtiID
    INTO @PreisChanged (KdArtiID, LeasPreis, WaschPreis, SonderPreis, VKPreis, BasisRestwert, LeasPreisAbwAbWo, LeasPreisPrListKdArtiID, WaschPreisPrListKdArtiID, SondPreisPrListKdArtiID, VkPreisPrListKdArtiID, BasisRWPrListKdArtiID)
    SELECT KdArti.KundenID, #KdArtiSrc.ArtikelID_Neu AS ArtikelID, KdArti.Variante, KdArti.VariantBez, KdArti.KdBerID, KdArti.LiefArtID, KdArti.WaschPrgID, KdArti.WebArtikel, KdArti.KostenlosRPo, KdArti.LeasPreis, KdArti.WaschPreis, KdArti.SonderPreis, KdArti.VKPreis, KdArti.BasisRestwert, KdArti.LeasPreisAbwAbWo, KdArti.MaxWaschen, KdArti.AfaWochen, @userid AS UserID_, @userid AS AnlageUserID_
    FROM #KdArtiSrc
    JOIN KdArti ON #KdArtiSrc.KdArtiID_Alt = KdArti.ID;

    SET @msg = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss') + ': ' + FORMAT(@@ROWCOUNT, N'N0') + ' Kundenartikel-Datensätze angelegt.';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;

    INSERT INTO PrArchiv (KdArtiID, Datum, LeasPreis, WaschPreis, SonderPreis, VKPreis, BasisRestwert, LeasPreisAbwAbWo, MitarbeiID, Aktivierungszeitpunkt, LeasPreisPrListKdArtiID, WaschPreisPrListKdArtiID, SondPreisPrListKdArtiID, VkPreisPrListKdArtiID, BasisRWPrListKdArtiID, AnlageUserID_, UserID_)
    SELECT KdArtiID, CAST(GETDATE() AS date) AS Datum, LeasPreis, WaschPreis, SonderPreis, VKPreis, BasisRestwert, LeasPreisAbwAbWo, @UserID AS MitarbeiID, GETDATE() AS Aktivierungszeitpunkt, LeasPreisPrListKdArtiID, WaschPreisPrListKdArtiID, SondPreisPrListKdArtiID, VkPreisPrListKdArtiID, BasisRWPrListKdArtiID, @UserID AS AnlageUserID_, @UserID AS UserID_
    FROM @PreisChanged;

    SET @msg = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss') + ': ' + FORMAT(@@ROWCOUNT, N'N0') + ' Preisarchiv-Einträge angelegt.';
    RAISERROR(@msg, 0, 1) WITH NOWAIT;
  
  COMMIT;

  SET @msg = FORMAT(GETDATE(), 'yyyy-MM-dd HH:mm:ss') + ': Fertig!';
  RAISERROR(@msg, 0, 1) WITH NOWAIT;

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