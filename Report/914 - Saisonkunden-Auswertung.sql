DECLARE @von date = $1$;
DECLARE @bis date = $2$;
DECLARE @MinLS int = $4$;

WITH AnzLSKunde AS (
  SELECT Vsa.KundenID, COUNT(LsKo.ID) AS AnzLs
  FROM LsKo
  JOIN Vsa ON LsKo.VsaID = Vsa.ID
  WHERE EXISTS (
    SELECT LsPo.*
    FROM LsPo
    WHERE LsPo.LsKoID = LsKo.ID
      AND LsPo.Menge > 0
    )
    AND LsKo.Datum BETWEEN @von AND @bis
  GROUP BY Vsa.KundenID
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, KdGf.KdGfBez AS Geschäftsbereich, Branche.BrancheBez AS Branche, Firma.SuchCode AS Firma, Standort.Bez AS Haupstandort, ISNULL(AnzLSKunde.AnzLs, 0) AS [Anzahl Lieferscheine]
FROM Kunden
JOIN KdGf ON Kunden.KdGFID = Kdgf.ID
JOIN Branche ON Kunden.BrancheID = Branche.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
LEFT OUTER JOIN AnzLSKunde ON AnzLSKunde.KundenID = Kunden.ID
WHERE ISNULL(AnzLSKunde.AnzLs, 0) <= @MinLS
  AND Standort.ID IN ($3$)
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1;