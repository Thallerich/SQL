DECLARE @KdNr int;
DECLARE @Datum date;
DECLARE @Bereich nchar(2);
DECLARE @UserID int = (SELECT ID FROM Mitarbei WHERE UserName = N'THALST');

SET @KdNr = 10002702;
SET @Datum = CAST(N'2021-09-17' AS date);
SET @Bereich = N'FW';

IF OBJECT_ID(N'tempdb..#Schwund') IS NULL
  CREATE TABLE #Schwund (
    OPTeileID int,
    ArtikelID int,
    ArtGroeID int,
    VsaID int
  );
ELSE
  TRUNCATE TABLE #Schwund;

INSERT INTO #Schwund (OPTeileID, ArtikelID, ArtGroeID, VsaID)
SELECT OPTeile.ID AS OPTeileID, IIF(OPTeile.LastErsatzFuerKdArtiID < 0, OPTeile.ArtikelID, OPTeile.LastErsatzFuerKdArtiID) AS ArtikelID, IIF(OPTeile.LastErsatzArtGroeID < 0, OPTeile.ArtGroeID, OPTeile.LastErsatzArtGroeID) AS ArtGroeID, OPTeile.VsaID AS VsaID
FROM OPTeile, Vsa, Kunden, Artikel, Bereich
WHERE OPTeile.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
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

WITH Schwund AS (
  SELECT S.VsaID, S.ArtGroeID, S.ArtikelID, COUNT(DISTINCT S.OPTeileID) AS Schwundmenge
  FROM #Schwund AS S
  GROUP BY S.VsaID, S.ArtGroeID, S.ArtikelID
)
UPDATE VsaAnf SET Bestand = IIF((VsaAnf.Bestand - Schwund.Schwundmenge) - ((VsaAnf.Bestand - Schwund.Schwundmenge) % Artikel.Packmenge) + IIF((VsaAnf.Bestand - Schwund.Schwundmenge) % Artikel.Packmenge = 0, 0, Artikel.Packmenge) < 0, 0,  (VsaAnf.Bestand - Schwund.Schwundmenge) - ((VsaAnf.Bestand - Schwund.Schwundmenge) % Artikel.Packmenge) + IIF((VsaAnf.Bestand - Schwund.Schwundmenge) % Artikel.Packmenge = 0, 0, Artikel.Packmenge))
FROM VsaAnf
JOIN Vsa ON VsaAnf.VsaID = Vsa.ID
JOIN Kunden ON Vsa.KundenID = Kunden.ID
JOIN KdArti ON VsaAnf.KdArtiID = KdArti.ID
JOIN Artikel ON KdArti.ArtikelID = Artikel.ID
JOIN Schwund ON Schwund.VsaID = Vsa.ID AND (Schwund.ArtGroeID = VsaAnf.ArtGroeID OR VsaAnf.ArtGroeID = -1) AND Schwund.ArtikelID = Artikel.ID;