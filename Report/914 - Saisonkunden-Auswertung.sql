DECLARE @von date = $1$;
DECLARE @bis date = $2$;

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
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, KdGf.KdGfBez AS Geschäftsbereich, Branche.BrancheBez AS Branche, Firma.SuchCode AS Firma, Standort.Bez AS Haupstandort, ISNULL(AnzLSKunde.AnzLs, 0) AS [Anzahl Lieferscheine], SUM(RechKo.NettoWert) AS [Netto-Umsatz 12 Monate]
FROM Kunden
JOIN KdGf ON Kunden.KdGFID = Kdgf.ID
JOIN Branche ON Kunden.BrancheID = Branche.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
LEFT OUTER JOIN RechKo ON RechKo.KundenID = Kunden.ID AND RechKo.RechDat >= DATEADD(month, -12, GETDATE())
LEFT OUTER JOIN AnzLSKunde ON AnzLSKunde.KundenID = Kunden.ID
LEFT OUTER JOIN KdGru ON KdGru.KundenID = Kunden.ID
WHERE Standort.ID IN ($3$)
  AND KdGru.AdrGrpID IN ($4$)
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1
GROUP BY Kunden.KdNr, Kunden.SuchCode, KdGf.KdGfBez, Branche.BrancheBez, Firma.SuchCode, Standort.Bez, ISNULL(AnzLSKunde.AnzLs, 0);