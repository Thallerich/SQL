WITH Kundenstatus AS (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'KUNDEN'
)
SELECT Firma.SuchCode AS Firma, KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kundenstatus.StatusBez AS [Status Kunde], Standort.Suchcode AS Hauptstandort, COUNT(DISTINCT WebUser.ID) AS [Anzahl Webportal-Benutzer], COUNT(WebLogin.ID) AS [Anzahl Logins], MAX(WebLogin.Zeitpunkt) AS [letzter Login]
FROM WebUser
JOIN Kunden ON WebUser.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN WebLogin ON WebUser.UserName = WebLogin.UserName
JOIN Kundenstatus ON Kunden.[Status] = Kundenstatus.[Status]
WHERE Firma.ID IN ($2$)
  AND KdGf.ID IN ($3$)
  AND Kunden.AdrArtID = 1
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
  AND WebLogin.Zeitpunkt BETWEEN $STARTDATE$ AND $ENDDATE$
  AND WebLogin.IsLogout = 0
  AND WebLogin.Success = 1
  AND Kundenstatus.ID IN ($4$)
GROUP BY Firma.SuchCode, KdGf.KurzBez, Kunden.KdNr, Kunden.SuchCode, Kundenstatus.StatusBez, Standort.Suchcode
ORDER BY Firma, Geschäftsbereich, KdNr;