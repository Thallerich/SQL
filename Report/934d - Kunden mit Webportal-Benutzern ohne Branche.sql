/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Webuser Kunde                                                                                                             ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT
  Firma = Firma.SuchCode,
  Vertriebszone = [Zone].ZonenCode,
  Geschäftsbereich = KdGf.KurzBez,
  KdNr = Kunden.KdNr,
  Kunde = Kunden.SuchCode,
  Hauptstandort = Standort.Bez,
  Kundenbetreuer = STUFF((
    SELECT N';  ' + Mitarbei.Name
    FROM KdBer
    JOIN Mitarbei ON KdBer.BetreuerID = Mitarbei.ID
    WHERE KdBer.KundenID = Kunden.ID
      AND KdBer.[Status] = N'A'
    GROUP BY Mitarbei.Name
    ORDER BY COUNT(KdBer.ID) DESC
    FOR XML PATH('')
  ), 1, 2, N''),
  [Aktive Webportal-Benutzer] = SUM(IIF(Webuser.[Status] = 'A', 1, 0)),
  [Inaktive Webportal-Benutzer] = SUM(IIF(Webuser.[Status] != 'A', 1, 0)),
  Webportal = IIF(SUM(IIF(Webuser.[Status] = 'A', 1, 0)) = 0, 'N', 'J')
FROM Kunden
LEFT JOIN Webuser on Webuser.KundenID = Kunden.ID
JOIN KdGf ON Kunden.KdGfID = KdGf.ID
JOIN Firma ON Kunden.FirmaID = Firma.ID
JOIN Standort ON Kunden.StandortID = Standort.ID
JOIN [Zone] on Kunden.ZoneID = [Zone].ID
WHERE Kunden.[Status] = N'A'
  AND Kunden.AdrArtID = 1
  AND Firma.ID in ($1$)
  AND Kdgf.ID in ($2$)
  AND Zone.ID in ($5$)
  AND (($6$ = 1 AND WebUser.[Status] = N'A') OR ($6$ = 0))
  AND EXISTS (
    SELECT KdBer.*
    FROM KdBer
    WHERE KdBer.BetreuerID IN ($3$)
      AND KdBer.KundenID = Kunden.ID
      AND KdBer.[Status] = N'A'
  )
GROUP BY Firma.SuchCode, [Zone].ZonenCode, KdGf.KurzBez, Kunden.ID, Kunden.KdNr, Kunden.SuchCode, Standort.Bez
ORDER BY Firma, Geschäftsbereich, KdNr;

/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */
/* ++ Webuser VSA                                                                                                               ++ */
/* +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ */

SELECT
  Firma = Firma.SuchCode,
  Vertriebszone = [Zone].ZonenCode,
  Geschäftsbereich = KdGf.KurzBez,
  KdNr = Kunden.KdNr,
  Kunde = Kunden.SuchCode,
  Hauptstandort = Standort.Bez,
  VsaNr = Vsa.VsaNr,
  [Vsa-Bezeichnung] = Vsa.Bez,
  Kundenbetreuer = STUFF((
    SELECT N';  ' + Mitarbei.Name
    FROM VsaBer
    JOIN Mitarbei ON VsaBer.BetreuerID = Mitarbei.ID
    WHERE VsaBer.VsaID = Vsa.ID
      AND VsaBer.[Status] = N'A'
    GROUP BY Mitarbei.Name
    ORDER BY COUNT(VsaBer.ID) DESC
    FOR XML PATH('')
  ), 1, 2, N''),
  SUM(IIF(VsaWebuser.[Status] = 'A', 1, 0)) [Aktive Webportal-Benutzer],
  SUM(IIF(VsaWebuser.[Status] != 'A', 1, 0)) [Inaktive Webportal-Benutzer],
  IIF(SUM(IIF(VsaWebuser.[Status] = 'A', 1, 0)) = 0, 'N', 'J') AS [Webportal] 
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
  AND Zone.ID in ($5$)
  AND (($6$ = 1 AND VsaWebuser.Status = N'A') OR ($6$ = 0))
  AND EXISTS (
    SELECT VsaBer.*
    FROM VsaBer
    WHERE VsaBer.BetreuerID IN ($3$)
      AND VsaBer.VsaID = Vsa.ID
      AND VsaBer.[Status] = N'A'
  )
GROUP BY Firma.SuchCode, [Zone].ZonenCode, KdGf.KurzBez, Kunden.KdNr, Kunden.SuchCode, Standort.Bez, Vsa.ID, Vsa.VsaNr, Vsa.Bez
ORDER BY Firma, Geschäftsbereich, KdNr;