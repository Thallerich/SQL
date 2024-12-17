/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Webuser Kunde                                                                                                             ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Firma.SuchCode AS Firma, [Zone].ZonenCode AS Vertriebszone, KdGf.KurzBez AS Geschäftsbereich, Branche.BrancheBez$LAN$ AS Branche, Kunden.KdNr, Kunden.SuchCode AS Kunde, Standort.Bez AS Hauptstandort, SUM(IIF(Webuser.[Status] = 'A', 1, 0)) [Aktive Webportal-Benutzer], SUM(IIF(Webuser.[Status] != 'A', 1, 0)) [Inaktive Webportal-Benutzer], IIF(SUM(IIF(Webuser.[Status] = 'A', 1, 0)) = 0, 'N', 'J') AS [Webportal] 
FROM Kunden
LEFT JOIN Webuser on Webuser.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN Branche on Kunden.BrancheID = Branche.ID
JOIN [Zone] on Kunden.ZoneID = [Zone].ID
WHERE Kunden.[Status] = N'A'
  AND Kunden.AdrArtID = 1
  AND Firma.ID in ($1$)
  AND Kdgf.ID in ($2$)
  AND Branche.ID in ($4$)
  AND Zone.ID in ($5$)
  AND (($6$ = 1 AND WebUser.[Status] = N'A') OR ($6$ = 0))
  AND EXISTS (
    SELECT KdBer.*
    FROM KdBer
    WHERE KdBer.BetreuerID IN ($3$)
      AND KdBer.KundenID = Kunden.ID
  )
GROUP BY Firma.SuchCode, [Zone].ZonenCode, KdGf.KurzBez, Branche.BrancheBez$LAN$, Kunden.KdNr, Kunden.SuchCode, Standort.Bez
ORDER BY Firma, Geschäftsbereich, KdNr;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Webuser VSA                                                                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT Firma.SuchCode AS Firma, [Zone].ZonenCode AS Vertriebszone, KdGf.KurzBez AS Geschäftsbereich, Branche.BrancheBez$LAN$ AS Branche, Kunden.KdNr, Kunden.SuchCode AS Kunde, Standort.Bez AS Hauptstandort, Vsa.VsaNr, Vsa.Bez AS [Vsa-Bezeichnung], SUM(IIF(VsaWebuser.[Status] = 'A', 1, 0)) [Aktive Webportal-Benutzer], SUM(IIF(VsaWebuser.[Status] != 'A', 1, 0)) [Inaktive Webportal-Benutzer], IIF(SUM(IIF(VsaWebuser.[Status] = 'A', 1, 0)) = 0, 'N', 'J') AS [Webportal] 
FROM Vsa
JOIN Kunden ON Vsa.KundenID = Kunden.ID
LEFT JOIN (
  SELECT Vsa.ID AS VsaID, WebUser.ID AS WebUserID, WebUser.[Status]
  FROM Vsa
  JOIN Webuser ON Vsa.KundenID = WebUser.KundenID
  WHERE Vsa.ID IN ( 
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

) AS VsaWebuser ON Vsa.ID = VsaWebUser.VsaID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN Branche on Kunden.BrancheID = Branche.ID
JOIN [Zone] on Kunden.ZoneID = [Zone].ID
WHERE Kunden.[Status] = N'A'
  AND Vsa.[Status] = N'A'
  AND Kunden.AdrArtID = 1
  AND Firma.ID in ($1$)
  AND Kdgf.ID in ($2$)
  AND Branche.ID in ($4$)
  AND Zone.ID in ($5$)
  AND (($6$ = 1 AND VsaWebuser.Status = N'A') OR ($6$ = 0))
  AND EXISTS (
    SELECT KdBer.*
    FROM KdBer
    WHERE KdBer.BetreuerID IN ($3$)
      AND KdBer.KundenID = Kunden.ID
  )
GROUP BY Firma.SuchCode, [Zone].ZonenCode, KdGf.KurzBez, Branche.BrancheBez$LAN$, Kunden.KdNr, Kunden.SuchCode, Standort.Bez, Vsa.VsaNr, Vsa.Bez
ORDER BY Firma, Geschäftsbereich, KdNr;