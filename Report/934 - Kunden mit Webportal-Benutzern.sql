/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Webuser Kunde                                                                                                             ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Firma.SuchCode AS Firma, KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr, Kunden.SuchCode AS Kunde, Standort.Bez AS Hauptstandort, COUNT(WebUser.ID) AS [Anzahl Webportal-Benutzer]
FROM WebUser
JOIN Kunden ON WebUser.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
WHERE Firma.ID IN ($1$)
  AND KdGf.ID IN ($2$)
  AND WebUser.Status = N'A'
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
  AND EXISTS (
    SELECT KdBer.*
    FROM KdBer
    WHERE KdBer.BetreuerID IN ($3$)
      AND KdBer.KundenID = Kunden.ID
  )
GROUP BY Firma.SuchCode, KdGf.KurzBez, Kunden.KdNr, Kunden.SuchCode, Standort.Bez
ORDER BY Firma, Geschäftsbereich, KdNr;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Webuser VSA                                                                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Firma.SuchCode AS Firma, KdGf.KurzBez AS Geschäftsbereich, Kunden.KdNr, Kunden.SuchCode AS Kunde, Standort.Bez AS Hauptstandort, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], COUNT(WebUser.ID) AS [Anzahl Webportal-Benutzer]
FROM WebUser
JOIN Kunden ON WebUser.KundenID = Kunden.ID
JOIN Vsa ON Vsa.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
WHERE Firma.ID IN ($1$)
  AND KdGf.ID IN ($2$)
  AND WebUser.Status = N'A'
  AND Kunden.Status = N'A'
  AND Kunden.AdrArtID = 1
  AND Kunden.SichtbarID IN ($SICHTBARIDS$)
  AND EXISTS (
    SELECT KdBer.*
    FROM KdBer
    WHERE KdBer.BetreuerID IN ($3$)
      AND KdBer.KundenID = Kunden.ID
  )
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
GROUP BY Firma.SuchCode, KdGf.KurzBez, Kunden.KdNr, Kunden.SuchCode, Standort.Bez, Vsa.VsaNr, Vsa.Bez
ORDER BY Firma, Geschäftsbereich, KdNr;