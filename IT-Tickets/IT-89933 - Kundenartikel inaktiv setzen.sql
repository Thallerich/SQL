/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ TRUNCATE TABLE _IT95226;                                                                                                  ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SET NOCOUNT ON;
SET XACT_ABORT ON;
GO

DECLARE @KdArti TABLE (
  KdArtiID int PRIMARY KEY CLUSTERED
);

DECLARE @VsaAnf TABLE (
  VsaAnfID int PRIMARY KEY CLUSTERED
);

DECLARE @userid int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');
DECLARE @msg nvarchar(255);

INSERT INTO @KdArti (KdArtiID)
SELECT DISTINCT KdArti.ID
FROM _IT95226
JOIN Kunden ON _IT95226.KdNr = Kunden.KdNr
JOIN Artikel ON _IT95226.ArtikelNr = Artikel.ArtikelNr
JOIN KdArti ON KdArti.KundenID = Kunden.ID AND KdArti.ArtikelID = Artikel.ID AND KdArti.Variante = _IT95226.Variante
WHERE KdArti.[Status] != N'I';

SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - ' + FORMAT(@@ROWCOUNT, N'N0') + N' Kundenartikel gefunden.';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

INSERT INTO @VsaAnf (VsaAnfID)
SELECT Vsaanf.ID
FROM VsaAnf
WHERE VsaAnf.KdArtiID IN (SELECT KdArtiID FROM @KdArti)
  AND VsaAnf.Status IN (N'A', N'C');

SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - ' + FORMAT(@@ROWCOUNT, N'N0') + N' anforderbare Artikel gefunden.';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

UPDATE VsaAnf SET [Status] = N'I', UserID_ = @userid WHERE ID IN (SELECT VsaAnfID FROM @VsaAnf);

SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - ' + FORMAT(@@ROWCOUNT, N'N0') + N' anforderbar Artikkel auf inaktiv gesetzt.';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

UPDATE KdArti SET [Status] = N'I', UserID_ = @userid WHERE ID IN (SELECT KdArtiID FROM @KdArti);

SET @msg = FORMAT(GETDATE(), N'yyyy-MM-dd HH:mm:ss') + N' - ' + FORMAT(@@ROWCOUNT, N'N0') + N' Kundenartikel auf inaktiv gesetzt.';
RAISERROR(@msg, 0, 1) WITH NOWAIT;

GO