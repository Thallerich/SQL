DECLARE @cutoff datetime;
SET @cutoff = $1$;

UPDATE OPTeile SET RechPoID = -2
WHERE OPTeile.Status = 'W'
  AND OPTeile.RechPoID < 0
  AND OPTeile.VsaID IN (SELECT Vsa.ID FROM Vsa WHERE Vsa.KundenID = $ID$)
  AND OPTeile.ArtikelID IN (SELECT KdArti.ArtikelID FROM KdArti WHERE KdArti.KundenID = $ID$ AND KdArti.Vertragsartikel = $FALSE$);

UPDATE OPTeile SET RechPoID = -2
WHERE OPTeile.Status = 'W'
  AND OPTeile.RechPoID < 0
  AND OPTeile.VsaID IN (SELECT Vsa.ID FROM Vsa WHERE Vsa.KundenID = $ID$)
  AND OPTeile.LastScanTime < @cutoff;

SELECT 'Schwundteile, die kein Vertragsartikel sind, für Verrechnung gesperrt!' AS Message
UNION ALL
SELECT 'Schwundteile mit letztem Scan vor ' + CONVERT(char(10), FORMAT($1$, 'dd.MM.yyyy', 'de-AT')) + ' für die Verrechnung gesperrt!' AS Message
UNION ALL
SELECT TRIM(CONVERT(char, x.Anz)) + ' Schwundteile verbleiben zur Verrechnung.' AS Message
FROM (
  SELECT COUNT(*) AS Anz
  FROM OPTeile
  WHERE OPTeile.Status = 'W'
    AND OPTeile.RechPoID = -1
    AND OPTeile.VsaID IN (SELECT Vsa.ID FROM Vsa WHERE Vsa.KundenID = $ID$)
) x;