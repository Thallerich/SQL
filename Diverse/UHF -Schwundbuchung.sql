DECLARE @KdNr int;
DECLARE @Datum date;
DECLARE @Bereich nchar(2);
DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

SET @KdNr = 10002703;
SET @Datum = CAST(N'2021-06-17' AS date);
SET @Bereich = N'BK';

IF OBJECT_ID(N'tempdb..#Schwund') IS NULL
  CREATE TABLE #Schwund (
    OPTeileID int,
    ArtikelID int,
    VsaID int
  );
ELSE
  TRUNCATE TABLE #Schwund;

INSERT INTO #Schwund (OPTeileID, ArtikelID, VsaID)
SELECT OPTeile.ID AS OPTeileID, IIF(OPTeile.LastErsatzFuerKdArtiID < 0, OPTeile.ArtikelID, KdArti.ArtikelID) AS ArtikelID, OPTeile.VsaID AS VsaID
FROM OPTeile, Vsa, Kunden, KdArti, Artikel, Bereich
WHERE OPTeile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND OPTeile.LastErsatzFuerKdArtiID = KdArti.ID
  AND OPTeile.ArtikelID = Artikel.ID
  AND Artikel.BereichID = Bereich.ID
  AND Kunden.KdNr = @KdNr
  AND Bereich.Bereich = @Bereich
  AND OPTeile.LastScanTime < @Datum
  AND OPTeile.Status = N'Q'
  AND OPTeile.LastActionsID IN (102, 120, 136);

UPDATE OPTeile SET Status = N'W', LastActionsID = 116
WHERE ID IN (
  SELECT OPTeileID
  FROM #Schwund
);

INSERT INTO OPScans (Zeitpunkt, OPTeileID, ZielNrID, ActionsID, UserID_, AnlageUserID_)
SELECT GETDATE(), OPTeileID, 10000105, 116, @UserID, @UserID
FROM #Schwund;