DECLARE @cutoff datetime = $1$;
DECLARE @CustomerID int = $ID$;
DECLARE @LockedNonContract int;
DECLARE @NotLockedReplacement int;
DECLARE @LockedOld int;

UPDATE OPTeile SET RechPoID = -2
WHERE OPTeile.Status = 'W'
  AND OPTeile.LastActionsID IN (102, 116, 120)
  AND OPTeile.RechPoID < 0
  AND OPTeile.RechPoID != -2
  AND OPTeile.VsaID IN (SELECT Vsa.ID FROM Vsa WHERE Vsa.KundenID = @CustomerID)
  AND OPTeile.ArtikelID IN (SELECT KdArti.ArtikelID FROM KdArti WHERE KdArti.KundenID = @CustomerID AND KdArti.Vertragsartikel = 0 AND KdArti.ErsatzFuerKdArtiID < 0);

SET @LockedNonContract = @@ROWCOUNT;

SET @NotLockedReplacement = (
  SELECT COUNT(OPTeile.ID)
  FROM OPTeile
  WHERE OPTeile.Status = 'W'
    AND OPTeile.LastActionsID IN (102, 116, 120)
    AND OPTeile.RechPoID < 0
    AND OPTeile.RechPoID != -2
    AND OPTeile.VsaID IN (SELECT Vsa.ID FROM Vsa WHERE Vsa.KundenID = @CustomerID)
    AND OPTeile.ArtikelID IN (SELECT KdArti.ArtikelID FROM KdArti WHERE KdArti.KundenID = @CustomerID AND KdArti.Vertragsartikel = 0 AND KdArti.ErsatzFuerKdArtiID > 0)
);

UPDATE OPTeile SET RechPoID = -2
WHERE OPTeile.Status = 'W'
  AND OPTeile.LastActionsID IN (102, 116, 120)
  AND OPTeile.RechPoID < 0
  AND OPTeile.RechPoID != -2
  AND OPTeile.VsaID IN (SELECT Vsa.ID FROM Vsa WHERE Vsa.KundenID = @CustomerID)
  AND OPTeile.LastScanTime < @cutoff;

SET @LockedOld = @@ROWCOUNT;

SELECT CAST(@LockedNonContract AS nvarchar) + ' Schwundteile, die kein Vertragsartikel sind, für Verrechnung gesperrt!' AS Message
UNION ALL
SELECT CAST(@NotLockedReplacement AS nvarchar) + ' Schwundteile wurden nicht gesperrt, da als Ersatz geliefert!' AS Message
UNION ALL
SELECT CAST(@LockedOld AS nvarchar) + ' Schwundteile mit letztem Scan vor ' + CONVERT(char(10), FORMAT(@cutoff, 'dd.MM.yyyy', 'de-AT')) + ' für die Verrechnung gesperrt!' AS Message
UNION ALL
SELECT CAST(x.Anz AS nvarchar) + ' Schwundteile verbleiben zur Verrechnung.' AS Message
FROM (
  SELECT COUNT(*) AS Anz
  FROM OPTeile
  WHERE OPTeile.Status = 'W'
    AND OPTeile.RechPoID = -1
    AND OPTeile.VsaID IN (SELECT Vsa.ID FROM Vsa WHERE Vsa.KundenID = @CustomerID)
) x;