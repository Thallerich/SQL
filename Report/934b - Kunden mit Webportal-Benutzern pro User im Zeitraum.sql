/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Webuser Kunde                                                                                                             ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Firma.SuchCode AS Firma, KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kundenstatus.StatusBez AS [Status Kunde], Standort.Suchcode AS Hauptstandort, WebUser.Username AS [Webportal-Benutzer], WebUserStatus.StatusBez AS [Status Webportal-Benutzer], COUNT(WebLogin.ID) AS [Anzahl Logins], MAX(WebLogin.Zeitpunkt) AS [letzter Login]
FROM WebUser
JOIN Kunden ON WebUser.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN WebLogin ON WebUser.UserName = WebLogin.UserName
JOIN (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'KUNDEN'  
) AS Kundenstatus ON Kunden.[Status] = Kundenstatus.[Status]
JOIN (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'WEBUSER'
) AS WebUserStatus ON WebUser.[Status] = WebUserStatus.[Status]
WHERE Firma.ID IN ($2$)
  AND KdGf.ID IN ($3$)
  AND Kunden.AdrArtID = 1
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
  AND WebLogin.Zeitpunkt >= $1$
  AND WebLogin.IsLogout = 0
  AND WebLogin.Success = 1
  AND Kundenstatus.ID IN ($4$)
GROUP BY Firma.SuchCode, KdGf.KurzBez, Kunden.KdNr, Kunden.SuchCode, Kundenstatus.StatusBez, Standort.Suchcode, WebUser.UserName, WebUserStatus.StatusBez
ORDER BY Firma, Geschäftsbereich, KdNr;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Webuser VSA                                                                                                             ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Firma.SuchCode AS Firma, KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr, Kunden.SuchCode AS Kunde, Kundenstatus.StatusBez AS [Status Kunde], Standort.Suchcode AS Hauptstandort, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], WebUser.Username AS [Webportal-Benutzer], WebUserStatus.StatusBez AS [Status Webportal-Benutzer], COUNT(WebLogin.ID) AS [Anzahl Logins], MAX(WebLogin.Zeitpunkt) AS [letzter Login]
FROM WebUser
JOIN Kunden ON WebUser.KundenID = Kunden.ID
JOIN Vsa ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN WebLogin ON WebUser.UserName = WebLogin.UserName
JOIN (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'KUNDEN'  
) AS Kundenstatus ON Kunden.[Status] = Kundenstatus.[Status]
JOIN (
  SELECT [Status].ID, [Status].[Status], [Status].StatusBez$LAN$ AS StatusBez
  FROM [Status]
  WHERE [Status].Tabelle = N'WEBUSER'
) AS WebUserStatus ON WebUser.[Status] = WebUserStatus.[Status]
WHERE Firma.ID IN ($2$)
  AND KdGf.ID IN ($3$)
  AND Kunden.AdrArtID = 1
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
  AND WebLogin.Zeitpunkt >= $1$
  AND WebLogin.IsLogout = 0
  AND WebLogin.Success = 1
  AND Kundenstatus.ID IN ($4$)
  AND Vsa.ID IN ( 
    SELECT Vsa.ID 
    FROM Vsa 
    JOIN WebUser AS wu ON wu.KundenID = Vsa.KundenID 
    LEFT JOIN WebUVsa ON WebUVsa.WebUserID = wu.ID 
    WHERE wu.ID = WebUser.ID
      AND (WebUVsa.ID IS NULL OR WebUVsa.VsaID = Vsa.ID) 
  )
  AND Vsa.AbteilID IN (  
    SELECT WebUAbt.AbteilID
    FROM WebUAbt
    WHERE WebUAbt.WebUserID = WebUser.ID
  )
GROUP BY Firma.SuchCode, KdGf.KurzBez, Kunden.KdNr, Kunden.SuchCode, Kundenstatus.StatusBez, Standort.Suchcode, WebUser.UserName, WebUserStatus.StatusBez, Vsa.VsaNr, Vsa.Bez
ORDER BY Firma, Geschäftsbereich, KdNr;