DECLARE @FirmaID int = $1$;
DECLARE @von date = $STARTDATE$;
DECLARE @bis date = $ENDDATE$;

WITH Schwund AS (
  SELECT RechKo.KundenID, SUM(RechKo.NettoWert) AS SchwundNetto
  FROM RechKo
  WHERE RechKo.FirmaID = @FirmaID
    AND RechKo.RechDat BETWEEN @von AND @bis
    AND RechKo.RKoTypeID = 91 /* Schwundverrechnung */
  GROUP BY RechKo.KundenID
),
Umsatz AS (
  SELECT RechKo.KundenID, SUM(RechKo.NettoWert) AS UmsatzNetto
  FROM RechKo
  WHERE RechKo.FirmaID = @FirmaID
    AND RechKo.RechDat BETWEEN @von AND @bis
    AND RechKo.RKoTypeID != 91 /* keine Schwundverrechnung */
  GROUP BY RechKo.KundenID

),
Kundenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'KUNDEN'
)
SELECT Kunden.KdNr, Kunden.SuchCode AS Kunde, Kundenstatus.StatusBez AS [Status], KdGf.KurzBez AS Geschäftsbereich, Schwund.SchwundNetto, Umsatz.UmsatzNetto
FROM Kunden
LEFT JOIN Schwund ON Schwund.KundenID = Kunden.ID
LEFT JOIN Umsatz ON Umsatz.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Kundenstatus ON Kunden.[Status] = Kundenstatus.[Status]
WHERE Kunden.FirmaID = @FirmaID
  AND Kunden.AdrArtID = 1
  AND Kunden.ID IN ($3$)
  AND EXISTS (
    SELECT RechKo.ID
    FROM RechKo
    WHERE RechKo.KundenID = Kunden.ID
      AND RechKo.RechDat BETWEEN @von AND @bis
  );