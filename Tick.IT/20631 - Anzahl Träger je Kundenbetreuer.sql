USE Wozabal
GO

SELECT Mitarbei.Name, SUM(IIF(Traeger.Geschlecht = 'M', 1, 0)) AS "Träger männlich", SUM(IIF(Traeger.Geschlecht = 'W', 1, 0)) AS "Träger weiblich", SUM(IIF(Traeger.Geschlecht NOT IN ('M', 'W'), 1, 0)) AS "Träger andere"
FROM Traeger, Vsa, Kunden, Mitarbei, KdGf, (
  SELECT DISTINCT VsaBer.VsaID, VsaBer.BetreuerID
  FROM VsaBer
) AS VsaBer
WHERE Traeger.VsaID = Vsa.ID
  AND Vsa.KundenID = Kunden.ID
  AND VsaBer.VsaID = Vsa.ID
  AND VsaBer.BetreuerID = Mitarbei.ID
  AND Kunden.KdGfID = KdGf.ID
  AND VsaBer.BetreuerID > 0
  AND Traeger.Status = 'A'
  AND Kunden.Status = 'A'
  -- AND KdGf.KurzBez IN ('GW', 'SH')
GROUP BY Mitarbei.Name

GO