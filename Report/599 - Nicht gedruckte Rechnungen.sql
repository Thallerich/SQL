SELECT Kunden.KdNr, 
  Kunden.SuchCode AS Kunde,
  Kundenservice = (
    SELECT TOP 1 Mitarbei.Name
    FROM Mitarbei
    JOIN KdBer ON KdBer.ServiceID = Mitarbei.ID
    WHERE KdBer.KundenID = Kunden.ID
    GROUP BY Mitarbei.Name
    ORDER BY COUNT(Mitarbei.ID) DESC
  ),
  KdGf.KurzBez AS SGF, 
  RechKo.RechNr, 
  [Status].StatusBez$LAN$ AS Rechnungsstatus,
  RechKo.Art,
  RechKo.NettoWert,
  [Letzter Fibu-Export] = (
    SELECT TOP 1 NettoWert
    FROM RechKo FE
    WHERE FE.KundenID = RechKo.KundenID
      AND FE.AbteilID = RechKo.AbteilID
      AND FE.FibuExpID > 0
      AND FE.Art = N'R'
    ORDER BY FE.ID DESC
  )
FROM RechKo
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN [Status] ON RechKo.Status = [Status].[Status] AND [Status].Tabelle = N'RECHKO'
JOIN DrLauf ON RechKo.DrLaufID = DrLauf.ID
WHERE KdGf.ID IN ($1$)
  AND RechKo.FirmaID IN ($2$)
  AND RechKo.[Status] < N'F'
  AND DrLauf.SichtbarID IN ($SICHTBARIDS$)
  AND ((Kunden.FakAustausch = 1 AND $3$ = 1) OR ($3$ = 0))
ORDER BY SGF, Kunden.KdNr, RechKo.RechNr;