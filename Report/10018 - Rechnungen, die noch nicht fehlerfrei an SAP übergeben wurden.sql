WITH Rechnungsstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'RECHKO'
)
SELECT RechKo.ID AS RechKoID, RechKo.RechNr, RechKo.Art, Rechnungsstatus.StatusBez AS [Status der Rechnung], RechKo.Debitor, RechKo.Name1 AS Kunde, RechKo.KundenID, RechKo.RechDat AS Rechnungsdatum, (NettoWert + NettoWert2) AS NettoWert, RechKo.BruttoWert, RechKo.DruckZeitpunkt, Firma.SuchCode AS Firma
FROM RechKo
JOIN Kunden ON RechKo.KundenID = Kunden.ID
JOIN Firma ON RechKo.FirmaID = Firma.ID
JOIN Rechnungsstatus ON RechKo.[Status] = Rechnungsstatus.[Status]
WHERE RechKo.[Status] >= N'N'
  AND RechKo.[Status] < N'X'
  AND RechKo.FiBuExpID = -1
  AND RechKo.RechDat BETWEEN $STARTDATE$ AND $ENDDATE$
  AND Kunden.SichtbarID IN ($SICHTBARIDS$);