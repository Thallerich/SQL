SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, KdGf.KurzBez AS SGF, RechKo.RechNr, Status.StatusBez$LAN$ AS Rechnungsstatus, RechKo.Art, RechKo.NettoWert, (
  SELECT TOP 1 NettoWert
  FROM RechKo FE
  WHERE FE.KundenID = RechKo.KundenID
    AND FE.AbteilID = RechKo.AbteilID
    AND FE.FibuExpID > 0
    AND FE.Art = 'R'
  ORDER BY FE.ID DESC
) AS [Letzter Fibu-Export]
FROM RechKo, Kunden, KdGf, Status
WHERE RechKo.KundenID = Kunden.ID
  AND Kunden.KdGfID = KdGf.ID
  AND RechKo.Status = Status.Status
  AND Status.Tabelle = 'RECHKO'
  AND KdGf.ID IN ($1$)
  AND RechKo.Status < 'F'
ORDER BY SGF, Kunden.KdNr, RechKo.RechNr;